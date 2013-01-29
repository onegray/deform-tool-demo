//
//  PatternBrush.m
//  DeformTool
//
//  Created by onegray on 1/20/13.
//
//

#import "PatternBrush.h"

#import "GLProgram.h"
#import "GLTexture.h"
#import "GLFramebuffer.h"

@interface PatternBrush()

@end

@implementation PatternBrush


-(void) updatePixelSize
{
	[super updatePixelSize];
	CGSize texSize = CGSizeMake(self.pixelSize, self.pixelSize);
	if( !CGSizeEqualToSize(texSize, _patternTexture.textureSize) ) {
		_patternTexture = [self generateBrushTextureOfSize:texSize];
	}
}

-(GLProgram*) brushProgram
{
	static GLProgram* program = nil;
	if(!program) {
		program = [[GLProgram alloc] initWithVertexShaderFilename:@"GenBrush" fragmentShaderFilename:@"GenBrush"];
		[program addAttribute:@"position"];
		[program link];
	}
	return program;
}

-(GLTexture*) generateBrushTextureOfSize:(CGSize)texSize
{
	GLFramebuffer* brushFramebuffer = [[GLFramebuffer alloc] initTextureFramebufferOfSize:texSize];
	[brushFramebuffer startRendering];

	GLProgram* program = [self brushProgram];
	[program use];

	GLfloat vertices[] = {-1, -1, 1, -1, -1, 1, 1, 1 };
    GLuint vertCoordAttr = [program attributeIndex:@"position"];
    glVertexAttribPointer(vertCoordAttr, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(vertCoordAttr);
	
	glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	[brushFramebuffer endRendering];
	
	//[brushFramebuffer saveImage:@"brush.png"];
	
	return brushFramebuffer.texture;
}


@end
