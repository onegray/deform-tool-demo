//
//  PatternBrush.h
//  DeformTool
//
//  Created by onegray on 1/20/13.
//
//

#import "Brush.h"

@class GLTexture;

@interface PatternBrush : Brush

@property (nonatomic, readonly) GLTexture* patternTexture;

@end
