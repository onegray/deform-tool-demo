//
//  LayerMesh.m
//  DeformTool
//
//  Created by onegray on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LayerMesh.h"
#import "DeformVectors.h"
#import <Accelerate/Accelerate.h>

@interface LayerMesh()
{
	double textureWidth1px;
	double textureHeight1px;
	CGRect textureCoordinateRect;
	GLfloat* textureCoordinates;

	MeshLayout layout;
	LayoutWindow maxLayoutWindow;
	
	int tileSize;
	GLfloat* vertices;
	int vertNum;
	
	GLushort* indices;
	int indexCount;
	
	int vertOffset;
	
	DeformVectors* deformVectors;
}
@end


@implementation LayerMesh
@synthesize vertices, vectors, vertNum;
@synthesize indices, indexCount;
@synthesize layout, tileSize, textureContentSize;
@synthesize vertStride;

-(id) initWithTextureSize:(PixelSize)ts
{
	self = [super init];
	if(self) {
		NSAssert( ts.widthPixels % MAX_TEXTURE_TILE_SIZE == 0, @"");
		NSAssert( ts.heighPixels % MAX_TEXTURE_TILE_SIZE == 0, @"");
		
		tileSize = 8;
		textureContentSize = ts;
		layout = MeshLayoutMake(0, 0, ts.widthPixels/tileSize, ts.heighPixels/tileSize);
		textureCoordinateRect = CGRectMake(0, 0, 1, 1);
		textureWidth1px = (double)textureCoordinateRect.size.width / textureContentSize.widthPixels;
		textureHeight1px = (double)textureCoordinateRect.size.height / textureContentSize.heighPixels;
		
		deformVectors = [[DeformVectors alloc] initWithLayout:layout];
		
		/*
		layout = MeshLayoutMake(-7, -8, layout.width+20, layout.height+20);
		[textureMesh extendMeshLayout:layout];
		*/
		 
		/*
		[textureMesh resampleMesh:2];
		tileSize = tileSize/2;
		layout = textureMesh.layout;
		*/
		
		[self rebuildVertices];
		[self rebuildTextureCoordinates];
		[self rebuildIndices];
		
		vertStride = sizeof(GLfloat)*2;
	}
	return self;
}


-(GLfloat*) vectorsAbsolutePointer
{
	return deformVectors.vectors;
}

-(GLfloat*) vectors
{
	return deformVectors.vectors + vertOffset;
}

-(GLfloat*) vertices
{
	return vertices + vertOffset;
}

-(GLfloat*) texCoords
{
	return textureCoordinates + vertOffset;
}


-(void) extendLayoutForWindow:(LayoutWindow)window
{
	int layoutMaxX = layout.x+layout.width;
	int layoutMaxY = layout.y+layout.height;
	if(window.left < layout.x || window.right > layoutMaxX || window.top < layout.y || window.bottom > layoutMaxY)
	{
		window.left = MIN(window.left, layout.x);
		window.right = MAX(window.right, layoutMaxX);
		window.top = MIN(window.top, layout.y);
		window.bottom = MAX(window.bottom, layoutMaxY);
		
		layout = MeshLayoutFromWindow(window);
		[deformVectors extendLayout:layout];
		
		[self rebuildVertices];
		[self rebuildTextureCoordinates];
		[self rebuildIndices];
	}
}


-(void) setupVisibleRect:(CGRect)visibleRect interlacing:(int)interlacing
{
	int left = floorf(visibleRect.origin.x/tileSize);
	int right = ceilf((visibleRect.origin.x+visibleRect.size.width)/tileSize);
	int top = floorf(visibleRect.origin.y/tileSize);
	int bottom = ceilf((visibleRect.origin.y+visibleRect.size.height)/tileSize);

	int width = right - left;
	int height = bottom - top;
	
	width = ((width+interlacing-1)/interlacing)*interlacing;  // width = n*interlacing
	height = ((height+interlacing-1)/interlacing)*interlacing;

	right = left + width;
	bottom = top + height;
	
	LayoutWindow visibleWindow = LayoutWindowMake(left, top, right, bottom);
	[self extendLayoutForWindow:visibleWindow];
	[self rebuildIndicesForWindow:visibleWindow interlacing:interlacing];
}

-(void) rebuildIndicesForWindow:(LayoutWindow)window interlacing:(int)interlacing
{
	if(indices)
		free(indices);

	int windowWidth = window.right - window.left;
	int windowHeight = window.bottom - window.top;
	NSAssert( !(windowWidth%interlacing) && !(windowHeight%interlacing), @"Invalid window ");
	
	int interlacedLayoutWidth = windowWidth/interlacing;
	int interlacedLayoutHeight = windowHeight/interlacing;

	indexCount = interlacedLayoutHeight*(interlacedLayoutWidth+1)*2;
	indices = malloc(indexCount*sizeof(GLushort));
	GLushort* pi = indices;
	
	for(int i=0; i<interlacedLayoutHeight; i++)
	{
		for(int j=0; j<=interlacedLayoutWidth; j++)
		{
			*pi++ = (i*(layout.width+1) + j);
			*pi++ = ((i+1)*(layout.width+1) +j);
		}
		
		i++;
		if(i==interlacedLayoutHeight)
			break;
		
		for(int j=interlacedLayoutWidth; j>=0; j--)
		{
			*pi++ = ((i+1)*(layout.width+1) + j);
			*pi++ = (i*(layout.width+1) + j);
		}
	}
	NSAssert(indexCount==(pi-indices), @"Invalid indNum");
	
	vertOffset = ((window.top-layout.y)*(layout.width+1) + (window.left-layout.x))*2;
	vertStride = interlacing*sizeof(GLfloat)*2;
}


-(void) rebuildVertices
{
	if(vertices)
		free(vertices);
	
	vertNum = (layout.width+1)*(layout.height+1);
	vertices = (GLfloat*)malloc(vertNum*2*sizeof(GLfloat));
	GLfloat* vertPtr = vertices;
	
	for(int i=0; i<=layout.height; i++)
	{
		for(int j=0; j<=layout.width; j++)
		{
			*vertPtr++ = (layout.x+j)*tileSize;
			*vertPtr++ = (layout.y+i)*tileSize;
		}
	}	
}

-(void) rebuildTextureCoordinates
{
	if(textureCoordinates) {
		free(textureCoordinates);
	}

	int coordNum = (layout.width+1) * (layout.height+1);
	textureCoordinates = (GLfloat*)malloc(coordNum*2*sizeof(GLfloat));
	
	float dx = textureWidth1px*tileSize;
	float dy = textureHeight1px*tileSize;
	

	long rowStride = (layout.width+1)*2;
	
	float x0 = textureCoordinateRect.origin.x+layout.x*dx;
	vDSP_vramp(&x0, &dx, textureCoordinates, 2, layout.width+1);

	float y0 = textureCoordinateRect.origin.y+layout.y*dy;
	vDSP_vramp(&y0, &dy, textureCoordinates+1, rowStride, layout.height+1);

	for(int j=0; j<=layout.width; j++)
	{
		float* colPtr = textureCoordinates + j*2;
		vDSP_vfill(colPtr, colPtr+rowStride, rowStride, layout.height);
	}
	
	for(int i=0; i<=layout.height; i++)
	{
		float* rowPtr = textureCoordinates + i*rowStride;
		vDSP_vfill(rowPtr+1, rowPtr+1+2, 2, layout.width);
	}

#if 1
	GLfloat* coordPtr = textureCoordinates;
	for(int i=0; i<=layout.height; i++)
	{
		for(int j=0; j<=layout.width; j++)
		{
			float x = textureCoordinateRect.origin.x + (layout.x+j) * dx;
			float y = textureCoordinateRect.origin.y + (layout.y+i) * dy;
			NSAssert(fabs(coordPtr[0]-x) < 0.00001 && fabs(coordPtr[1]-y) < 0.00001, @"Invalid vDSP processing");
			*coordPtr++ = x;
			*coordPtr++ = y;
		}
	}
#endif
	
}

-(void) rebuildIndices
{
	if(indices)
		free(indices);
	
	indexCount = layout.height*(layout.width+1)*2;
	indices = malloc(indexCount*sizeof(GLushort));
	GLushort* pi = indices;
	
	for(int i=0; i<layout.height; i++)
	{
		for(int j=0; j<=layout.width; j++)
		{
			*pi++ = i*(layout.width+1) + j;
			*pi++ = (i+1)*(layout.width+1) +j;
		}
		
		i++;
		if(i==layout.height)
			break;
		
		for(int j=layout.width; j>=0; j--)
		{
			*pi++ = (i+1)*(layout.width+1) + j;
			*pi++ = i*(layout.width+1) + j;
		}
	}
	
	NSAssert(indexCount==(pi-indices), @"Invalid indNum");
}


-(void) interlaceIndices:(int)interlacing
{
	if(indices)
		free(indices);

	NSAssert( !(layout.width%interlacing) && !(layout.height%interlacing), @"Invalid layout or interlacing");
	
	int interlacedLayoutWidth = layout.width/interlacing;
	int interlacedLayoutHeight = layout.height/interlacing;
	
	indexCount = interlacedLayoutHeight*(interlacedLayoutWidth+1)*2;
	indices = malloc(indexCount*sizeof(GLushort));
	GLushort* pi = indices;
	
	int max = 0;
	
	for(int i=0; i<interlacedLayoutHeight; i++)
	{
		for(int j=0; j<=interlacedLayoutWidth; j++)
		{
			*pi++ = (i*(layout.width+1) + j)*interlacing;
			*pi++ = ((i+1)*(layout.width+1) +j)*interlacing;
			
			max = MAX(pi[-1], max);
			max = MAX(pi[-2], max);
		}
		
		i++;
		if(i==interlacedLayoutHeight)
			break;
		
		for(int j=interlacedLayoutWidth; j>=0; j--)
		{
			*pi++ = ((i+1)*(layout.width+1) + j)*interlacing;
			*pi++ = (i*(layout.width+1) + j)*interlacing;

			max = MAX(pi[-1], max);
			max = MAX(pi[-2], max);
		}
	}

	NSLog(@"interlaceIndices indexCount: %d", indexCount);
	NSLog(@"interlaceIndices max: %d", max);

	NSAssert(indexCount==(pi-indices), @"Invalid indNum");
}



@end





























