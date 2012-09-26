//
//  ViewController.m
//  DeformTool
//
//  Created by onegray on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "EAGLView.h"
#import "GLTexture.h"
#import "GLRender.h"
#import "GLTransform.h"

@interface ViewController ()
{
	EAGLContext* context;
	
	GLTexture* texture;
	
	GLTransform* glTransform;
}
@end

@implementation ViewController
@synthesize glView;

- (void)dealloc {
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
	}
}


- (void)viewDidLoad
{
    [super viewDidLoad];

	if(!context) {
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		NSAssert(context!=nil, @"Failed to create EAGLContext");
	}
	
	[glView setContext:context];
	[glView setFramebuffer];
	
	[GLRender loadSharedRender];
	
	if(!glTransform) {
		glTransform = [[GLTransform alloc] initWithOrtho2dRect:glView.bounds];
		
		//[glTransform rotate:0.2 aroundPoint:glView.center];
	}

	if(!texture) {
		texture = [[GLTexture alloc] initWithImage:[UIImage imageNamed:@"nature"]];
	}
	
	[self drawTexture:texture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.glView = nil;
}

-(CGRect) rectForTexture:(GLTexture*)tex
{
	CGRect r = glView.bounds;
	CGSize vsz = glView.bounds.size;
	CGFloat tk = tex.contentSize.width/tex.contentSize.height;
	CGFloat vk = vsz.width/vsz.height;
	if(vk>=tk) { // if viewport is 'wider' than texture image
		r.size.width =r.size.height*tk;
		r.origin.x += (vsz.width - r.size.width)/2;
	} else {
		r.size.height = r.size.width/tk;
		r.origin.y += (vsz.height - r.size.height)/2;
	}
	return r;
}


-(void) drawTexture:(GLTexture*)tex
{
    [glView setFramebuffer];
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

	CGRect textureRect = [self rectForTexture:tex];
	[[GLRender sharedRender] drawTexture:tex inRect:textureRect withTransform:glTransform];
	
	[glView presentFramebuffer];  
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	[self performSelector:@selector(setupViewport) withObject:nil afterDelay:0];
	return YES;
}

-(void) setupViewport
{
	[glTransform loadOrtho2dRect:glView.bounds];
	[self drawTexture:texture];
}


@end






