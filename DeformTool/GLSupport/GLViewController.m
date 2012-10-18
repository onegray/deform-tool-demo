//
//  GLViewController.m
//  DeformTool
//
//  Created by onegray on 9/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GLViewController.h"
#import "GLView.h"

@interface GLViewController()
{
	GLView* view;
	
	GLint framebufferWidth;
    GLint framebufferHeight;
    
    GLuint defaultFramebuffer, colorRenderbuffer;
	
	EAGLContext* context;
	
	CGAffineTransform projectionMatrix;
	CGAffineTransform ortho2DProjection;
	CGAffineTransform transform;
	CGAffineTransform transformAnchor;
	CGAffineTransform transformAnchorInverted;
	CGPoint pointAnchor;
}

@end

@interface GLView (private)
-(void) setGlController:(GLViewController *)glController;
@end


@implementation GLViewController
@synthesize projectionMatrix, transform;

-(id) init
{
	self = [super init];
	if(self) {
		projectionMatrix = CGAffineTransformIdentity;
		ortho2DProjection = CGAffineTransformIdentity;
		transform = CGAffineTransformIdentity;
	}
	return self;
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
	}
    [self deleteFramebuffer];    
}


-(void) loadView
{
	view = [[GLView alloc] initWithFrame:CGRectZero];
}

-(GLView*) glView
{
	if(!view) {
		[self loadView];
	}
	return view;
}

-(void) setGlView:(GLView *)glView
{
	if(view!=glView) {
		view = glView;
		[view setGlController:self];
		[self deleteFramebuffer];
	}
}


- (void)setContext:(EAGLContext *)newContext
{
    if (context != newContext) {
        [self deleteFramebuffer];
        context = newContext;
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)setContext
{
	if(!context) {
		EAGLContext* ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		NSAssert(ctx!=nil, @"Failed to create EAGLContext");
		[self setContext:ctx];
	}
}


- (void)createFramebuffer
{
    if (context && !defaultFramebuffer) {
        [EAGLContext setCurrentContext:context];
        
        // Create default framebuffer object.
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        // Create color render buffer and allocate backing store.
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)view.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)deleteFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer) {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer) {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
    }
}

- (void)setFramebuffer
{
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        if (!defaultFramebuffer)
            [self createFramebuffer];
        
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        glViewport(0, 0, framebufferWidth, framebufferHeight);
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (context) {
        [EAGLContext setCurrentContext:context];
        
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        success = [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

-(CGAffineTransform) loadOrtho2DProjection
{
	CGSize boundsSize = view.bounds.size;
	return CGAffineTransformMake(2.0f/boundsSize.width, 0.0, 0.0, -2.0f/boundsSize.height, -1.0f, 1.0f);
}

-(void) updateProjection
{
	ortho2DProjection = [self loadOrtho2DProjection];
	projectionMatrix = CGAffineTransformConcat(transform, ortho2DProjection);
}

- (CGPoint) convertPoint:(CGPoint)p
{
	return CGPointApplyAffineTransform(p, CGAffineTransformInvert(transform));
}

-(void) scrollBy:(CGPoint)p
{
	p = CGPointApplyAffineTransform(p, transformAnchorInverted);
	transform = CGAffineTransformTranslate(transformAnchor, p.x-pointAnchor.x, p.y-pointAnchor.y);
	projectionMatrix = CGAffineTransformConcat(transform, ortho2DProjection);
}

-(void) scaleBy:(CGFloat)v relativeToPoint:(CGPoint)p
{
	p = CGPointApplyAffineTransform(p, transformAnchorInverted);
	transform = CGAffineTransformTranslate(transformAnchor, p.x, p.y);
	transform = CGAffineTransformScale(transform, v, v);
	transform = CGAffineTransformTranslate(transform, -p.x, -p.y);
	projectionMatrix = CGAffineTransformConcat(transform, ortho2DProjection);
}

-(void) setTransformAnchor:(CGPoint)p
{
	transformAnchor = transform;
	transformAnchorInverted = CGAffineTransformInvert(transformAnchor);
	pointAnchor = CGPointApplyAffineTransform(p, transformAnchorInverted);
}

@end


























