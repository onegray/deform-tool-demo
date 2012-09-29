//
//  LayerMesh.m
//  DeformTool
//
//  Created by onegray on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LayerMesh.h"
#import "TextureMesh.h"

@interface LayerMesh()
{
	TextureMesh* texMesh;
}
@end


@implementation LayerMesh


-(void) buildMeshForVertexRect:(CGRect)vertexRect layoutSize:(LayoutSize)layoutSize tileSize:(int)tileSize
{
	//NSAssert( tileSize > 0 && tileSize <= MAX_TEXTURE_TILE_SIZE && IS_POT(tileSize), @"");

	// vertexRect must be aligned to vertex grid
	//NSAssert( layoutSize.width % MAX_TEXTURE_TILE_SIZE == 0, @"");
	//NSAssert( layoutSize.height % MAX_TEXTURE_TILE_SIZE == 0, @"");

	
	
	
	
}






@end
