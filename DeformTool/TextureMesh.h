//
//  TextureMesh.h
//  DeformTool
//
//  Created by onegray on 9/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


struct PixelSize {
	int widthPixels;
	int heighPixels;
};
typedef struct PixelSize PixelSize;


CG_INLINE PixelSize PixelSizeMake(int width, int height)
{
	PixelSize size; size.widthPixels = width; size.heighPixels = height; return size;
}


@interface TextureMesh : NSObject

-(id) initWithTextureSize:(PixelSize)ts;
-(void) buildInitialMeshWithTileSize:(int)ts;
-(void) extendMeshRect:(CGRect)newRect;
-(void) resampleMeshForTileSize:(int)newTileSize;

+(void) test;

@end
