//
//  IndexMeshCache.h
//  DeformTool
//
//  Created by onegray on 11/23/12.
//
//

#import <Foundation/Foundation.h>
#import "MeshLayout.h"

@class IndexMesh;
@interface IndexMeshCache : NSObject

@property (nonatomic, readonly) MeshLayout layerMeshLayout;

-(id) initWithLayerLayout:(MeshLayout)layout;

-(IndexMesh*) meshForWidth:(int)width;
-(IndexMesh*) inclusiveMeshForWidth:(int)width maxWidth:(int)maxWidth;


-(void) printLast:(int)n;
-(void) print;
+(void) test;

@end
