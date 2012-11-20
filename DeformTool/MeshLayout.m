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

LayoutWindow LayoutWindowIntersection(LayoutWindow w1, LayoutWindow w2)
{
	return (LayoutWindow){MAX(w1.left, w2.left), MAX(w1.top, w2.top), MIN(w1.right, w2.right), MIN(w1.bottom, w2.bottom)};
}

BOOL LayoutWindowContainsWindow(LayoutWindow w1, LayoutWindow w2)
{
	return w1.left<=w2.left && w1.top<=w2.top && w1.right>=w2.right && w1.bottom>=w2.bottom;
}

BOOL LayoutWindowBiggerThanWindow(LayoutWindow w1, LayoutWindow w2)
{
	return (w1.right-w1.left > w2.right-w2.left) && (w1.bottom-w1.top > w2.bottom-w2.top);
}

LayoutWindow LayoutWindowShiftInsideWindow(LayoutWindow child, LayoutWindow parent)
{
	NSCAssert(!LayoutWindowBiggerThanWindow(child, parent), @"Parent is too small");
	
	if(child.left < parent.left) {
		int w = child.right-child.left;
		child.left = parent.left;
		child.right = child.left + w;
	} else if(child.right > parent.right) {
		int w = child.right-child.left;
		child.right = parent.right;
		child.left = child.right - w;
	}
	
	if(child.top < parent.top) {
		int h = child.bottom-child.top;
		child.top = parent.top;
		child.bottom = child.top + h;
	} else if(child.bottom > parent.bottom) {
		int h = child.bottom-child.top;
		child.bottom = parent.bottom;
		child.top = child.bottom - h;
	}
	
	return child;
}

MeshLayout MeshLayoutFromWindow(LayoutWindow window)
{
	return (MeshLayout){window.left, window.top, window.right-window.left, window.bottom-window.top};
}

BOOL MeshLayoutContainsWindow(MeshLayout l, LayoutWindow w)
{
	return l.x<=w.left && l.y<=w.top && (l.x+l.width)>=w.right && (l.y+l.height)>=w.bottom;
}


