//
//  GLFramebuffer.h
//  DeformTool
//
//  Created by onegray on 10/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLTexture;

@interface GLFramebuffer : NSObject

@property (nonatomic, readonly) GLuint textureName;
@property (nonatomic, readonly) CGSize framebufferSize;

-(id) initTextureFramebufferWithTexture:(GLTexture*)texture;
-(id) initTextureFramebufferOfSize:(CGSize)textureSize;
-(id) initFloatTextureFramebufferOfSize:(CGSize)textureSize;

-(void) startRendering;
-(void) endRendering;



-(UIImage*)getUIImage;
-(BOOL)saveImage:(NSString*)fileName;


@end
