//
//  LayerMesh.h
//  DeformTool
//
//  Created by onegray on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TextureMesh.h"


struct PixelSize {
	int widthPixels;
	int heighPixels;
};
typedef struct PixelSize PixelSize;

CG_INLINE PixelSize PixelSizeMake(int width, int height)
{
	PixelSize size; size.widthPixels = width; size.heighPixels = height; return size;
}


@interface LayerMesh : NSObject

-(id) initWithTextureSize:(PixelSize)ts;

-(void) setupVisibleRect:(CGRect)visibleRect interlacing:(int)interlacing;
-(void) setupVisibleRect:(CGRect)visibleRect scale:(CGFloat)scale;

//@property (nonatomic, readonly) GLshort* vertices;
//@property (nonatomic, readonly) GLfloat* vectors;
@property (nonatomic, readonly) GLfloat* vectorsAbsolutePointer;
@property (nonatomic, readonly) int vertNum;

//@property (nonatomic, readonly) GLushort* indices;
//@property (nonatomic, readonly) int indexCount;

//@property (nonatomic, readonly) GLfloat* texCoords;

@property (nonatomic, readonly) int vertStride;
@property (nonatomic, readonly) int vectorsStride;

@property (nonatomic, readonly) NSArray* subMeshes;


@property (nonatomic, readonly) MeshLayout layout;
@property (nonatomic, readonly) int tileSize;
@property (nonatomic, readonly) int interlacing;
@property (nonatomic, readonly) int interlacedTileSize;
@property (nonatomic, readonly) PixelSize textureContentSize;


-(void) checkVertices;
//-(void) checkVerticesForIndices;

@end



@interface SubMesh : NSObject
@property (nonatomic, assign) GLshort* vertices;
@property (nonatomic, assign) GLfloat* vectors;
@property (nonatomic, assign) GLushort* indices;
@property (nonatomic, assign) int indexCount;

@end
