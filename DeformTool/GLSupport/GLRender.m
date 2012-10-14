//
//  GLRender.m
//  DeformTool
//
//  Created by onegray on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GLRender.h"
#import "GLTexture.h"
#import "GLProgram.h"
#import "LayerMesh.h"

#import "matrix.h"
#import "TransformUtils.h"


@interface GLRender ()
{
	//GLProgram* program;
}


@end

@implementation GLRender

static GLRender* sharedInstance = nil;

+(GLRender*) sharedRender
{
	return sharedInstance;
}

+ (void) loadSharedRender
{
	if(!sharedInstance) {
		sharedInstance = [[GLRender alloc] init];
	}
}

+(GLProgram*) baseProgram
{
	static GLProgram* baseProgram = nil;
	if(!baseProgram) {
		baseProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"BaseShader" fragmentShaderFilename:@"BaseShader"];
		[baseProgram addAttribute:@"position"];
		[baseProgram addAttribute:@"texCoord"];
		[baseProgram link];
	}
	return baseProgram;
}





- (void) drawTexture:(GLTexture*)texture inRect:(CGRect)rect transformMatrix:(CGAffineTransform)transform
{
	GLfloat matrix[16];
	CGAffineToGL(&transform, matrix);	
	
    GLfloat w = rect.size.width;
    GLfloat h = rect.size.height;
    CGPoint pt = rect.origin;
	GLfloat vertices[] = {pt.x,	pt.y, 0, pt.x+w, pt.y, 0, pt.x, pt.y+h, 0, pt.x+w, pt.y+h, 0};
	//GLfloat coordinates[] = { 0, texture.maxT, texture.maxS, texture.maxT, 0, 0, texture.maxS, 0};
	  GLfloat coordinates[] = {
		  0,			0,
		  texture.maxS, 0, 
		  0,			texture.maxT,
		  texture.maxS, texture.maxT,
	  };
    
	GLProgram* program = [GLRender baseProgram];
    [program use];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture.textureName);
    
	glUniformMatrix4fv([program uniformIndex:@"modelViewProjectionMatrix"], 1, GL_FALSE, matrix);
    glUniform1i([program uniformIndex:@"texture"], 0);
    
    GLuint vertCoordAttr = [program attributeIndex:@"position"];
    GLuint texCoordAttr = [program attributeIndex:@"texCoord"];
    
    glVertexAttribPointer(vertCoordAttr, 3, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(vertCoordAttr);
    glVertexAttribPointer(texCoordAttr, 2, GL_FLOAT, 0, 0, coordinates);
    glEnableVertexAttribArray(texCoordAttr);
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (void) drawTexture:(GLTexture*)texture withMesh:(LayerMesh*)mesh transformMatrix:(CGAffineTransform)transform
{
	GLfloat matrix[16];
	CGAffineToGL(&transform, matrix);
    
	GLProgram* program = [GLRender baseProgram];
    [program use];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture.textureName);
    
	glEnable(GL_BLEND);   
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	
	
	glUniformMatrix4fv([program uniformIndex:@"modelViewProjectionMatrix"], 1, GL_FALSE, matrix);
    glUniform1i([program uniformIndex:@"texture"], 0);
    
    GLuint vertCoordAttr = [program attributeIndex:@"position"];
    GLuint texCoordAttr = [program attributeIndex:@"texCoord"];
    
    glVertexAttribPointer(vertCoordAttr, 2, GL_FLOAT, 0, 0, mesh.vertices);
    glEnableVertexAttribArray(vertCoordAttr);
    glVertexAttribPointer(texCoordAttr, 2, GL_FLOAT, 0, 0, mesh.texCoords);
    glEnableVertexAttribArray(texCoordAttr);
    
	//glDrawElements(GL_LINE_STRIP, mesh.indexCount, GL_UNSIGNED_SHORT, mesh.indices);
	glDrawElements(GL_TRIANGLE_STRIP, mesh.indexCount, GL_UNSIGNED_SHORT, mesh.indices);
}




+(GLProgram*) resultProgram
{
	static GLProgram* resultProgram = nil;
	if(!resultProgram) {
		resultProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"ResultShader" fragmentShaderFilename:@"ResultShader"];
		[resultProgram addAttribute:@"position"];
		[resultProgram addAttribute:@"texCoord"];
		[resultProgram link];
	}
	return resultProgram;
}


- (void) drawTexture:(GLTexture*)texture deformTexture:(int)deformTexture inRect:(CGRect)rect transformMatrix:(CGAffineTransform)transform
{
	GLfloat matrix[16];
	CGAffineToGL(&transform, matrix);	
	
    GLfloat w = rect.size.width;
    GLfloat h = rect.size.height;
    CGPoint pt = rect.origin;
	GLfloat vertices[] = {pt.x,	pt.y, 0, pt.x+w, pt.y, 0, pt.x, pt.y+h, 0, pt.x+w, pt.y+h, 0};
	GLfloat coordinates[] = {
		0,			0,
		texture.maxS, 0, 
		0,			texture.maxT,
		texture.maxS, texture.maxT,
	};
    
	
	GLProgram* resultProgram = [GLRender resultProgram];
    [resultProgram use];

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, deformTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glUniform1i([resultProgram uniformIndex:@"deformTexture"], 1);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture.textureName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glUniform1i([resultProgram uniformIndex:@"texture"], 0);

	glUniformMatrix4fv([resultProgram uniformIndex:@"modelViewProjectionMatrix"], 1, GL_FALSE, matrix);
    
    GLuint vertCoordAttr = [resultProgram attributeIndex:@"position"];
    GLuint texCoordAttr = [resultProgram attributeIndex:@"texCoord"];
    
    glVertexAttribPointer(vertCoordAttr, 3, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(vertCoordAttr);
    glVertexAttribPointer(texCoordAttr, 2, GL_FLOAT, 0, 0, coordinates);
    glEnableVertexAttribArray(texCoordAttr);
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}



+(GLProgram*) simpleProgram
{
	static GLProgram* simpleProgram = nil;
	if(!simpleProgram) {
		simpleProgram = [[GLProgram alloc] initWithVertexShaderFilename:@"SimpleShader" fragmentShaderFilename:@"SimpleShader"];
		[simpleProgram addAttribute:@"position"];
		[simpleProgram addAttribute:@"texCoord"];
		[simpleProgram link];
	}
	return simpleProgram;
}

- (void) drawTextureName:(GLuint)textureName inRect:(CGRect)rect
{
    GLfloat w = rect.size.width;
    GLfloat h = rect.size.height;
    CGPoint pt = rect.origin;
	GLfloat vertices[] = {pt.x,	pt.y, pt.x+w, pt.y, pt.x, pt.y+h, pt.x+w, pt.y+h};
	GLfloat coordinates[] = { 0, 0,   1, 0,   0, 1,   1, 1, };
    
	GLProgram* program = [GLRender simpleProgram];
    [program use];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureName);
    
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);

    glUniform1i([program uniformIndex:@"texture"], 0);
    
    GLuint vertCoordAttr = [program attributeIndex:@"position"];
    GLuint texCoordAttr = [program attributeIndex:@"texCoord"];
    
    glVertexAttribPointer(vertCoordAttr, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(vertCoordAttr);
    glVertexAttribPointer(texCoordAttr, 2, GL_FLOAT, 0, 0, coordinates);
    glEnableVertexAttribArray(texCoordAttr);
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}





@end
