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

#import "IndexMesh.h"

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
	CGSize brushSize = _brush.patternTexture.textureSize;
	MeshLayout layout = deformMesh.layout;

	CGRect r = CGRectMake(p.x-brushSize.width/2, p.y-brushSize.height/2, brushSize.width, brushSize.height);
	LayoutWindow drawWindow = [deformMesh inclusiveWindowForRect:r interlacing:1];
	
	IndexMesh* indexMesh = [IndexMesh indexMeshWithWidth:drawWindow.right-drawWindow.left
											 maxHeight:drawWindow.bottom-drawWindow.top
											 rowStride:(layout.width+1)];	
	
	
	int offsetX = drawWindow.left-layout.x;
	int offsetY = drawWindow.top-layout.y;
	int vertOffset = (offsetY*(layout.width+1) + offsetX)*2;
	
	GLshort* vertices = [deformMesh verticesAbsolutePointer] + vertOffset;
	GLfloat* vectors = [deformMesh vectorsAbsolutePointer] + vertOffset;
		
	
	
	CGSize tsz = alphaTexture.textureSize;
	
	[framebuffer startRendering];
	
	GLProgram* program = [EraseTool loadEraseProgram];
	[program use];

	glUniform2f([program uniformIndex:@"tsz"], tsz.width, tsz.height);
	glUniform2f([program uniformIndex:@"bsz"], brushSize.width, brushSize.height);
	glUniform2f([program uniformIndex:@"bp0"], r.origin.x, r.origin.y);

	glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _brush.patternTexture.textureName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

	glEnable(GL_BLEND);
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

    glUniform1i([program uniformIndex:@"texture"], 0);
    
    GLuint positionAttr = [program attributeIndex:@"position"];
    glVertexAttribPointer(positionAttr, 2, GL_SHORT, 0, 0, vertices);
    glEnableVertexAttribArray(positionAttr);

	GLuint vectorsAttr = [program attributeIndex:@"vectors"];
	glVertexAttribPointer(vectorsAttr, 2, GL_FLOAT, 0, 0, vectors);
    glEnableVertexAttribArray(vectorsAttr);


	glDisable(GL_CULL_FACE);

	//glDrawElements(GL_LINE_STRIP, indexMesh.indexCount, GL_UNSIGNED_SHORT, indexMesh.indices);
	glDrawElements(GL_TRIANGLE_STRIP, indexMesh.indexCount, GL_UNSIGNED_SHORT, indexMesh.indices);

	
	[framebuffer startRendering];
	
}


-(void) clear
{
	[framebuffer startRendering];
	glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
	[framebuffer startRendering];
}


@end
