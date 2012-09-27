//
//  GLView.m
//  DeformTool
//
//  Created by onegray on 9/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GLView.h"
#import "GLViewController.h"

@interface GLView ()
{
	__unsafe_unretained GLViewController* controller;
}
@end

@implementation GLView


+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

-(void) initialize
{
	CAEAGLLayer* eaglLayer = (CAEAGLLayer*)self.layer;
	
	eaglLayer.opaque = TRUE;
	eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
									kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
									nil];
	
	if(self.contentScaleFactor==1.0) {
		//self.contentScaleFactor = 2.0;
	}
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(GLViewController*) glController
{
	return controller;
}

-(void) layoutSubviews
{
	[controller updateProjection]; // since bounds are changed
	[controller deleteFramebuffer];
}

@end


@interface GLView (private)
-(void) setGlController:(GLViewController *)glController;
@end

@implementation GLView (private)

-(void) setGlController:(GLViewController *)glController
{
	controller = glController;
}

@end


