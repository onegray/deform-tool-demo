//
//  TextureMesh.h
//  DeformTool
//
//  Created by onegray on 9/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MeshLayout.h"


struct PixelSize {
	int widthPixels;
	int heighPixels;
};
typedef struct PixelSize PixelSize;

CG_INLINE PixelSize PixelSizeMake(int width, int height)
{
	PixelSize size; size.widthPixels = width; size.heighPixels = height; return size;
}


struct LayoutRect {
	int x;
	int y;
	int width;
	int height;
};
typedef struct LayoutRect LayoutRect;








#define MAX_TEXTURE_TILE_SIZE 32


@interface TextureMesh : NSObject

@property (nonatomic, readonly) PixelSize textureSize;
@property (nonatomic, readonly) int tileSize;
@property (nonatomic, readonly) CGRect meshRect;
@property (nonatomic, readonly) GLfloat* coordinates;
@property (nonatomic, readonly) int coordNum;

@property (nonatomic, readonly) MeshLayout layout;

-(id) initWithTextureRect:(CGRect)textureRect meshLayout:(MeshLayout)meshLayout tileSize:(int)ts;

-(void) extendMeshLayout:(MeshLayout)newLayout;

-(void) resampleMeshForTileSize:(int)newTileSize;


+(void) test;
-(void) print;

@end
