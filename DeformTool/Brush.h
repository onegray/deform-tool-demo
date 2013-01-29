//
//  Brush.h
//  DeformTool
//
//  Created by onegray on 11/24/12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
	FingerSizeNone,
	FingerSize033 = 33, // 1/3
	FingerSize050 = 50, // 1/2
	FingerSize066 = 66, // 2/3
	FingerSize100 = 100, // 1
	FingerSize150 = 150, // 1 1/2
	FingerSize200 = 200, // 2
} FingerSize;


@interface Brush : NSObject

@property (nonatomic, assign) float fingerSize;
@property (nonatomic, assign) float scale;

@property (nonatomic, readonly) int pixelSize;

-(void) updatePixelSize;

@end
