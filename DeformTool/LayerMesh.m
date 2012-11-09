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
	int tileSize;
	GLfloat* vertices;
	int vertNum;
	
	GLushort* indices;
	int indexCount;
	
	
	
	DeformVectors* deformVectors;
}
@end


@implementation LayerMesh
@synthesize vertices, vectors, vertNum;
@synthesize indices, indexCount;
@synthesize layout, tileSize, textureContentSize;


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
	}
	return self;
}

-(GLfloat*) vectors
{
	return deformVectors.vectors;
}


-(void) satisfyVisibleRect:(CGRect)visibleRect
{
	int left = floorf(visibleRect.origin.x/tileSize);
	int right = ceilf((visibleRect.origin.x+visibleRect.size.width)/tileSize);
	int top = floorf(visibleRect.origin.y/tileSize);
	int bottom = ceilf((visibleRect.origin.y+visibleRect.size.height)/tileSize);

	int layoutMaxX = layout.x+layout.width;
	int layoutMaxY = layout.y+layout.height;
	if(left < layout.x || right > layoutMaxX || top < layout.y || bottom > layoutMaxY)
	{
		left = MIN(left, layout.x);
		right = MAX(right, layoutMaxX);
		top = MIN(top, layout.y);
		bottom = MAX(bottom, layoutMaxY);
		
		layout = MeshLayoutMake(left, top, right-left, bottom-top);
		[deformVectors extendLayout:layout];

		[self rebuildVertices];
		[self rebuildTextureCoordinates];
		[self rebuildIndices];
	}
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
			NSAssert(fabs(coordPtr[0]-x) < 0.000001 && fabs(coordPtr[1]-y) < 0.000001, @"Invalid vDSP processing");
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


-(void) buildMeshForLayout:(MeshLayout)viewLayout 
{
	/*
	if(!MeshLayoutContainsLayout(textureMesh.layout, viewLayout)) {
		MeshLayout unionLayout = MeshLayoutUnion(textureMesh.layout, viewLayout);
		[textureMesh extendMeshLayout:unionLayout];
	}
	*/
	//int ts = textureMesh.tileSize;
	//CGRect viewRect = CGRectMake(viewLayout.x*ts, viewLayout.y*ts, viewLayout.width*ts, viewLayout.height*ts);
	
	
	
}


-(GLfloat*) texCoords
{
	return textureCoordinates;
}

-(int) texCoordNum
{
	return vertNum;
}


@end





























