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

-(void) satisfyVisibleRect:(CGRect)visibleRect;

@property (nonatomic, readonly) GLfloat* vertices;
@property (nonatomic, readonly) GLfloat* vectors;
@property (nonatomic, readonly) int vertNum;

@property (nonatomic, readonly) GLushort* indices;
@property (nonatomic, readonly) int indexCount;

@property (nonatomic, readonly) GLfloat* texCoords;
@property (nonatomic, readonly) int texCoordNum;

@property (nonatomic, readonly) MeshLayout layout;
@property (nonatomic, readonly) int tileSize;
@property (nonatomic, readonly) PixelSize textureContentSize;

@end
