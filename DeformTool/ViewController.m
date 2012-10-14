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

#import "LayerMesh.h"
#import "DeformTool.h"

enum  {
	MODE_SCROLL,
	MODE_TRANSFORM,
	MODE_DEFORM,
};


@interface ViewController ()
{
	GLTexture* texture;
	LayerMesh* mesh;
		
	CGAffineTransform modelviewMatrix;
	CGAffineTransform resultTransform;

	CGAffineTransform transformAnchor;
	CGPoint pointAnchor;
	
	BOOL gestureInProgress;
	
	//BOOL transformMode;
	int mode;
	
	DeformTool* deformTool;
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

	mode = MODE_SCROLL;
	
	[GLRender loadSharedRender];
	
	deformTool = [[DeformTool alloc] init];
	
	[deformTool applyDeformVector:CGPointMake(20.0, 0.0) atPoint:CGPointMake(100, 150)];
	//[deformTool applyDeformVector:CGPointMake(10.0, 0.0) atPoint:CGPointMake(100, 150)];

	
	[deformTool applyDeformVector:CGPointMake(1.0, 0.0) atPoint:CGPointMake(100, 200)];
	[deformTool applyDeformVector:CGPointMake(1.0, 0.0) atPoint:CGPointMake(100, 200)];

	
	if(!texture) {
		texture = [[GLTexture alloc] initWithImage:[UIImage imageNamed:@"table"]];
		//mesh = [[LayerMesh alloc] initWithTextureSize:PixelSizeMake(texture.contentSize.width, texture.contentSize.height)];
		mesh = [[LayerMesh alloc] initWithTextureSize:PixelSizeMake(352, 288)];
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

	
	//[[GLRender sharedRender] drawTextureName:deformTool.deformTextureName inRect:CGRectMake(-1, -1, 2, 2)];
	
	//[[GLRender sharedRender] drawTextureName:tex.textureName inRect:CGRectMake(-1, -1, 2, 2)];
	//[[GLRender sharedRender] drawTexture:tex withMesh:mesh transformMatrix:resultTransform];
	
	CGRect textureRect = CGRectMake(0, 0, 256, 256);
	[[GLRender sharedRender] drawTexture:tex deformTexture:deformTool.deformTextureName inRect:textureRect transformMatrix:resultTransform];

	
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
	mode = segmentedControl.selectedSegmentIndex;
	if(mode==MODE_TRANSFORM) {
		mode = MODE_DEFORM;
	}
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch* touch = [touches anyObject];
	CGPoint pos = [touch locationInView:touch.view];
	//CGPoint prev_pos = [touch previousLocationInView:touch.view];

	if(mode==MODE_SCROLL)
	{
		[glController setTransformAnchor:pos];
	}
	else if(mode==MODE_TRANSFORM)
	{
		transformAnchor = modelviewMatrix;
		pos = [glController convertPoint:pos];
		pointAnchor = CGPointApplyAffineTransform(pos, CGAffineTransformInvert(transformAnchor));
	}
	
	gestureInProgress = NO;
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if([touches count] == 1 && !gestureInProgress)
	{
		UITouch* touch = [touches anyObject];
		CGPoint pos = [touch locationInView:touch.view];
		CGPoint prev_pos = [touch previousLocationInView:touch.view];
		
		if(mode==MODE_SCROLL)
		{
			[glController scrollBy:pos];
		}
		else if(mode==MODE_TRANSFORM)
		{
			pos = [glController convertPoint:pos];
			pos = CGPointApplyAffineTransform(pos, CGAffineTransformInvert(transformAnchor));
			modelviewMatrix = CGAffineTransformTranslate(transformAnchor, pos.x-pointAnchor.x, pos.y-pointAnchor.y);
		}
		else if(mode==MODE_DEFORM)
		{
			CGPoint p = [glController convertPoint:prev_pos];
			CGPoint v = [glController convertPoint:pos];
			CGFloat l, dx, dy, xf, yf;
			int deformAreaRadius = 64/2;
			
			dx = p.x - v.x;
			dy = p.y - v.y;
			l= sqrt (dx * dx + dy * dy);
			int num = (int) (l * 2 / deformAreaRadius) + 1;
			dx /= num;
			dy /= num;
			xf = v.x + dx; yf = v.y + dy;
			
			for (int i=0; i< num; i++)
			{
				int x0 = (int) xf;
				int y0 = (int) yf;
				
				[deformTool applyDeformVector:CGPointMake(dx, dy) atPoint:CGPointMake(x0, y0)];
				
				xf += dx;
				yf += dy;
			}
			
		}
		
		resultTransform = CGAffineTransformConcat(modelviewMatrix, glController.projectionMatrix);
		[self drawTexture:texture];
	}
}


-(void) onPinchGesture:(UIPinchGestureRecognizer*)gesture
{	
	CGPoint p = [gesture locationInView:gesture.view];
	
	if(mode==MODE_SCROLL)
	{
		[glController scaleBy:gesture.scale relativeToPoint:p];
	}
	else if(mode==MODE_TRANSFORM)
	{
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
	
	if(mode==MODE_TRANSFORM)
	{
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






