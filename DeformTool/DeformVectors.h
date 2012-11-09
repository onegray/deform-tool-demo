//
//  DeformVectors.h
//  DeformTool
//
//  Created by onegray on 11/4/12.
//
//

#import <Foundation/Foundation.h>
#import "MeshLayout.h"

@interface DeformVectors : NSObject

@property (nonatomic, readonly) MeshLayout layout;
@property (nonatomic, readonly) GLfloat* vectors;

-(id) initWithLayout:(MeshLayout)layout;

-(void) extendLayout:(MeshLayout)newLayout;


-(void) print;
+(void) test;

@end
