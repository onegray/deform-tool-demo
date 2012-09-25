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

@interface ViewController ()
{
	EAGLContext* context;
	
	GLTexture* texture;
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
	
	[GLRender loadBaseProgram];
	
	texture = [[GLTexture alloc] initWithImage:[UIImage imageNamed:@"nature"]];
	[self drawTexture:texture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	self.glView = nil;
}

-(CGRect) rectForTexture:(GLTexture*)tex
{
	CGRect r = CGRectMake(-1, -1, 2, 2);
	CGSize vsz = glView.bounds.size;
	CGFloat tk = tex.contentSize.width/tex.contentSize.height;
	CGFloat vk = vsz.width/vsz.height;
	if(vk>=tk) { // if viewport is 'wider' than texture image
		r.size.width =2*tk/vk;
		r.origin.x += (2 - r.size.width)/2;
	} else {
		r.size.height = 2*vk/tk;
		r.origin.y += (2 - r.size.height)/2;
	}
	return r;
}


-(void) drawTexture:(GLTexture*)tex
{
    [glView setFramebuffer];
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

	[GLRender drawTexture:tex inRect:[self rectForTexture:tex]];
	
	[glView presentFramebuffer];  
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	[self drawTexture:texture];
}

@end






