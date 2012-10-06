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
#import "GLFramebuffer.h"

@interface DeformTool()
{
	GLFramebuffer* deformFramebuffer;
}
@end

@implementation DeformTool


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
		
		deformFramebuffer = [[GLFramebuffer alloc] initTextureFramebufferOfSize:CGSizeMake(256, 256)];
		
		[deformFramebuffer startRendering];
		
		[self renderDeformInRect:CGRectMake(-1, -1, 2, 2)];
		
		[deformFramebuffer endRendering];
		
	}
	return self;
}

-(GLuint) deformTextureName
{
	return deformFramebuffer.textureName;
}

@end
















