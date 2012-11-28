//
//  Brush.m
//  DeformTool
//
//  Created by onegray on 11/24/12.
//
//

#import "Brush.h"

#define PPF 44

@implementation Brush
@synthesize fingerSize;
@synthesize scale;
@synthesize pixelSize;

-(id) init
{
	self = [super init];
	if(self) {
		scale = 1.0;
		fingerSize = 1.0;
		pixelSize = fingerSize*scale*PPF;
	}
	return self;
}

-(void) setFingerSize:(float)fs
{
	fingerSize = fs;
	pixelSize = fingerSize*scale*PPF;
}

-(void) setScale:(float)s
{
	scale = s;
	pixelSize = fingerSize*scale*PPF;
}


@end
