//
//  IndexMesh.m
//  DeformTool
//
//  Created by onegray on 11/23/12.
//
//

#import "IndexMesh.h"

@interface IndexMesh()
{
	GLushort* indices;
	int indexCount;

	int width;
	int height;
	int rowStride;
}

@end

@implementation IndexMesh
@synthesize indices, indexCount;
@synthesize width, height, rowStride;


+(IndexMesh*) indexMeshWithWidth:(int)w maxHeight:(int)mh rowStride:(int)rs
{
	//int maxIndex = h*rs + w;
	int maxHeight = (USHRT_MAX-w)/rs;
	int h = MIN(mh, maxHeight);
	return [[self alloc] initWithWidth:w height:h rowStride:rs];
}

-(id) initWithWidth:(int)w height:(int)h rowStride:(int)rs
{
	NSLog(@"IndexMesh initWithWidth:%d height:%d rowStride:%d", w, h, rs);
	
	self = [super init];
	if(self) {
		
		width = w;
		height = h;
		rowStride = rs;
		
		indexCount = height*(width+1)*2;
		indices = malloc(indexCount*sizeof(GLushort));
		GLushort* pi = indices;
		
		for(int i=0; i<height; i++)
		{
			for(int j=0; j<=width; j++)
			{
				*pi++ = i*rowStride + j;
				*pi++ = (i+1)*rowStride +j;
			}
			
			i++;
			if(i==height)
				break;
			
			for(int j=width; j>=0; j--)
			{
				*pi++ = (i+1)*rowStride + j;
				*pi++ = i*rowStride + j;
			}
		}
		NSAssert(indexCount==(pi-indices), @"Invalid indexCount");
	}
	return self;
}

-(int) indexCountForMeshHeight:(int)h
{
	return h*(width+1)*2;
}


-(void) dealloc
{
	if(indices) {
		free(indices);
	}
}

@end
