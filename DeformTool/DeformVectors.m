//
//  DeformVectors.m
//  DeformTool
//
//  Created by onegray on 11/4/12.
//
//

#import <Accelerate/Accelerate.h>

#import "DeformVectors.h"
#import "MeshLayout.h"

@interface DeformVectors ()
{
	MeshLayout layout;
	GLfloat* vectors;
	int vertNum;
}
@end




@implementation DeformVectors
@synthesize layout, vectors;

-(id) initWithLayout:(MeshLayout)l
{
	self = [super init];
	if(self) {
		layout = l;
		vertNum = (layout.width+1)*(layout.height+1);
		
		//vectors = (GLfloat*)malloc(vertNum*2*sizeof(GLfloat));
		//memset(vectors, 0, vertNum*2*sizeof(GLfloat));
		vectors = (GLfloat*)calloc(vertNum*2, sizeof(GLfloat));
		
	}
	return self;
}

-(void) dealloc
{
	if(vectors) {
		free(vectors);
	}
}

-(void) extendLayout:(MeshLayout)newLayout
{
	NSAssert(MeshLayoutContainsLayout(newLayout, layout), @"");

	int newVertNum = (newLayout.width+1) * (newLayout.height+1);
	
	//GLfloat* newVectors = (GLfloat*)malloc(newVertNum*2*sizeof(GLfloat));
	//memset(newVectors, 0, newVertNum*2*sizeof(GLfloat));
	GLfloat* newVectors = (GLfloat*)calloc(newVertNum*2, sizeof(GLfloat));

	
	vDSP_mmov(vectors, newVectors + (layout.y-newLayout.y)*(newLayout.width+1)*2 + (layout.x-newLayout.x)*2,
			  (layout.width+1)*2, (layout.height+1),
			  (layout.width+1)*2,
			  (newLayout.width+1)*2 );
	

#if 0
	GLfloat* vPtr = vectors;
	for(int i=0; i<=layout.height; i++)
	{
		GLfloat* nvPtr = newVectors + (i + layout.y-newLayout.y)*(newLayout.width+1)*2 + (layout.x-newLayout.x)*2;
		for(int j=0; j<=layout.width; j++)
		{
			NSAssert(nvPtr[0]==vPtr[0] && nvPtr[1]==vPtr[1], @"vDSP_mmov invalid results");
			*nvPtr++ = *vPtr++;
			*nvPtr++ = *vPtr++;
		}
	}
#endif
	
	layout = newLayout;
	vertNum = newVertNum;

	free(vectors);
	vectors = newVectors;
}

-(void) print
{
	NSLog(@"DeformVectors: %d x %d", layout.width, layout.height );
	
	NSMutableString* str = [[NSMutableString alloc] initWithCapacity:vertNum*8];
	
	GLfloat* vPtr = vectors;
	for (int i=0; i<=layout.height; i++) {
		for(int j=0; j<=layout.width; j++) {
			GLfloat x = *vPtr++;
			GLfloat y = *vPtr++;
			[str appendFormat:@"\t(%.2f,%.2f) ", x, y];
		}
		[str appendString:@"\n"];
	}
	NSLog(@"\n%@", str);
}


+(void) test
{
	return;
	
	DeformVectors* v = [[DeformVectors alloc] initWithLayout:MeshLayoutMake(0, 0, 4, 4)];

	for (int i=0; i<=v.layout.height; i++) {
		for(int j=0; j<=v.layout.width; j++) {
			int ind = i*(v.layout.width+1)*2  + j*2;
			v.vectors[ind] = i*5+j;
			v.vectors[ind+1] = -(i*5+j);
		}
	}
	
	[v print];
	
	[v extendLayout:MeshLayoutMake(-1, -2, 6, 8)];

	[v print];

}


@end




