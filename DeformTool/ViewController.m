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

@interface ViewController ()
{
	GLTexture* texture;
		
	CGAffineTransform modelviewMatrix;
	CGAffineTransform resultTransform;

	CGAffineTransform transformAnchor;
	CGPoint pointAnchor;
	
	BOOL gestureInProgress;
	
	BOOL transformMode;
}
@end

@implementation ViewController
@synthesize glController;


- (void)viewDidLoad
{
    [super viewDidLoad];

	[glController setContext];
	[glController setFramebuffer];

	
	modelviewMatrix = CGAffineTransformIdentity;

	
	resultTransform = CGAffineTransformConcat(modelviewMatrix, glController.projectionMatrix);

	transformMode = NO;
	
	[GLRender loadSharedRender];
	
	if(!texture) {
		texture = [[GLTexture alloc] initWithImage:[UIImage imageNamed:@"nature"]];
	}

	
	UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(onPinchGesture:)];
	[glController.glView addGestureRecognizer:pinchRecognizer];
	
	UIRotationGestureRecognizer* rotateRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(onRotateGesture:)];
	[glController.glView addGestureRecognizer:rotateRecognizer];
	
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
	
	[[GLRender sharedRender] drawTexture:tex inRect:textureRect transformMatrix:resultTransform];
	
	[glController presentFramebuffer];  
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	[self performSelector:@selector(setupViewport) withObject:nil afterDelay:0];
	return YES;
}

-(void) setupViewport
{
	resultTransform = CGAffineTransformConcat(modelviewMatrix, glController.projectionMatrix);
	[self drawTexture:texture];
}


-(IBAction)onTransformModeBtn:(UISegmentedControl*)segmentedControl
{
	transformMode = segmentedControl.selectedSegmentIndex == 1;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	CGPoint p = [touch locationInView:touch.view];
	if(!transformMode) {
		[glController setTransformAnchor:p];
	} else {
		transformAnchor = modelviewMatrix;
		p = [glController convertPoint:p];
		pointAnchor = CGPointApplyAffineTransform(p, CGAffineTransformInvert(transformAnchor));
	}
	gestureInProgress = NO;
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([touches count] == 1 && !gestureInProgress)
	{
		UITouch* touch = [touches anyObject];
		CGPoint p = [touch locationInView:touch.view];
		
		if(!transformMode) {
			[glController scrollBy:p];
		} else {
			p = [glController convertPoint:p];
			p = CGPointApplyAffineTransform(p, CGAffineTransformInvert(transformAnchor));
			modelviewMatrix = CGAffineTransformTranslate(transformAnchor, p.x-pointAnchor.x, p.y-pointAnchor.y);
		}
		
		resultTransform = CGAffineTransformConcat(modelviewMatrix, glController.projectionMatrix);
		[self drawTexture:texture];
	}
}


-(void) onPinchGesture:(UIPinchGestureRecognizer*)gesture
{	
	CGPoint p = [gesture locationInView:gesture.view];
	
	if(!transformMode) {
		[glController scaleBy:gesture.scale relativeToPoint:p];
	} else {
		p = [glController convertPoint:p];
		p = CGPointApplyAffineTransform(p, CGAffineTransformInvert(transformAnchor));
		modelviewMatrix = CGAffineTransformTranslate(transformAnchor, p.x, p.y);
		modelviewMatrix = CGAffineTransformScale(modelviewMatrix, gesture.scale, gesture.scale);
		modelviewMatrix = CGAffineTransformTranslate(modelviewMatrix, -p.x, -p.y);
	}

	gestureInProgress = YES;
	resultTransform = CGAffineTransformConcat(modelviewMatrix, glController.projectionMatrix);
	[self drawTexture:texture];
}

-(void) onRotateGesture:(UIRotationGestureRecognizer*)gesture
{
	CGPoint p = [gesture locationInView:gesture.view];
	
	if(transformMode) {
		p = [glController convertPoint:p];
		p = CGPointApplyAffineTransform(p, CGAffineTransformInvert(transformAnchor));
		modelviewMatrix = CGAffineTransformTranslate(transformAnchor, p.x, p.y);
		modelviewMatrix = CGAffineTransformRotate(modelviewMatrix, gesture.rotation);
		modelviewMatrix = CGAffineTransformTranslate(modelviewMatrix, -p.x, -p.y);
	}
	
	gestureInProgress = YES;
	resultTransform = CGAffineTransformConcat(modelviewMatrix, glController.projectionMatrix);
	[self drawTexture:texture];
}


@end






