//
//  DeformBrush.m
//  DeformTool
//
//  Created by onegray on 11/25/12.
//
//

#import "DeformBrush.h"
#import <Accelerate/Accelerate.h>


#import "DeformBrush.h"
#import <Accelerate/Accelerate.h>

@implementation DeformBrush
@synthesize valueBuffer, valueBufferLength;

-(id) init
{
	self = [super init];
	if(self) {
		valueBufferLength = 1024;
		valueBuffer = (float*)malloc(valueBufferLength*sizeof(float));
		
		/*
		CFAbsoluteTime start1 = CFAbsoluteTimeGetCurrent();
		if(!vvcosf) {
			return nil;
		}
		
		float v0 = 0.0;
		float dv  = M_PI/(valueBufferLength-1);
		vDSP_vramp(&v0, &dv, valueBuffer, 1, valueBufferLength);
			
		vvcosf(valueBuffer, valueBuffer, &valueBufferLength); // iOS 5.0
		
		float float0_5 = 0.5;
		float float0_5_ = 0.5;
		vDSP_vsmsa(valueBuffer, 1, &float0_5, &float0_5_, valueBuffer, 1, valueBufferLength); // Vector scalar multiply and scalar add;
		
		float float0_6 = 0.6;
		float* constantBuf = (float*)malloc(valueBufferLength*sizeof(float));
		vDSP_vfill(&float0_6, constantBuf, 1, valueBufferLength);
		vvpowf(valueBuffer, constantBuf, valueBuffer, &valueBufferLength); // iOS 5.0
		free(constantBuf);

		CFAbsoluteTime end1 = CFAbsoluteTimeGetCurrent();
		*/
		
		for (int x = 0; x < valueBufferLength; x++)
		{
			float y = 0.5 + cosf(x*M_PI/(valueBufferLength-1)) / 2;
			y = powf(y, 0.6);
			valueBuffer[x] = y;

			//NSLog(@"%@ = %@", [NSNumber numberWithFloat:valueBuffer[x]], [NSNumber numberWithFloat:y]);
		}

		//CFAbsoluteTime end2 = CFAbsoluteTimeGetCurrent();
		
		//NSLog(@"vDSP:%@  regular:%@", [NSNumber numberWithDouble:end1-start1], [NSNumber numberWithDouble:end2-start1]);

	}
	return self;
}

-(void) dealloc
{
	if(valueBuffer) {
		free(valueBuffer);
	}
}

#define MAX_DEFORM_AREA_RADIUS 50

+(void) test
{
	//[[DeformBrush alloc] init];
	
	/*
	CGFloat filter[MAX_DEFORM_AREA_RADIUS];
	for (int i = 0; i < MAX_DEFORM_AREA_RADIUS; i++)
    {
		int x = i;
		float y = 0.5 + sin(x*M_PI/MAX_DEFORM_AREA_RADIUS + M_PI_2) / 2;
		filter[i] = y;
		//filter[i] = powf ((cos (sqrt((double) i / MAX_DEFORM_AREA_RADIUS) * M_PI) + 1) * 0.5, 0.7);
    }

	NSMutableString* str = [NSMutableString stringWithCapacity:1000];
	for(int i=0; i<MAX_DEFORM_AREA_RADIUS; i++) {
		[str appendFormat:@" %.2f", filter[i]];
	}
	NSLog(@"%@", str);
	*/
}

@end
