//
//  BrushView.m
//  DeformTool
//
//  Created by onegray on 12/1/12.
//
//

#import "BrushView.h"

@implementation BrushView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGRect r = CGRectInset(self.bounds, 2, 2);
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextAddEllipseInRect(context, r);
	CGContextSetFillColorWithColor(context, [[UIColor colorWithWhite:192/255.0 alpha:0.85] CGColor]);
	CGContextFillPath(context);
	
	CGContextAddEllipseInRect(context, r);
	CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:80/255.0 alpha:0.85] CGColor]);
	CGContextSetLineWidth(context, 1.5);
	CGContextStrokePath(context);
}

@end
