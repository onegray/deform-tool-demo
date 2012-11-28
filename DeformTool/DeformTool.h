//
//  DeformTool.h
//  DeformTool
//
//  Created by onegray on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GLTexture, GLFramebuffer;
@class LayerMesh;
@class DeformBrush;

@interface DeformTool : NSObject
{
	GLFramebuffer* meshFramebuffer;
	
	GLFramebuffer* tempFramebuffer;
	
	GLTexture* brushTexture;
}

-(id) initWithMesh:(LayerMesh*)aMesh;
-(void) applyMoveDeformVector:(CGPoint)force atPoint:(CGPoint)point;

@property (nonatomic, retain) DeformBrush* brush;

@end


#import "DeformTool+TextureMesh.h"
