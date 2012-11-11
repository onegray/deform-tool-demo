//
//  MeshLayout.m
//  DeformTool
//
//  Created by onegray on 10/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MeshLayout.h"


MeshLayout MeshLayoutMake(int x, int y, int width, int height)
{
	return (MeshLayout){x, y, width, height};
}

BOOL MeshLayoutEqualToLayout(MeshLayout l1, MeshLayout l2)
{
	return l1.x==l2.x && l1.y==l2.y && l1.width==l2.width && l2.height==l2.height;
}

BOOL MeshLayoutContainsLayout(MeshLayout l1, MeshLayout l2)
{
	return l1.x<=l2.x && l1.y<=l2.y && (l1.x+l1.width)>=(l2.x+l2.width) && (l1.y+l1.height)>=(l2.y+l2.height);
}

MeshLayout MeshLayoutUnion(MeshLayout l1, MeshLayout l2)
{
	MeshLayout l;
	l.x = MIN(l1.x, l2.x);
	l.y = MIN(l1.y, l2.y);
	l.width = MAX(l1.x+l1.width, l2.x+l2.width) - l.x;
	l.height = MAX(l1.y+l1.height, l2.y+l2.height) - l.y;
	return l;
}




LayoutWindow LayoutWindowMake(int l, int t, int r, int b)
{
	return (LayoutWindow){l, t, r, b};
}


MeshLayout MeshLayoutFromWindow(LayoutWindow window)
{
	return (MeshLayout){window.left, window.top, window.right-window.left, window.bottom-window.top};
}
