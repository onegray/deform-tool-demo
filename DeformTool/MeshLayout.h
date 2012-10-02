//
//  MeshLayout.h
//  DeformTool
//
//  Created by onegray on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

struct MeshLayout {
	int x;
	int y;
	int width;
	int height;
};
typedef struct MeshLayout MeshLayout;


MeshLayout MeshLayoutMake(int x, int y, int width, int height);
BOOL MeshLayoutEqualToLayout(MeshLayout l1, MeshLayout l2);
BOOL MeshLayoutContainsLayout(MeshLayout l1, MeshLayout l2);
MeshLayout MeshLayoutUnion(MeshLayout l1, MeshLayout l2);
