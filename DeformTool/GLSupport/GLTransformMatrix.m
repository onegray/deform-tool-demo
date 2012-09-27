//
//  GLTransformMatrix.m
//  DeformTool
//
//  Created by onegray on 9/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GLTransformMatrix.h"

#import "matrix.h"
#import "TransformUtils.h"

@implementation GLTransformMatrix
{
	GLfloat matrix[16];
	CGAffineTransform affineTransform;
}

-(id) init
{
	self = [super init];
	if(self) {
		affineTransform = CGAffineTransformIdentity;
		mat4f_LoadIdentity(matrix);
	}
	return self;
}

-(void) loadOrtho2D:(CGRect)rect
{
	mat4f_LoadOrtho(rect.origin.x, rect.origin.x+rect.size.width,
					rect.origin.y+rect.size.height, rect.origin.y,
					-1, 1, matrix);
	GLToCGAffine(matrix, &affineTransform);
}

-(void) loadMultiplicationOfMatrix:(GLTransformMatrix*)m1 byMatrix:(GLTransformMatrix*)m2
{
	mat4f_MultiplyMat4f(m1->matrix, m2->matrix, self->matrix);
	GLToCGAffine(matrix, &affineTransform);
}

-(GLfloat*) glMatrix
{
	return matrix;
}

-(void) setAffineTransform:(const CGAffineTransform)transform
{
	affineTransform = transform;
	CGAffineToGL(&transform, matrix);
}

-(CGPoint) convertPoint:(CGPoint)p
{
	CGAffineTransform t = CGAffineTransformInvert(affineTransform);
	return CGPointApplyAffineTransform(p, t);
}

-(void) translateTo:(CGPoint)p
{
	CGAffineTransform t = CGAffineTransformTranslate(affineTransform, p.x, p.y);
	[self setAffineTransform:t];
}

-(void) scaleTo:(CGFloat)f
{
	CGAffineTransform t = CGAffineTransformScale(affineTransform, f, f);
	[self setAffineTransform:t];
}

-(void) rotate:(CGFloat)angle aroundPoint:(CGPoint)p
{
	p = [self convertPoint:p];
	CGAffineTransform t = CGAffineTransformTranslate(affineTransform, p.x, p.y);
	t = CGAffineTransformRotate(t, angle);
	t = CGAffineTransformTranslate(t, -p.x, -p.y);
	[self setAffineTransform:t];
}

-(void) scale:(CGFloat)v relativeToPoint:(CGPoint)p
{
	//p = [self convertPoint:p];
	CGAffineTransform t = CGAffineTransformTranslate(affineTransform, p.x, p.y);
	t = CGAffineTransformScale(t, v, v);
	t = CGAffineTransformTranslate(t, -p.x, -p.y);
	[self setAffineTransform:t];
}


@end
