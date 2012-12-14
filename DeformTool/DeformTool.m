//
//  DeformTool.m
//  DeformTool
//
//  Created by onegray on 10/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeformTool.h"
#import "LayerMesh.h"
#import "DeformBrush.h"

@interface DeformTool()
{
	LayerMesh* mesh;
	
	int deformAreaRadius;
	CGPoint* deformAreaVectors;

}


@end


@implementation DeformTool

-(id) initWithMesh:(LayerMesh*)aMesh
{
	self = [super init];
	if(self) {
		mesh = aMesh;
	
		deformAreaRadius = 32;
		
		int deformAreaBufSize = (2*deformAreaRadius+1)*(2*deformAreaRadius+1)*sizeof(CGPoint);
		deformAreaVectors = (CGPoint*)malloc(deformAreaBufSize);
		memset(deformAreaVectors, 0, deformAreaBufSize);
		
		
	}
	return self;
}

-(void) setBrush:(DeformBrush *)b
{
	_brush = b;
	
	if(_brush.pixelSize!=deformAreaRadius) {
		if(deformAreaVectors)
			free(deformAreaVectors);
		
		deformAreaRadius = _brush.pixelSize;
		int deformAreaBufSize = (2*deformAreaRadius+1)*(2*deformAreaRadius+1)*sizeof(CGPoint);
		deformAreaVectors = (CGPoint*)malloc(deformAreaBufSize);
		memset(deformAreaVectors, 0, deformAreaBufSize);
	}
}

static CGPoint interpolatedVector(CGPoint p, CGPoint* deformVectors, MeshLayout layout)
{
	if(p.x>=0 && p.x<layout.width && p.y>=0 && p.y<layout.height)
	{
		int xi = (int)p.x;
		int yi = (int)p.y;
		
		float dx = p.x - xi;
		float dy = p.y - yi;
		
		int rowSize = layout.width+1;
		int index = yi*rowSize + xi;
		
		NSCAssert( (index+rowSize+1) < rowSize*(layout.height+1), @"interpolatedVector: Invalid point index");
		
		CGPoint v00 = deformVectors[index];
		CGPoint v10 = deformVectors[index+1];
		CGPoint v01 = deformVectors[index+rowSize];
		CGPoint v11 = deformVectors[index+rowSize+1];
		
		float mx0 = v00.x + (v10.x-v00.x) * dx;
		float mx1 = v01.x + (v11.x-v01.x) * dx;
		float my0 = v00.y + (v10.y-v00.y) * dx;
		float my1 = v01.y + (v11.y-v01.y) * dx;
		
		float vx = mx0 + dy * (mx1 - mx0);
		float vy = my0 + dy * (my1 - my0);
		
		NSCAssert( !isnan(vx) && !isnan(vy), @"interpolatedVector: Invalid result point values");
		
		return CGPointMake(vx, vy);
	}
	return CGPointMake(0, 0);
}

// Inline assembler optimization   http://stackoverflow.com/questions/11161237/fast-arm-neon-memcpy
// http://hilbert-space.de/
// http://infocenter.arm.com/help/index.jsp?topic=/com.arm.doc.faqs/ka13544.html


-(void) applyMoveDeformVector:(CGPoint)force atPoint:(CGPoint)point
{
	int tileSize = mesh.tileSize;
	MeshLayout layout = mesh.layout;
	CGPoint* deformVectors = (CGPoint*)mesh.vectorsAbsolutePointer;
	int r = deformAreaRadius/tileSize;
	int r2 = r*r;

	CGPoint p = CGPointMake( point.x/tileSize - layout.x, point.y/tileSize - layout.y);
	
	int cx = (int)p.x;
	int cy = (int)p.y;
	
	//int x0 =  -MIN(r, cx); // cx - r >= 0 ? -r : -cx;
	//int y0 =  -MIN(r, cy); // cy - r >= 0 ? -r : -cy;
	//int x1 = MIN(r+1, layout.width - cx);  // cx + r1 <= layout.width ? r1 : (layout.width - cx)
	//int y1 = MIN(r+1, layout.height - cy); // cy + r1 <= layout.height ? r1 : (layout.height - cy)

	int left = MAX(cx-r, 0);
	int top = MAX(cy-r, 0);
	int right = MIN(cx+r+1, layout.width);
	int bottom = MIN(cy+r+1, layout.height);
	
	for (int yi = top; yi <= bottom; yi++)
	{
		for (int xi = left; xi <= right; xi++)
		{
			float dx = xi-p.x;
			float dy = yi-p.y;
			float d2 = dx*dx + dy*dy;
			if(d2<=r2) {

				//float deformValue = 0.9 * powf(( cos(sqrt((double)d2/r2)*M_PI)+1.0)*0.5, 0.7);				
				int valueIndex = _brush.valueBufferLength * sqrt(d2)/r;
				float deformValue = _brush.valueBuffer[valueIndex];
				
				float nvx = deformValue*force.x;
				float nvy = deformValue*force.y;

				CGPoint v = interpolatedVector(CGPointMake(xi+nvx/tileSize, yi+nvy/tileSize), deformVectors, layout);
				v.x += nvx/mesh.textureContentSize.widthPixels;
				v.y += nvy/mesh.textureContentSize.heighPixels;
				
				int ax = xi-left;
				int ay = yi-top;
				int aw = right-left;
				deformAreaVectors[ay*aw + ax] = v;
			}
		}
	}

	for (int yi = top; yi <= bottom; yi++)
	{
		for (int xi = left; xi <= right; xi++)
		{
			float dx = xi-p.x;
			float dy = yi-p.y;
			float d2 = dx*dx + dy*dy;
			if(d2<=r2) {
				int ax = xi-left;
				int ay = yi-top;
				int aw = right-left;
				CGPoint v = deformAreaVectors[ay*aw + ax];
				deformVectors[yi*(layout.width+1) + xi] = v;
			}
		}
	}
	
	
}



@end
















