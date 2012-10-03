//
//  TextureMesh.h
//  DeformTool
//
//  Created by onegray on 9/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MeshLayout.h"


#define MAX_TEXTURE_TILE_SIZE 32


@interface TextureMesh : NSObject

@property (nonatomic, readonly) CGRect textureRect;
@property (nonatomic, readonly) MeshLayout layout;
@property (nonatomic, readonly) GLfloat* coordinates;
@property (nonatomic, readonly) int coordNum;

-(id) initWithTextureRect:(CGRect)textureRect meshLayout:(MeshLayout)meshLayout;
-(void) extendMeshLayout:(MeshLayout)newLayout;
-(void) resampleMesh:(int)multiplier;


+(void) test;
-(void) print;

@end
