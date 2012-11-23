//
//  IndexMesh.h
//  DeformTool
//
//  Created by onegray on 11/23/12.
//
//

#import <Foundation/Foundation.h>

@interface IndexMesh : NSObject

+(IndexMesh*) indexMeshWithWidth:(int)w maxHeight:(int)mh rowStride:(int)rs;
-(id) initWithWidth:(int)w height:(int)h rowStride:(int)rs;

@property (nonatomic, readonly) GLushort* indices;
@property (nonatomic, readonly) int indexCount;

@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;
@property (nonatomic, readonly) int rowStride;

@end
