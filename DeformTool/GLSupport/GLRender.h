//
//  GLRender.h
//  DeformTool
//
//  Created by onegray on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLProgram;
@class GLTexture;
@class LayerMesh;

@interface GLRender : NSObject


+(GLRender*) sharedRender;
+ (void) loadSharedRender;

- (void) drawTexture:(GLTexture*)texture inRect:(CGRect)rect transformMatrix:(CGAffineTransform)transform;

- (void) drawTexture:(GLTexture*)texture withMesh:(LayerMesh*)mesh transformMatrix:(CGAffineTransform)transform;

- (void) drawTexture:(GLTexture*)texture deformTexture:(GLTexture*)deformTexture inRect:(CGRect)rect transformMatrix:(CGAffineTransform)transform;

@end
