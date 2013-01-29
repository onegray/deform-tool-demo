//
//  EraseTool.m
//  DeformTool
//
//  Created by onegray on 1/20/13.
//
//

#import "EraseTool.h"
#import "PatternBrush.h"

#import "LayerMesh.h"
#import "GLTexture.h"
#import "GLFramebuffer.h"
#import "GLProgram.h"

@interface EraseTool()
{
	LayerMesh* deformMesh;
	GLTexture* alphaTexture;
	
	GLFramebuffer* framebuffer;
}
@end

@implementation EraseTool

+(GLProgram*) loadEraseProgram
{
	static GLProgram* program = nil;
	if(!program) {
		program = [[GLProgram alloc] initWithVertexShaderFilename:@"EraseShader" fragmentShaderFilename:@"EraseShader"];
		[program addAttribute:@"position"];
		[program addAttribute:@"texCoord"];
		[program addAttribute:@"vectors"];
		[program link];
	}
	return program;
}


- (id)initWithMesh:(LayerMesh*)mesh alphaTexture:(GLTexture*)texture
{
    self = [super init];
    if (self) {
        deformMesh = mesh;
		alphaTexture = texture;
		
		framebuffer = [[GLFramebuffer alloc] initTextureFramebufferWithTexture:texture];
    }
    return self;
}

-(void) eraseFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
	CGPoint p = startPoint;
	CGSize bs = _brush.patternTexture.textureSize;
	CGSize ts = alphaTexture.textureSize;
	
	CGRect r = CGRectMake(p.x-bs.width/2, p.y-bs.height/2, bs.width, bs.height);

	NSLog(@"\n\n ts: %@", NSStringFromCGSize(ts));

	NSLog(@"p: %@", NSStringFromCGPoint(p));
	
	NSLog(@"r: %@", NSStringFromCGRect(r));
	r = CGRectMake(r.origin.x/ts.width, r.origin.y/ts.height, r.size.width/ts.width, r.size.height/ts.height);
	NSLog(@"r: %@", NSStringFromCGRect(r));

	r = CGRectMake(2*r.origin.x-1, 2*r.origin.y-1, r.size.width*2, r.size.height*2);
	NSLog(@"r: %@", NSStringFromCGRect(r));

	GLfloat vertices[] = {
		r.origin.x,						r.origin.y,
		r.origin.x+r.size.width,	r.origin.y,
		r.origin.x,						r.origin.y+r.size.height,
		r.origin.x+r.size.width,	r.origin.y+r.size.height, };

	GLfloat coordinates[] = { 0, 0,   1, 0,   0, 1,   1, 1, };
	
	[framebuffer startRendering];
	
	GLProgram* program = [EraseTool loadEraseProgram];
	[program use];
	
	glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _brush.patternTexture.textureName);
	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	
    glUniform1i([program uniformIndex:@"texture"], 0);
    
    GLuint vertCoordAttr = [program attributeIndex:@"position"];
    GLuint texCoordAttr = [program attributeIndex:@"texCoord"];
	GLuint vectorsAttr = [program attributeIndex:@"vectors"];
    
    glVertexAttribPointer(vertCoordAttr, 2, GL_FLOAT, 0, 0, vertices);
    glEnableVertexAttribArray(vertCoordAttr);
    glVertexAttribPointer(texCoordAttr, 2, GL_FLOAT, 0, 0, coordinates);
    glEnableVertexAttribArray(texCoordAttr);
	//glVertexAttribPointer(vectorsAttr, 2, GL_FLOAT, 0, mesh.vectorsStride, deformMesh.vectors);
	//glEnableVertexAttribArray(vectorsAttr);

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	
	[framebuffer endRendering];
}



@end
