//
//  DeformTool+TextureMesh.m
//  DeformTool
//
//  Created by onegray on 10/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeformTool+TextureMesh.h"
#import "GLTexture.h"
#import "GLProgram.h"
#import "GLFramebuffer.h"
#import "GLRender.h"

@implementation DeformTool (TextureMesh)

+(GLProgram*) loadDeformProgram
{
	static GLProgram* deformProgram = nil;
	if(!deformProgram) {
		deformProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"DeformShader" fragmentShaderFilename:@"DeformShader"];
		[deformProgram addAttribute:@"position"];
		[deformProgram addAttribute:@"texCoord"];
		[deformProgram addAttribute:@"brushCoord"];
		[deformProgram link];
	}
	return deformProgram;
}

-(id) init
{
	self = [super init];
	if(self) {
		[self initDeformTextures];
	}
	return self;
}

-(void) initDeformTextures
{
	brushTexture = [[GLTexture alloc] initWithImage:[UIImage imageNamed:@"brush.png"]];
	CGSize brushSize = [brushTexture contentSize];
	
	meshFramebuffer = [[GLFramebuffer alloc] initFloatTextureFramebufferOfSize:CGSizeMake(256, 256)];
	
	tempFramebuffer = [[GLFramebuffer alloc] initFloatTextureFramebufferOfSize:brushSize];
}


-(void) generateBrushTexture
{
	static GLProgram* program = nil;
	if(!program) {
		program = [[GLProgram alloc] initWithVertexShaderFilename:@"GenBrush" fragmentShaderFilename:@"GenBrush"];
		[program addAttribute:@"position"];
		[program addAttribute:@"texCoord"];
		[program link];
	}
	
	[program use];
	
	GLFramebuffer* brushFramebuffer = [[GLFramebuffer alloc] initTextureFramebufferOfSize:CGSizeMake(64, 64)];
	[brushFramebuffer startRendering];
	
	GLfloat vertices[] = {-1, -1, 1, -1, -1, 1, 1, 1 };
    GLuint vertCoordAttr = [program attributeIndex:@"position"];
    glVertexAttribPointer(vertCoordAttr, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(vertCoordAttr);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	[brushFramebuffer endRendering];
	[brushFramebuffer saveImage:@"brush.png"];
}

-(GLuint) deformTextureName
{
	return meshFramebuffer.texture.textureName;
}

-(GLuint) brushTextureName
{
	return brushTexture.textureName;
}


-(void) applyDeformVector:(CGPoint)force atPoint:(CGPoint)point
{
	CGSize contentSize = CGSizeMake(256, 256);
	CGSize brushSize = [brushTexture contentSize];
	
	CGPoint texPoint = CGPointMake(point.x/contentSize.width, point.y/contentSize.height);
	CGSize texBrushSize = CGSizeMake(brushSize.width/contentSize.width, brushSize.height/contentSize.height);
	CGRect texRect = CGRectMake(texPoint.x-texBrushSize.width/2, texPoint.y-texBrushSize.height/2, texBrushSize.width, texBrushSize.height);
	CGRect vertexRect = CGRectMake(-1 + 2*texRect.origin.x, -1 + 2*texRect.origin.y, 2*texRect.size.width, 2*texRect.size.height);
	
	force.x = force.x / brushSize.width;
	force.y = force.y / brushSize.height;
	force.x = force.x / 4;
	force.y = force.y / 4;
	
	NSLog(@"texBrushSize %@", NSStringFromCGSize(texBrushSize));
	NSLog(@"texRect %@", NSStringFromCGRect(texRect));
	NSLog(@"vertexRect %@", NSStringFromCGRect(vertexRect));
	
	
	GLfloat vertices[] = {-1, -1, 1, -1, -1, 1, 1, 1 };
	GLfloat coordinates[] = { 
		texRect.origin.x,						texRect.origin.y,  
		texRect.origin.x+texRect.size.width,	texRect.origin.y,
		texRect.origin.x,						texRect.origin.y+texRect.size.height,
		texRect.origin.x+texRect.size.width,	texRect.origin.y+texRect.size.height, };
	GLfloat brushCoords[] = { 0, 0,   1, 0,   0, 1,   1, 1, };
	
	GLProgram* program = [DeformTool loadDeformProgram];
    [program use];
	
	[tempFramebuffer startRendering];
	
	glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, brushTexture.textureName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glUniform1i([program uniformIndex:@"brushTexture"], 1);
	
	glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, meshFramebuffer.texture.textureName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glUniform1i([program uniformIndex:@"meshTexture"], 0);
	
	glUniform2f([program uniformIndex:@"center"], texPoint.x, texPoint.y);
	glUniform2f([program uniformIndex:@"force"], force.x, force.y);
	
    GLuint vertCoordAttr = [program attributeIndex:@"position"];
    GLuint texCoordAttr = [program attributeIndex:@"texCoord"];
    GLuint brushCoordAttr = [program attributeIndex:@"brushCoord"];
    
    glVertexAttribPointer(vertCoordAttr, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(vertCoordAttr);
    glVertexAttribPointer(texCoordAttr, 2, GL_FLOAT, 0, 0, coordinates);
    glEnableVertexAttribArray(texCoordAttr);
	glVertexAttribPointer(brushCoordAttr, 2, GL_FLOAT, 0, 0, brushCoords);
    glEnableVertexAttribArray(brushCoordAttr);
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	[tempFramebuffer endRendering];
	
	[meshFramebuffer startRendering];
	[[GLRender sharedRender] drawTextureName:tempFramebuffer.texture.textureName inRect:vertexRect];
	[meshFramebuffer endRendering];
}



@end
