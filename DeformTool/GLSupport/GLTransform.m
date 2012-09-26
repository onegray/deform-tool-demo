//
//  GLTransform.m
//  DeformTool
//
//  Created by onegray on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GLTransform.h"

#import "matrix.h"
#import "TransformUtils.h"


@interface GLTransform()
{
	GLfloat projection[16];
	GLfloat modelview[16];
	GLfloat modelviewProjection[16];
	
	CGAffineTransform affineTransform;
}
@end


@implementation GLTransform

-(id) initWithOrtho2dRect:(CGRect)rect
{
	self = [super init];
	if(self) {
		affineTransform = CGAffineTransformIdentity;
		mat4f_LoadIdentity(modelview);
		[self loadOrtho2dRect:rect];
	}
	return self;
}

-(void) loadOrtho2dRect:(CGRect)rect
{
	mat4f_LoadOrtho(rect.origin.x, rect.origin.x+rect.size.width,
					rect.origin.y, rect.origin.y+rect.size.height,
					-1, 1, projection);
	mat4f_MultiplyMat4f(projection, modelview, modelviewProjection);
}

-(GLfloat*) resultMatrix
{
	return modelviewProjection;
}

-(void) setAffineTransform:(const CGAffineTransform)transform
{
	affineTransform = transform;
	CGAffineToGL(&transform, modelview);
	mat4f_MultiplyMat4f(projection, modelview, modelviewProjection);
}

-(CGPoint) convertPoint:(CGPoint)p
{
	CGAffineTransform t = CGAffineTransformInvert(affineTransform);
	return CGPointApplyAffineTransform(p, t);
}

-(void) rotate:(CGFloat)angle aroundPoint:(CGPoint)p
{
	p = [self convertPoint:p];
	
	CGAffineTransform transform = CGAffineTransformTranslate(affineTransform, p.x, p.y);
	transform = CGAffineTransformRotate(transform, angle);
	transform = CGAffineTransformTranslate(transform, -p.x, -p.y);

	[self setAffineTransform:transform];
}


@end
