//
//  GLTransformMatrix.h
//  DeformTool
//
//  Created by onegray on 9/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLTransformMatrix : NSObject

-(void) loadOrtho2D:(CGRect)rect;
-(void) loadMultiplicationOfMatrix:(GLTransformMatrix*)m1 byMatrix:(GLTransformMatrix*)m2;
-(GLfloat*) glMatrix;
-(CGPoint) convertPoint:(CGPoint)p;
-(void) translateTo:(CGPoint)p;
-(void) scaleTo:(CGFloat)f;
-(void) rotate:(CGFloat)angle aroundPoint:(CGPoint)p;
-(void) scale:(CGFloat)v relativeToPoint:(CGPoint)p;


@end
