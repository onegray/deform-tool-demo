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
#import "IndexMeshCache.h"


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
	
	int indexMeshHeight;
	
	//int vertOffset;
	
	NSMutableArray* subMeshes;
	
	DeformVectors* deformVectors;
}

@property (nonatomic, retain) IndexMesh* indexMesh;
@property (nonatomic, retain) IndexMeshCache* indexMeshCache;

@end


@implementation LayerMesh
//@synthesize vertices, vectors;
@synthesize vertNum;
//@synthesize indices, indexCount;
@synthesize layout, tileSize, textureContentSize;
@synthesize vertStride, vectorsStride;
@synthesize indexMesh, indexMeshCache;
@synthesize interlacing = _interlacing;

-(id) initWithTextureSize:(PixelSize)ts
{
	self = [super init];
	if(self) {
		NSAssert( ts.widthPixels % MAX_TEXTURE_TILE_SIZE == 0, @"");
		NSAssert( ts.heighPixels % MAX_TEXTURE_TILE_SIZE == 0, @"");
		
		tileSize = 4;
		//maxLayoutWindow = LayoutWindowMake(-120, -120, 240+120, 240+120);
		maxLayoutWindow = LayoutWindowMake(-120*8, -120*8, 120*8, 120*8);
		textureContentSize = ts;
		layout = MeshLayoutMake(0, 0, ts.widthPixels/tileSize, ts.heighPixels/tileSize);
		textureCoordinateRect = CGRectMake(0, 0, 1, 1);
		textureWidth1px = (double)textureCoordinateRect.size.width / textureContentSize.widthPixels;
		textureHeight1px = (double)textureCoordinateRect.size.height / textureContentSize.heighPixels;
		
		deformVectors = [[DeformVectors alloc] initWithLayout:layout];
				
		subMeshes = [[NSMutableArray alloc] initWithCapacity:4];
		
		[self rebuildVertices];
		[self setupVisibleRect:CGRectMake(0, 0, ts.widthPixels, ts.heighPixels) interlacing:1];
		
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

/*
-(GLfloat*) vectors
{
	return deformVectors.vectors + vertOffset;
}

-(GLshort*) vertices
{
	return vertices + vertOffset;
}

-(GLushort*) indices
{
	return indexMesh.indices;
}

-(int) indexCount
{
	//return indexMesh.indexCount;
	return [indexMesh indexCountForMeshHeight:indexMeshHeight];
}
 
-(GLfloat*) texCoords
{
	return textureCoordinates + vertOffset;
}
 */

 
-(int) interlacedTileSize
{
	return _interlacing*tileSize;
}

-(NSArray*) subMeshes
{
	return subMeshes;
}

-(void) extendLayoutForWindow:(LayoutWindow)window
{
	NSLog(@"extendLayoutForWindow %@", LayoutWindowDescription(window));
	
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
		self.indexMeshCache = [[IndexMeshCache alloc] initWithLayerLayout:layout];
	}
	
	if(!self.indexMeshCache) {
		self.indexMeshCache = [[IndexMeshCache alloc] initWithLayerLayout:layout];
	}
	
	int width = inclusiveWindow.right - inclusiveWindow.left;
	int height = inclusiveWindow.bottom - inclusiveWindow.top;

	NSAssert( !(width%interlacing) && !(height%interlacing), @"Invalid index window");
	int interlacedWidth = width/interlacing;
	int interlacedHeight = height/interlacing;
	NSAssert(interlacedWidth <= layout.width && interlacedHeight <= layout.height, @"Invalid index window");


	/*
	self.indexMesh = [indexMeshCache meshForWidth:interlacedWidth];
	indexMeshHeight = MIN(interlacedHeight, indexMesh.height);
	
	int offsetX = renderingWindow.left-layout.x;
	if(offsetX+indexMesh.width*interlacing > layout.width) {
		offsetX = layout.width - indexMesh.width*interlacing;
		NSAssert(offsetX>=0, @"");
	}
	
	int offsetY = renderingWindow.top-layout.y;
	if(offsetY+indexMeshHeight*interlacing > layout.height) {
		indexMeshHeight = (layout.height - offsetY)/interlacing;
	}

	vertOffset = ( offsetY*(layout.width+1) + offsetX )*2;
	vertStride = interlacing*sizeof(GLshort)*2;
	vectorsStride = interlacing*sizeof(GLfloat)*2;
	_interlacing = interlacing;
	*/
	
	self.indexMesh = [indexMeshCache meshForWidth:interlacedWidth];
	
	int offsetX = renderingWindow.left-layout.x;
	if(offsetX+indexMesh.width*interlacing > layout.width) {
		offsetX = layout.width - indexMesh.width*interlacing;
		NSAssert(offsetX>=0, @"");
	}

	int offsetY = renderingWindow.top-layout.y;
	if(offsetY+interlacedHeight*interlacing > layout.height) {
		interlacedHeight = (layout.height - offsetY)/interlacing;
	}


	int h = interlacedHeight;
	[subMeshes removeAllObjects];
	while (h > 0) {

		int subMeshHeight = MIN(h, indexMesh.height);
		int vertOffset = ( offsetY*(layout.width+1) + offsetX )*2;
		
		SubMesh* sm = [[SubMesh alloc] init];
		sm.vertices = vertices + vertOffset;
		sm.vectors = deformVectors.vectors + vertOffset;
		sm.indices = indexMesh.indices;
		sm.indexCount = [indexMesh indexCountForMeshHeight:subMeshHeight];
		[subMeshes addObject:sm];

		offsetY += subMeshHeight*interlacing;
		h -= subMeshHeight;
	}
	
	vertStride = interlacing*sizeof(GLshort)*2;
	vectorsStride = interlacing*sizeof(GLfloat)*2;
	_interlacing = interlacing;
}

-(void) setupVisibleRect:(CGRect)visibleRect scale:(CGFloat)scale
{
	int interlacing = [[self class] interlacingForScale:scale];
	[self setupVisibleRect:visibleRect interlacing:interlacing];
}

/*
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
}
*/

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

/*
-(void) checkVerticesForIndices
{
	GLshort* pVertEnd = vertices + vertNum*2;
	int indexCount = [self indexCount];
	for(int i=0; i<indexCount; i++)
	{
		int vertIndex = indexMesh.indices[i];
		GLshort* p = vertices + vertOffset + vertIndex*vertStride;
		NSAssert(p>=vertices && p<pVertEnd, @"Invalid indices");
	}
}
*/











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

/*
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
*/

/*
-(void) checkMemory
{
	for(int i=0; i<indexCount; i++) {
		NSAssert(indices[i]==indicesBackup[i], @"checkMemory failed");
	}
}
*/


@end

@implementation SubMesh



@end



























