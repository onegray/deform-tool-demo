//
//  GLViewController.h
//  DeformTool
//
//  Created by onegray on 9/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "GLView.h"

@class GLTransformMatrix;

@interface GLViewController : NSObject

@property (nonatomic, strong) IBOutlet GLView* glView;

@property (nonatomic, readonly) GLTransformMatrix* projectionMatrix;
@property (nonatomic, assign) CGPoint scrollPos;
@property (nonatomic, assign) CGFloat scale;
-(void) setScale:(CGFloat)scale relativeToPoint:(CGPoint)p;

- (void) updateProjection;

- (void) setContext;
- (void) setFramebuffer;
- (BOOL) presentFramebuffer;
- (void) deleteFramebuffer;



@end
