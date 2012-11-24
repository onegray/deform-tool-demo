//
//  IndexMeshCache.m
//  DeformTool
//
//  Created by onegray on 11/23/12.
//
//

#import "IndexMeshCache.h"
#import "IndexMesh.h"

#define MAX_WIDTH 200

@interface IndexMeshCache()
{
	int rowStride;
	
	NSMutableArray* cachedObjects;
}
@end


@implementation IndexMeshCache
@synthesize layerMeshLayout;

-(id) initWithLayerLayout:(MeshLayout)layout
{
	self = [super init];
	if(self) {
		layerMeshLayout = layout;
		rowStride = layout.width+1;
		cachedObjects = [[NSMutableArray alloc] initWithCapacity:MAX_WIDTH];
	}
	return self;
}

-(IndexMesh*) meshForWidth:(int)width
{
	NSAssert(width<=layerMeshLayout.width, @"Width is too big");

	//int key = (width+3)/4;
	//width = key*4;
	int key = width;
	
	if(key<[cachedObjects count]) {
		IndexMesh* mesh = [cachedObjects objectAtIndex:key];
		if(mesh.width == width) {
			return mesh;
		}
	}

	IndexMesh* mesh = [IndexMesh indexMeshWithWidth:width maxHeight:width*2 rowStride:(layerMeshLayout.width+1)];
	if(key < [cachedObjects count])
	{
		for(int i=key; i>=0; i--) {
			IndexMesh* m = [cachedObjects objectAtIndex:i];
			if(m.width>width) {
				[cachedObjects replaceObjectAtIndex:i withObject:mesh];
			} else {
				break;
			}
		}
	}
	else
	{
		while( key >= [cachedObjects count] ) {
			[cachedObjects addObject:mesh];
		}
	}
	
	return mesh;
}

-(IndexMesh*) inclusiveMeshForWidth:(int)width maxWidth:(int)maxWidth
{
	NSAssert(width<=maxWidth && maxWidth<=layerMeshLayout.width, @"Width is too big");

	//int key = (width+3)/4;
	//width = key*4;
	//maxWidth = ((maxWidth+3)/4)*4;
	int key = width;

	if(key<[cachedObjects count]) {
		IndexMesh* mesh = [cachedObjects objectAtIndex:key];
		if(mesh.width <= maxWidth) {
			return mesh;
		}
	}

	return [self meshForWidth:maxWidth];
}

-(void) printLast:(int)n
{
	NSMutableString* str = [NSMutableString stringWithCapacity:1000];
	for(int i=MAX([cachedObjects count]-n, 0); i<[cachedObjects count]; i++) {
		IndexMesh* m = [cachedObjects objectAtIndex:i];
		[str appendFormat:@" %d", m.width];
	}
	NSLog(@"%@", str);
}

-(void) print
{
	NSMutableString* str = [NSMutableString stringWithCapacity:1000];
	for(IndexMesh* m in cachedObjects) {
		[str appendFormat:@" %d", m.width];
	}
	NSLog(@"%@", str);
}



+(void) test
{
	IndexMeshCache* cache = [[IndexMeshCache alloc] initWithLayerLayout:MeshLayoutMake(0, 0, 100, 20)];

	[cache meshForWidth:8];
	[cache print];
	
	[cache meshForWidth:4];
	[cache print];
	
	[cache meshForWidth:20];
	[cache print];

	[cache meshForWidth:20];
	[cache print];

	[cache meshForWidth:21];
	[cache print];

	[cache meshForWidth:20];
	[cache print];

	[cache meshForWidth:16];
	[cache print];
	
	
	[cache meshForWidth:5];
	[cache print];
	[cache meshForWidth:15];
	[cache print];
	[cache meshForWidth:12];
	[cache print];
	

	[cache inclusiveMeshForWidth:22 maxWidth:40];
	[cache print];
	
}

@end

















