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
	GLProgram* program;
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
		sharedInstance = [[GLRender alloc] initWithProgramName:@"BaseShader"];
	}
}

-(id) initWithProgramName:(NSString*)programName
{
	if(self=[super init]) {
		program = [[GLProgram alloc] initWithVertexShaderFilename:programName fragmentShaderFilename:programName];
		[program addAttribute:@"position"];
		[program addAttribute:@"texCoord"];
		[program link];
		
		
		[GLRender resultProgram];
	}
	return self;
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
    glUniform1i([resultProgram uniformIndex:@"deformTexture"], 1);
	
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture.textureName);
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





@end
