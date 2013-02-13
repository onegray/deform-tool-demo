//
//  EraseTool.h
//  DeformTool
//
//  Created by onegray on 1/20/13.
//
//

#import <Foundation/Foundation.h>

@class PatternBrush, LayerMesh, GLTexture;

@interface EraseTool : NSObject

- (id)initWithMesh:(LayerMesh*)mesh alphaTexture:(GLTexture*)texture;

-(void) eraseFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint;

-(void) clear;

@property (nonatomic, retain) PatternBrush* brush;

@end
