//
//  DeformTool+TextureMesh.h
//  DeformTool
//
//  Created by onegray on 10/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeformTool.h"

@interface DeformTool (TextureMesh)

-(void) initDeformTextures;

@property (nonatomic, readonly) GLuint deformTextureName;
@property (nonatomic, readonly) GLuint brushTextureName;

-(void) applyDeformVector:(CGPoint)force atPoint:(CGPoint)point;


@end
