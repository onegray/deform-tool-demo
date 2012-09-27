//
//  ViewController.m
//  DeformTool
//
//  Created by onegray on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "GLViewController.h"
#import "GLTexture.h"
#import "GLRender.h"
#import "GLTransform.h"

@interface ViewController ()
{
	GLTexture* texture;
	
	GLTransform* glTransform;
}
@end

@implementation ViewController
@synthesize glController;


- (void)viewDidLoad
{
    [super viewDidLoad];

	[glController setContext];
	[glController setFramebuffer];
	
	[GLRender loadSharedRender];
	
	if(!glTransform) {
		glTransform = [[GLTransform alloc] initWithOrtho2dRect:glController.glView.bounds];
		
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
	glController.glView = nil;
}

-(CGRect) rectForTexture:(GLTexture*)tex
{
	CGRect r = glController.glView.bounds;
	CGSize vsz = glController.glView.bounds.size;
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
    [glController setFramebuffer];
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

	CGRect textureRect = [self rectForTexture:tex];
	//textureRect = CGRectMake(10, 10, 250, 250);
	[[GLRender sharedRender] drawTexture:tex inRect:textureRect withTransform:glTransform];
	
	[glController presentFramebuffer];  
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	[self performSelector:@selector(setupViewport) withObject:nil afterDelay:0];
	return YES;
}

-(void) setupViewport
{
	[glTransform loadOrtho2dRect:glController.glView.bounds];
	[self drawTexture:texture];
}


@end






