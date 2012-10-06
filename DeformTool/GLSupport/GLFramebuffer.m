//
//  GLFramebuffer.m
//  DeformTool
//
//  Created by onegray on 10/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GLFramebuffer.h"
#import "GLTexture.h"

@interface GLFramebuffer()
{
	GLuint savedFBO;
	CGRect savedViewport;
	GLuint fbo;
	
	GLuint textureName;
	CGSize framebufferSize;
}
@end

@implementation GLFramebuffer
@synthesize textureName, framebufferSize;

-(id) initTextureFramebufferWithTexture:(GLTexture*)texture
{
	self = [super init];
	if(self) {
		framebufferSize = texture.textureSize;
		textureName = texture.textureName;
		fbo = [GLFramebuffer genFramebufferTexture2D:textureName];
	}
	return self;
}

-(id) initTextureFramebufferOfSize:(CGSize)textureSize
{
	self = [super init];
	if(self) {
		glGenTextures(1, &textureName);
		glBindTexture(GL_TEXTURE_2D, textureName);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		// This is necessary for non-power-of-two textures
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);		
		
		framebufferSize = textureSize;
		fbo = [GLFramebuffer genFramebufferTexture2D:textureName];
		
	}
	return self;
}


+ (GLuint) genFramebufferTexture2D:(GLuint)textureName
{
	GLint oldFBO = 0;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
	
	// generate FBO
	GLuint texFBO = 0;
	glGenFramebuffers(1, &texFBO);
	glBindFramebuffer(GL_FRAMEBUFFER, texFBO);
	
	// associate texture with FBO
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureName, 0);
	
	// check if it worked (probably worth doing :) )
	GLuint status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	if (status != GL_FRAMEBUFFER_COMPLETE) {
		[NSException raise:@"GLFramebuffer" format:@"Could not attach texture to framebuffer"];
	}
	
	glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
	
	return texFBO;
}

-(void) startRendering
{
	glGetFloatv(GL_VIEWPORT, (GLfloat*)&savedViewport);
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, (GLint*)&savedFBO);
	
	glBindFramebuffer(GL_FRAMEBUFFER, fbo);
	glViewport(0, 0, framebufferSize.width, framebufferSize.height);
}

-(void)endRendering
{
	glBindFramebuffer(GL_FRAMEBUFFER, savedFBO);
	glViewport(savedViewport.origin.x, savedViewport.origin.y, savedViewport.size.width, savedViewport.size.height);	
}



@end
