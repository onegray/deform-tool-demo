//
//  DeformTool.m
//  DeformTool
//
//  Created by onegray on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeformTool.h"
#import "GLTexture.h"
#import "GLProgram.h"

@interface DeformTool()
{
	GLuint savedFBO;
	CGRect savedViewport;
	GLuint meshFBO;
	
	GLTexture* deformTexture;
}
@end

@implementation DeformTool
@synthesize deformTexture;

+(GLuint) genFramebufferTexture2D:(GLTexture*)renderTex
{
	GLint oldFBO = 0;
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
	
	// generate FBO
	GLuint texFBO = 0;
	glGenFramebuffers(1, &texFBO);
	glBindFramebuffer(GL_FRAMEBUFFER, texFBO);
	
	// associate texture with FBO
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, renderTex.textureName, 0);
	
	// check if it worked (probably worth doing :) )
	GLuint status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	if (status != GL_FRAMEBUFFER_COMPLETE)
	{
		[NSException raise:@"Render Texture" format:@"Could not attach texture to framebuffer"];
	}
	
	glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);
	
	return texFBO;
}

-(void) startRenderingFBO:(GLuint)fbo withViewportSize:(CGSize)texSize
{
	glGetFloatv(GL_VIEWPORT, (GLfloat*)&savedViewport);
	glGetIntegerv(GL_FRAMEBUFFER_BINDING, (GLint*)&savedFBO);
	
	glBindFramebuffer(GL_FRAMEBUFFER, fbo);//Will direct drawing to the frame buffer created above
	glViewport(0, 0, texSize.width, texSize.height);
}

-(void)endRendering
{
	glBindFramebuffer(GL_FRAMEBUFFER, savedFBO);
	glViewport(savedViewport.origin.x, savedViewport.origin.y, savedViewport.size.width, savedViewport.size.height);	
}

+(GLProgram*) loadProgram
{
	static GLProgram* deformProgram = nil;
	if(!deformProgram) {
		deformProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"DeformShader" fragmentShaderFilename:@"DeformShader"];
		[deformProgram addAttribute:@"position"];
		[deformProgram addAttribute:@"texCoord"];
		[deformProgram link];
	}
	return deformProgram;
}

-(void) renderDeformInRect:(CGRect)rect
{
	GLfloat w = rect.size.width;
    GLfloat h = rect.size.height;
    CGPoint pt = rect.origin;
	GLfloat vertices[] = {pt.x,	pt.y, 0, pt.x+w, pt.y, 0, pt.x, pt.y+h, 0, pt.x+w, pt.y+h, 0};
	GLfloat coordinates[] = { 0, 0,   1, 0,   0, 1,   1, 1, };

	GLProgram* program = [DeformTool loadProgram];
    [program use];
    
	//glEnable(GL_BLEND);
	//glBlendFunc(GL_ONE, GL_ONE);
	
    GLuint vertCoordAttr = [program attributeIndex:@"position"];
    GLuint texCoordAttr = [program attributeIndex:@"texCoord"];
    
    glVertexAttribPointer(vertCoordAttr, 3, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(vertCoordAttr);
    glVertexAttribPointer(texCoordAttr, 2, GL_FLOAT, 0, 0, coordinates);
    glEnableVertexAttribArray(texCoordAttr);
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


-(id) init
{
	self = [super init];
	if(self) {
		
		deformTexture = [[GLTexture alloc] initWithImage:[UIImage imageNamed:@"Black256.png"]];
		meshFBO = [DeformTool genFramebufferTexture2D:deformTexture];
		
		[self startRenderingFBO:meshFBO withViewportSize:deformTexture.contentSize];

		[self renderDeformInRect:CGRectMake(-1, -1, 2, 2)];
		
		[self endRendering];
		
	}
	return self;
}


@end
















