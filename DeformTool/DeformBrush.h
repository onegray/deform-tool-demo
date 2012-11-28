//
//  DeformBrush.h
//  DeformTool
//
//  Created by onegray on 11/25/12.
//
//

#import "Brush.h"

@interface DeformBrush : Brush
{
	float* valueBuffer;
	int valueBufferLength;
}

@property (nonatomic, readonly) float* valueBuffer;
@property (nonatomic, readonly) int valueBufferLength;

+(void) test;

@end
