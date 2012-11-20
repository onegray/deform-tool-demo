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




struct LayoutWindow {
	int left;
	int top;
	int right;
	int bottom;
};
typedef struct LayoutWindow LayoutWindow;

LayoutWindow LayoutWindowMake(int l, int t, int r, int b);
LayoutWindow LayoutWindowIntersection(LayoutWindow w1, LayoutWindow w2);
BOOL LayoutWindowContainsWindow(LayoutWindow w1, LayoutWindow w2);
BOOL LayoutWindowExceedsWindow(LayoutWindow w1, LayoutWindow w2);
LayoutWindow LayoutWindowShiftInsideWindow(LayoutWindow child, LayoutWindow parent);
MeshLayout MeshLayoutFromWindow(LayoutWindow window);
BOOL MeshLayoutContainsWindow(MeshLayout l, LayoutWindow w);
NSString* LayoutWindowDescription(LayoutWindow w);


