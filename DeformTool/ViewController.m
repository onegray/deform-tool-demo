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
#import "GLTransformMatrix.h"

@interface ViewController ()
{
	GLTexture* texture;
		
	GLTransformMatrix* modelviewMatrix;
	GLTransformMatrix* resultMatrix;
	
	CGPoint touchBeginPoint;
	CGPoint scrollBeginPos;
	CGFloat scaleBeginValue;
}
@end

@implementation ViewController
@synthesize glController;


- (void)viewDidLoad
{
    [super viewDidLoad];

	[glController setContext];
	[glController setFramebuffer];

	if(!modelviewMatrix) {
		modelviewMatrix = [[GLTransformMatrix alloc] init];
		//[modelviewMatrix rotate:3.14/4 aroundPoint:CGPointMake(100, 100)];
	}

	resultMatrix = [[GLTransformMatrix alloc] init];
	[resultMatrix loadMultiplicationOfMatrix:glController.projectionMatrix byMatrix:modelviewMatrix];
	
	
	[GLRender loadSharedRender];
	
	if(!texture) {
		texture = [[GLTexture alloc] initWithImage:[UIImage imageNamed:@"nature"]];
	}

	
	UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchGesture:)];
	[glController.glView addGestureRecognizer:pinchRecognizer];
	
	
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
	textureRect = CGRectMake(0, 0, 250, 250);
	[[GLRender sharedRender] drawTexture:tex inRect:textureRect glMatrix:resultMatrix.glMatrix];
	
	[glController presentFramebuffer];  
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	[self performSelector:@selector(setupViewport) withObject:nil afterDelay:0];
	return YES;
}

-(void) setupViewport
{
	[resultMatrix loadMultiplicationOfMatrix:glController.projectionMatrix byMatrix:modelviewMatrix];
	[self drawTexture:texture];
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	touchBeginPoint = [touch locationInView:touch.view];
	scrollBeginPos = glController.scrollPos;
	scaleBeginValue = glController.scale;
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([touches count] > 1) {
		return;
	}
	
	UITouch* touch = [touches anyObject];
	CGPoint p = [touch locationInView:touch.view];

	CGPoint scrollPos = scrollBeginPos;
	scrollPos.x += p.x - touchBeginPoint.x;
	scrollPos.y += p.y - touchBeginPoint.y;
	glController.scrollPos = scrollPos;
	
	[resultMatrix loadMultiplicationOfMatrix:glController.projectionMatrix byMatrix:modelviewMatrix];
	[self drawTexture:texture];
}


-(void) onPinchGesture:(UIPinchGestureRecognizer*)gesture
{
	//CGPoint p = [gesture locationInView:gesture.view];
	//[glController setScale:scaleBeginValue*gesture.scale relativeToPoint:p];

	glController.scale = scaleBeginValue*gesture.scale;

	[resultMatrix loadMultiplicationOfMatrix:glController.projectionMatrix byMatrix:modelviewMatrix];
	[self drawTexture:texture];
}

@end






