//
//  DeformTool.h
//  DeformTool
//
//  Created by onegray on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLTexture;
@interface DeformTool : NSObject

@property (nonatomic, readonly) GLuint deformTextureName;
@property (nonatomic, readonly) GLuint brushTextureName;

-(void) applyDeformVector:(CGPoint)force atPoint:(CGPoint)point;



@end
