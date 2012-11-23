//
//  LayerMesh.m
//  DeformTool
//
//  Created by onegray on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Accelerate/Accelerate.h>

#import "LayerMesh.h"
#import "DeformVectors.h"
#import "IndexMesh.h"


@interface LayerMesh()
{
	double textureWidth1px;
	double textureHeight1px;
	CGRect textureCoordinateRect;
	GLfloat* textureCoordinates;

	MeshLayout layout;
	LayoutWindow maxLayoutWindow;
	
	int tileSize;
	GLshort* vertices;
	int vertNum;
	
	GLushort* indices;
	//GLushort* indicesBackup;
	int indexCount;
	int indicesWindowWidth;
	int indicesWindowHeight;
	int indicesBuildedForLayoutWidth;
	int indicesInterlacing;
	
	int vertOffset;
	
	DeformVectors* deformVectors;
}
@end


@implementation LayerMesh
@synthesize vertices, vectors, vertNum;
@synthesize indices, indexCount;
@synthesize layout, tileSize, textureContentSize;
@synthesize vertStride, vectorsStride;

-(id) initWithTextureSize:(PixelSize)ts
{
	self = [super init];
	if(self) {
		NSAssert( ts.widthPixels % MAX_TEXTURE_TILE_SIZE == 0, @"");
		NSAssert( ts.heighPixels % MAX_TEXTURE_TILE_SIZE == 0, @"");
		
		tileSize = 4;
		maxLayoutWindow = LayoutWindowMake(-120, -120, 240+120, 240+120);
		textureContentSize = ts;
		layout = MeshLayoutMake(0, 0, ts.widthPixels/tileSize, ts.heighPixels/tileSize);
		textureCoordinateRect = CGRectMake(0, 0, 1, 1);
		textureWidth1px = (double)textureCoordinateRect.size.width / textureContentSize.widthPixels;
		textureHeight1px = (double)textureCoordinateRect.size.height / textureContentSize.heighPixels;
		
		deformVectors = [[DeformVectors alloc] initWithLayout:layout];
				
		[self rebuildVertices];
		//[self rebuildTextureCoordinates];
		[self rebuildIndices_deprecated];
		
		vertStride = sizeof(GLshort)*2;
		vectorsStride = sizeof(GLfloat)*2;
	}
	return self;
}

+(int) interlacingForScale:(CGFloat)scale
{
	static const int values[20] = {1, 1, 2, 3, 4, 5, 6, 6, 8, 8, 10, 10, 12, 12, 12, 15, 15, 15, 15, 15};
	return scale < 20 ? values[(int)scale] : 20;
}

-(GLfloat*) vectorsAbsolutePointer
{
	return deformVectors.vectors;
}

-(GLfloat*) vectors
{
	return deformVectors.vectors + vertOffset;
}

-(GLshort*) vertices
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

	window.left = MIN(window.left, layout.x);
	window.right = MAX(window.right, layoutMaxX);
	window.top = MIN(window.top, layout.y);
	window.bottom = MAX(window.bottom, layoutMaxY);
	
	layout = MeshLayoutFromWindow(window);
	[deformVectors extendLayout:layout];

	[self rebuildVertices];
	//[self rebuildTextureCoordinates];
	//[self rebuildIndices];
}

-(LayoutWindow) inclusiveWindowForRect:(CGRect)rect interlacing:(int)interlacing
{
	int interlacedTileSize = tileSize*interlacing;
	int left = interlacing * floorf(rect.origin.x/interlacedTileSize);
	int right = interlacing * ceilf((rect.origin.x+rect.size.width)/interlacedTileSize);
	int top = interlacing * floorf(rect.origin.y/interlacedTileSize);
	int bottom = interlacing * ceilf((rect.origin.y+rect.size.height)/interlacedTileSize);
	return LayoutWindowMake(left, top, right, bottom);
	
}

-(void) setupVisibleRect:(CGRect)visibleRect interlacing:(int)interlacing
{
	//NSLog(@"-"); NSLog(@"setupVisibleRect:");
	
	LayoutWindow inclusiveWindow = [self inclusiveWindowForRect:visibleRect interlacing:interlacing];
	//NSLog(@"inclusiveWindow %@", LayoutWindowDescription(inclusiveWindow));
	if(LayoutWindowExceedsWindow(inclusiveWindow, maxLayoutWindow)) {
		//NSLog(@"inclusiveWindow %@", LayoutWindowDescription(inclusiveWindow));
		inclusiveWindow = maxLayoutWindow;
	}
	LayoutWindow renderingWindow = LayoutWindowShiftInsideWindow(inclusiveWindow, maxLayoutWindow);
	//NSLog(@"renderingWindow %@", LayoutWindowDescription(renderingWindow));
	
	if(!MeshLayoutContainsWindow(layout, renderingWindow)) {
		[self extendLayoutForWindow:renderingWindow];
	}
	
	int width = inclusiveWindow.right - inclusiveWindow.left;
	int height = inclusiveWindow.bottom - inclusiveWindow.top;

	if(width > indicesWindowWidth || height > indicesWindowHeight || indicesBuildedForLayoutWidth!=layout.width || interlacing!=indicesInterlacing)
	{
		[self rebuildIndicesForWindowWidth:width height:height interlacing:interlacing];
	}
	
	int offsetX = renderingWindow.left-layout.x;
	if(offsetX+indicesWindowWidth > layout.width) {
		offsetX = layout.width - indicesWindowWidth;
		NSAssert(offsetX>=0, @"");
	}
	int offsetY = renderingWindow.top-layout.y;
	if(offsetY+indicesWindowHeight > layout.height) {
		offsetY = layout.height - indicesWindowHeight;
		NSAssert(offsetY>=0, @"");
	}

	//NSLog(@"offsetX:%d offsetY:%d", offsetX, offsetY);
	
	vertOffset = ( offsetY*(layout.width+1) + offsetX )*2;
	vertStride = interlacing*sizeof(GLshort)*2;
	vectorsStride = interlacing*sizeof(GLfloat)*2;
}

-(void) setupVisibleRect:(CGRect)visibleRect scale:(CGFloat)scale
{
	int interlacing = [[self class] interlacingForScale:scale];
	[self setupVisibleRect:visibleRect interlacing:interlacing];
}


-(void) rebuildIndicesForWindowWidth:(int)windowWidth height:(int)windowHeight interlacing:(int)interlacing
{
	NSAssert( !(windowWidth%interlacing) && !(windowHeight%interlacing), @"Invalid window ");

	int interlacedLayoutWidth = windowWidth/interlacing;
	int interlacedLayoutHeight = windowHeight/interlacing;

	int maxIndex = interlacedLayoutHeight*(layout.width+1) + interlacedLayoutWidth;
	NSLog(@"rebuildIndicesForWindowWidth:%d height:%d interlacing:%d (maxIndex %d) ", windowWidth, windowHeight, interlacing, maxIndex);

	int maxHeight = (USHRT_MAX-interlacedLayoutWidth)/(layout.width+1);
	if(maxHeight < interlacedLayoutHeight) {
		int maxIndexLimited = maxHeight*(layout.width+1)+interlacedLayoutWidth;
		NSAssert(maxIndexLimited <= USHRT_MAX, @"");
		interlacedLayoutHeight = maxHeight;
		NSLog(@"maxIndexLimited %d", maxIndexLimited);
	}
	
	
	if(indices)
		free(indices);
	
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
	
	indicesWindowWidth = windowWidth;
	indicesWindowHeight = windowHeight;
	indicesBuildedForLayoutWidth = layout.width;
	indicesInterlacing = interlacing;

	/*
	if(indicesBackup) free(indicesBackup);
	indicesBackup = malloc(indexCount*sizeof(GLushort));
	memcpy(indicesBackup, indices, indexCount*sizeof(GLushort));
	*/ 
}

-(void) rebuildVertices
{
	if(vertices)
		free(vertices);
	
	vertNum = (layout.width+1)*(layout.height+1);
	vertices = (GLshort*)malloc(vertNum*2*sizeof(GLshort));
	GLshort* vertPtr = vertices;
	
	for(int i=0; i<=layout.height; i++)
	{
		for(int j=0; j<=layout.width; j++)
		{
			*vertPtr++ = (layout.x+j)*tileSize;
			*vertPtr++ = (layout.y+i)*tileSize;
		}
	}
	
	[self checkVertices];
}

-(void) checkVertices
{
	GLshort* vertPtr = vertices;
	for(int i=0; i<=layout.height; i++)
	{
		for(int j=0; j<=layout.width; j++)
		{
			CGFloat x = (layout.x+j)*tileSize;
			CGFloat y = (layout.y+i)*tileSize;
			NSAssert( vertPtr[0]==x && vertPtr[1]==y, @"Invalid vertices");
			vertPtr+=2;
		}
	}
}

-(void) checkVerticesForIndices
{
	GLshort* pVertEnd = vertices + vertNum*2;
	for(int i=0; i<indexCount; i++)
	{
		int vertIndex = indices[i];
		GLshort* p = vertices + vertOffset + vertIndex*vertStride;
		NSAssert(p>=vertices && p<pVertEnd, @"Invalid indices");
	}
}












-(void) rebuildTextureCoordinates_deprecated
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
			NSAssert(fabs(coordPtr[0]-x) < 0.0001 && fabs(coordPtr[1]-y) < 0.0001, @"Invalid vDSP processing");
			*coordPtr++ = x;
			*coordPtr++ = y;
		}
	}
#endif
	
}

-(void) rebuildIndices_deprecated
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

/*
-(void) checkMemory
{
	for(int i=0; i<indexCount; i++) {
		NSAssert(indices[i]==indicesBackup[i], @"checkMemory failed");
	}
}
*/

-(void) interlaceIndices_deprecated:(int)interlacing
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





























