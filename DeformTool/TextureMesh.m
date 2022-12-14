//
//  TextureMesh.m
//  DeformTool
//
//  Created by onegray on 9/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextureMesh.h"


#define IS_POT(x) ((x)&&!((x)&((x)-1)))


@interface TextureMesh()
{
	CGRect textureRect;
	GLfloat* coordinates;
	int coordNum;
	
	MeshLayout layout;
}
@end


@implementation TextureMesh
@synthesize textureRect, coordinates, coordNum;
@synthesize layout;

-(id) initWithTextureRect:(CGRect)tr meshLayout:(MeshLayout)meshLayout
{
	self = [super init];
	if(self) {
		layout = meshLayout;
		textureRect = tr; // Initial texture rect is {0,0,1,1} 
	
		coordNum = (layout.width+1) * (layout.height+1);
		
		if(coordinates) free(coordinates);
		coordinates = (GLfloat*)malloc(coordNum*2*sizeof(GLfloat));
		GLfloat* coordPtr = coordinates;
		
		for(int i=0; i<=layout.height; i++)
		{
			for(int j=0; j<=layout.width; j++)
			{
				*coordPtr++ = textureRect.origin.x + j * textureRect.size.width / layout.width;
				*coordPtr++ = textureRect.origin.y + i * textureRect.size.height / layout.height;
			}
		}
	}
	return self;
}


-(void) extendMeshLayout:(MeshLayout)newLayout
{
	NSAssert(MeshLayoutContainsLayout(newLayout, layout), @"");
	float dw = textureRect.size.width / layout.width;
	float dh = textureRect.size.height / layout.height;
	int newCoordNum = (newLayout.width+1) * (newLayout.height+1);

	GLfloat* newCoordinates = (GLfloat*)malloc(newCoordNum*2*sizeof(GLfloat));
	GLfloat* newCoordPtr = newCoordinates;
	for(int i=0; i<=newLayout.height; i++)
	{
		for(int j=0; j<=newLayout.width; j++)
		{
			*newCoordPtr++ = (newLayout.x + j) * dw;
			*newCoordPtr++ = (newLayout.y + i) * dh;
		}
	}
	
	GLfloat* coordPtr = coordinates;
	for(int i=0; i<=layout.height; i++)
	{
		newCoordPtr = newCoordinates + (i + layout.y-newLayout.y)*(newLayout.width+1)*2 + (layout.x-newLayout.x)*2;
		for(int j=0; j<=layout.width; j++)
		{
			*newCoordPtr++ = *coordPtr++;
			*newCoordPtr++ = *coordPtr++;
		}
	}
	
	layout = newLayout;
	textureRect = CGRectMake(layout.x*dw, layout.y*dh, layout.width*dw, layout.height*dh);
	coordNum = newCoordNum;
	
	free(coordinates);
	coordinates = newCoordinates;
}


-(void) resampleMesh:(int)multiplier
{
	NSAssert(IS_POT(multiplier), @"");	
	
	int newMeshWidth = layout.width*multiplier;
	int newMeshHeight = layout.height*multiplier;
	int newCoordNum = (newMeshWidth+1) * (newMeshHeight+1);

	GLfloat* newCoordinates = (GLfloat*)malloc(newCoordNum*2*sizeof(GLfloat));
	
#define COORD_POINT(x,y) ((CGPoint*)&coordinates[(y)*(layout.width+1)*2 + (x)*2])
#define NEW_COORD_POINT(x,y) ((CGPoint*)&newCoordinates[(y)*(newMeshWidth+1)*2 + (x)*2])

	memset(newCoordinates, 0, newCoordNum*2*sizeof(GLfloat));
	
	for(int i=0; i<=layout.height; i++)
	{
		int ii = i*multiplier;
		for(int j=0; j<layout.width; j++)
		{
			GLfloat x0 = COORD_POINT(j, i)->x;
			GLfloat x1 = COORD_POINT(j+1, i)->x;
			GLfloat y0 = COORD_POINT(j, i)->y;
			GLfloat y1 = COORD_POINT(j+1, i)->y;

			int jj = j*multiplier;
			*NEW_COORD_POINT(jj, ii) = *COORD_POINT(j, i);
			for(int k=1; k<multiplier; k++) {
				*NEW_COORD_POINT(jj+k, ii) = CGPointMake(x0 + (x1-x0)*k/multiplier, y0 + (y1-y0)*k/multiplier);
			}			
		}
		*NEW_COORD_POINT(newMeshWidth, ii) = *COORD_POINT(layout.width, i);
	}
	
	for(int i=0; i<layout.height; i++)
	{
		int ii = i*multiplier;
		for(int j=0; j<=newMeshWidth; j++)
		{
			GLfloat x0 = NEW_COORD_POINT(j, ii)->x;
			GLfloat x1 = NEW_COORD_POINT(j, ii+multiplier)->x;
			GLfloat y0 = NEW_COORD_POINT(j, ii)->y;
			GLfloat y1 = NEW_COORD_POINT(j, ii+multiplier)->y;
			
			for(int k=1; k<multiplier; k++) {
				*NEW_COORD_POINT(j, ii+k) = CGPointMake(x0 + (x1-x0)*k/multiplier, y0 + (y1-y0)*k/multiplier);
			}			
		}
	}
	
#undef COORD_POINT
#undef NEW_COORD_POINT	
	
	coordNum = newCoordNum;
	
	free(coordinates);
	coordinates = newCoordinates;
	
	
	float dw = textureRect.size.width / layout.width;
	float dh = textureRect.size.height / layout.height;
	
	layout.x = textureRect.origin.x / dw;
	layout.y = textureRect.origin.y / dh;
	layout.width = newMeshWidth;
	layout.height= newMeshHeight;
}


////////////////////////////////////////////////////////

-(void) print
{
	NSLog(@"meshRect: %@", NSStringFromCGRect(textureRect) );
	NSLog(@"meshSize: %d x %d", layout.width, layout.height );

	NSMutableString* str = [[NSMutableString alloc] initWithCapacity:coordNum*8];
	
	GLfloat* coordPtr = coordinates;
	for (int i=0; i<=layout.height; i++) {
		for(int j=0; j<=layout.width; j++) {
			GLfloat x = *coordPtr++;
			GLfloat y = *coordPtr++;
			[str appendFormat:@"\t(%.2f,%.2f) ", x, y];
		}
		[str appendString:@"\n"];
	}
	NSLog(@"\n%@", str);
}

-(void) prontLineCoords:(GLfloat*)ptr count:(int)num
{
	NSMutableString* str = [[NSMutableString alloc] initWithCapacity:coordNum*8];
	for (int i=0; i<num; i++) {
		GLfloat x = *ptr++;
		GLfloat y = *ptr++;
		[str appendFormat:@"\t(%.2f,%.2f) ", x, y];
	}
	NSLog(@"\n%@", str);
}


+(void) test
{
	return;
	
	TextureMesh* mesh = [[TextureMesh alloc] initWithTextureRect:CGRectMake(0, 0, 1, 1) meshLayout:MeshLayoutMake(0, 0, 2, 2)];
	[mesh print];
	//[mesh extendMeshLayout:MeshLayoutMake(0, 0, 3, 3)];
	//[mesh print];
	
	[mesh resampleMesh:2];
	[mesh print];
	
}



@end










