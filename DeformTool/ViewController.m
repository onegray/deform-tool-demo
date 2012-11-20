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
	
	if(!texture) {
		texture = [[GLTexture alloc] initWithImage:[UIImage imageNamed:@"nature"]];
		mesh = [[LayerMesh alloc] initWithTextureSize:PixelSizeMake(352, 288)];

		//texture = [[GLTexture alloc] initWithImage:[UIImage imageNamed:@"table"]];
		//mesh = [[LayerMesh alloc] initWithTextureSize:PixelSizeMake(256, 256)];
	}

	deformTool = [[DeformTool alloc] initWithMesh:mesh];

	
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

	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);
	
	[[GLRender sharedRender] drawTexture:tex withMesh:mesh transformMatrix:resultTransform];
	//if(mode==MODE_DEFORM)
	{
		[[GLRender sharedRender] drawMesh:mesh transformMatrix:resultTransform];
	}

	//[[GLRender sharedRender] drawTextureName:tex.textureName inRect:CGRectMake(-1, -1, 2, 2)];
	
	//[[GLRender sharedRender] drawTexture:tex deformTexture:deformTool.deformTextureName inRect:CGRectMake(0, 0, 256, 256) transformMatrix:resultTransform];
	
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

-(CGRect) modelVisibleRect
{
	CGAffineTransform t = CGAffineTransformInvert(CGAffineTransformConcat(modelviewMatrix, glController.transform));
	return CGRectApplyAffineTransform(glController.glView.bounds, t);
}

-(CGFloat) modelScale
{
	CGAffineTransform t = CGAffineTransformInvert(CGAffineTransformConcat(modelviewMatrix, glController.transform));
	CGRect r = CGRectApplyAffineTransform(CGRectMake(0, 0, 100, 100), t);
	return r.size.width/100;
}

-(IBAction)onTransformModeBtn:(UISegmentedControl*)segmentedControl
{
	mode = segmentedControl.selectedSegmentIndex;
	
	[self drawTexture:texture];
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
			resultTransform = CGAffineTransformConcat(modelviewMatrix, glController.projectionMatrix);
			
			CGRect visibleRect = [self modelVisibleRect];
			CGFloat scale = [self modelScale];
			[mesh setupVisibleRect:visibleRect scale:scale*1.5];
		}
		else if(mode==MODE_TRANSFORM)
		{
			pos = [glController convertPoint:pos];
			pos = CGPointApplyAffineTransform(pos, CGAffineTransformInvert(transformAnchor));
			modelviewMatrix = CGAffineTransformTranslate(transformAnchor, pos.x-pointAnchor.x, pos.y-pointAnchor.y);
			resultTransform = CGAffineTransformConcat(modelviewMatrix, glController.projectionMatrix);
			
			CGRect visibleRect = [self modelVisibleRect];
			[mesh setupVisibleRect:visibleRect interlacing:2];
		}
		else if(mode==MODE_DEFORM)
		{
			CGAffineTransform t = CGAffineTransformInvert(CGAffineTransformConcat(modelviewMatrix, glController.transform));
			CGPoint p0 = CGPointApplyAffineTransform(prev_pos, t);
			CGPoint p1 = CGPointApplyAffineTransform(pos, t);
			
			CGFloat l, dx, dy, xf, yf;
			int deformAreaRadius = 64/2;
			
			dx = p0.x - p1.x;
			dy = p0.y - p1.y;
			l= sqrt (dx * dx + dy * dy);
			int num = (int) (l * 2 / deformAreaRadius) + 1;
			dx /= num;
			dy /= num;
			xf = p1.x + dx; yf = p1.y + dy;
			
			for (int i=0; i< num; i++)
			{
				//[deformTool applyDeformVector:CGPointMake(dx, dy) atPoint:CGPointMake((int)xf, (int)yf)];

				[deformTool applyMoveDeformVector:CGPointMake(dx, dy) atPoint:CGPointMake(xf, yf)];
				//[deformTool applyMoveDeformVector:CGPointMake(dx, dy) atPoint:CGPointMake((int)xf, (int)yf)];

				xf += dx;
				yf += dy;
			}
			
		}
		
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






