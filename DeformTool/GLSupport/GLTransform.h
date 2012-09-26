//
//  GLTransform.h
//  DeformTool
//
//  Created by onegray on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLTransform : NSObject

-(id) initWithOrtho2dRect:(CGRect)rect;

-(void) loadOrtho2dRect:(CGRect)rect;

-(CGPoint) convertPoint:(CGPoint)p;

-(void) rotate:(CGFloat)angle aroundPoint:(CGPoint)p;


@property (nonatomic, readonly) GLfloat* resultMatrix;


@end
