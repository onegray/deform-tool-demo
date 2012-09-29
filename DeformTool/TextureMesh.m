//
//  TextureMesh.m
//  DeformTool
//
//  Created by onegray on 9/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextureMesh.h"

#define MAX_TEXTURE_TILE_SIZE 32

#define IS_POT(x) ((x)&&!((x)&((x)-1)))


@interface TextureMesh()
{
	PixelSize textureSize;
	int tileSize;
	int meshWidth;
	int meshHeight;

	CGRect meshRect;
	GLfloat* coordinates;
	int coordNum;
}
@end


@implementation TextureMesh

-(id) initWithTextureSize:(PixelSize)ts
{
	self = [super init];
	if(self) {
		textureSize = ts;
		NSAssert( ts.widthPixels % MAX_TEXTURE_TILE_SIZE == 0, @"");
		NSAssert( ts.heighPixels % MAX_TEXTURE_TILE_SIZE == 0, @"");
	}
	return self;
}


-(void) buildInitialMeshWithTileSize:(int)ts
{
	//meshRect = rect;
	meshRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
	tileSize = ts;
	meshWidth = textureSize.widthPixels / tileSize;
	meshHeight = textureSize.heighPixels / tileSize;
	coordNum = (meshWidth+1) * (meshHeight+1);

	if(coordinates) free(coordinates);
	coordinates = (GLfloat*)malloc(coordNum*2*sizeof(GLfloat));
	GLfloat* coordPtr = coordinates;
	
	for(int i=0; i<=meshHeight; i++)
	{
		for(int j=0; j<=meshWidth; j++)
		{
			*coordPtr++ = meshRect.origin.x + j * meshRect.size.width / meshWidth;
			*coordPtr++ = meshRect.origin.y + i * meshRect.size.height / meshHeight;
		}
	}
}

-(void) extendMeshRect:(CGRect)newRect
{
	NSAssert( CGRectContainsRect(newRect, meshRect), @"");
	float dw = meshRect.size.width / meshWidth;
	float dh = meshRect.size.height / meshHeight;
	int newMeshWidth = newRect.size.width / dw;
	int newMeshHeight = newRect.size.height / dh;
	int newCoordNum = (newMeshWidth+1) * (newMeshHeight+1);
	
	GLfloat* newCoordinates = (GLfloat*)malloc(newCoordNum*2*sizeof(GLfloat));
	GLfloat* newCoordPtr = newCoordinates;
	for(int i=0; i<=newMeshHeight; i++)
	{
		for(int j=0; j<=newMeshWidth; j++)
		{
			*newCoordPtr++ = newRect.origin.x + j * dw;
			*newCoordPtr++ = newRect.origin.y + i * dh;
		}
	}

	int mx0 = meshRect.origin.x / dw;
	int nmx0 = newRect.origin.x / dw;
	int my0 = meshRect.origin.y / dh;
	int nmy0 = newRect.origin.y / dh;
	
	GLfloat* coordPtr = coordinates;
	for(int i=0; i<=meshHeight; i++)
	{
		newCoordPtr = newCoordinates + (i + my0-nmy0)*(newMeshWidth+1)*2 + (mx0-nmx0)*2;
		for(int j=0; j<=meshWidth; j++)
		{
			*newCoordPtr++ = *coordPtr++;
			*newCoordPtr++ = *coordPtr++;
		}
	}
	
	meshRect = newRect;
	meshWidth = newMeshWidth;
	meshHeight = newMeshHeight;
	coordNum = newCoordNum;
	
	free(coordinates);
	coordinates = newCoordinates;
}


-(void) resampleMeshForTileSize:(int)newTileSize
{
	NSAssert(newTileSize < tileSize, @"");	
	int tileMultiplier = tileSize/newTileSize;
	
	int newMeshWidth = meshWidth*tileMultiplier;
	int newMeshHeight = meshHeight*tileMultiplier;
	int newCoordNum = (newMeshWidth+1) * (newMeshHeight+1);

	GLfloat* newCoordinates = (GLfloat*)malloc(newCoordNum*2*sizeof(GLfloat));
	
#define COORD_POINT(x,y) ((CGPoint*)&coordinates[(y)*(meshWidth+1)*2 + (x)*2])
#define NEW_COORD_POINT(x,y) ((CGPoint*)&newCoordinates[(y)*(newMeshWidth+1)*2 + (x)*2])

	memset(newCoordinates, 0, newCoordNum*2*sizeof(GLfloat));
	
	for(int i=0; i<=meshHeight; i++)
	{
		int ii = i*tileMultiplier;
		for(int j=0; j<meshWidth; j++)
		{
			GLfloat x0 = COORD_POINT(j, i)->x;
			GLfloat x1 = COORD_POINT(j+1, i)->x;
			GLfloat y0 = COORD_POINT(j, i)->y;
			GLfloat y1 = COORD_POINT(j+1, i)->y;

			int jj = j*tileMultiplier;
			*NEW_COORD_POINT(jj, ii) = *COORD_POINT(j, i);
			for(int k=1; k<tileMultiplier; k++) {
				*NEW_COORD_POINT(jj+k, ii) = CGPointMake(x0 + (x1-x0)*k/tileMultiplier, y0 + (y1-y0)*k/tileMultiplier);
			}			
		}
		*NEW_COORD_POINT(meshWidth*tileMultiplier, ii) = *COORD_POINT(meshWidth, i);
	}
	
	for(int i=0; i<meshHeight; i++)
	{
		int ii = i*tileMultiplier;
		for(int j=0; j<=newMeshWidth; j++)
		{
			GLfloat x0 = NEW_COORD_POINT(j, ii)->x;
			GLfloat x1 = NEW_COORD_POINT(j, ii+tileMultiplier)->x;
			GLfloat y0 = NEW_COORD_POINT(j, ii)->y;
			GLfloat y1 = NEW_COORD_POINT(j, ii+tileMultiplier)->y;
			
			for(int k=1; k<tileMultiplier; k++) {
				*NEW_COORD_POINT(j, ii+k) = CGPointMake(x0 + (x1-x0)*k/tileMultiplier, y0 + (y1-y0)*k/tileMultiplier);
			}			
		}
	}
	
#undef COORD_POINT
#undef NEW_COORD_POINT	
	
	meshWidth = newMeshWidth;
	meshHeight = newMeshHeight;
	coordNum = newCoordNum;
	
	free(coordinates);
	coordinates = newCoordinates;
}


////////////////////////////////////////////////////////

-(void) print
{
	NSLog(@"meshRect: %@", NSStringFromCGRect(meshRect) );
	NSLog(@"meshSize: %d x %d", meshWidth, meshHeight );

	NSMutableString* str = [[NSMutableString alloc] initWithCapacity:coordNum*8];
	
	GLfloat* coordPtr = coordinates;
	for (int i=0; i<=meshHeight; i++) {
		for(int j=0; j<=meshWidth; j++) {
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
	
	TextureMesh* mesh = [[TextureMesh alloc] initWithTextureSize:PixelSizeMake(64, 64)];
	[mesh buildInitialMeshWithTileSize:32];
	[mesh print];
	[mesh extendMeshRect:CGRectMake(-0.5, -0.5, 1.5, 1.5)];
	[mesh print];
	
	[mesh resampleMeshForTileSize:8];
	[mesh print];
	
}



@end










