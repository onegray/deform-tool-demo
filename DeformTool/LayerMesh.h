//
//  LayerMesh.h
//  DeformTool
//
//  Created by onegray on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TextureMesh.h"


struct LayoutSize {
	int width;
	int height;
};
typedef struct LayoutSize LayoutSize;




@interface LayerMesh : NSObject

-(id) initWithTextureSize:(PixelSize)ts;

@property (nonatomic, readonly) GLfloat* vertices;
@property (nonatomic, readonly) int vertNum;

@property (nonatomic, readonly) GLushort* indices;
@property (nonatomic, readonly) int indexCount;

@property (nonatomic, readonly) GLfloat* texCoords;
@property (nonatomic, readonly) int texCoordNum;



@end
