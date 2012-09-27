//
//  GLView.h
//  DeformTool
//
//  Created by onegray on 9/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAGLContext;
@class GLViewController;

@interface GLView : UIView

@property (nonatomic, readonly) GLViewController* glController;

@end
