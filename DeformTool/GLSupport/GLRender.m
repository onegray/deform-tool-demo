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

@interface GLRender ()
@end

@implementation GLRender
static GLProgram* baseProgram = nil;

+ (GLProgram*)loadStandardProgram:(NSString*)programName
{        
    GLProgram* p = [[GLProgram alloc] initWithVertexShaderFilename:programName fragmentShaderFilename:programName];
    [p addAttribute:@"position"];
    [p addAttribute:@"texCoord"];
    [p link];
    return p;
}

+ (void)loadBaseProgram
{        
    if(!baseProgram)
    {
        baseProgram = [self loadStandardProgram:@"BaseShader"];
    }
}

+(GLProgram*) baseProgram
{
	if(!baseProgram) {
		[self loadBaseProgram];
	}
	return baseProgram;
}

+ (void) drawTexture:(GLTexture*)texture inRect:(CGRect)rect
{
    GLfloat w = rect.size.width;
    GLfloat h = rect.size.height;
    CGPoint pt = rect.origin;
	GLfloat vertices[] = {pt.x,	pt.y, 0, pt.x+w, pt.y, 0, pt.x, pt.y+h, 0, pt.x+w, pt.y+h, 0};
	GLfloat coordinates[] = { 0, texture.maxT, texture.maxS, texture.maxT, 0, 0, texture.maxS, 0};
    
    [baseProgram use];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture.textureName);
    
    glUniform1i([baseProgram uniformIndex:@"texture"], 0);
    
    GLuint vertCoordAttr = [baseProgram attributeIndex:@"position"];
    GLuint texCoordAttr = [baseProgram attributeIndex:@"texCoord"];
    
    glVertexAttribPointer(vertCoordAttr, 3, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(vertCoordAttr);
    glVertexAttribPointer(texCoordAttr, 2, GL_FLOAT, 0, 0, coordinates);
    glEnableVertexAttribArray(texCoordAttr);
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}














@end
