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
@interface GLRender : NSObject

+ (void)loadBaseProgram;
+ (void) drawTexture:(GLTexture*)texture inRect:(CGRect)rect;
+ (GLProgram*) baseProgram;

@end
