//
//  DeformTool.h
//  DeformTool
//
//  Created by onegray on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GLTexture, GLFramebuffer;
@interface DeformTool : NSObject
{
	GLFramebuffer* meshFramebuffer;
	
	GLFramebuffer* tempFramebuffer;
	
	GLTexture* brushTexture;
}


@end


#import "DeformTool+TextureMesh.h"
