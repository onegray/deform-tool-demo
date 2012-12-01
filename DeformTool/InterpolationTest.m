//
//  InterpolationTest.m
//  DeformTool
//
//  Created by onegray on 12/1/12.
//
//

#import <Accelerate/Accelerate.h>

#import "InterpolationTest.h"

@interface InterpolationTest()
{
	float* inputVectors;
	MeshLayout inputLayout;
	
	float* lookupVectors;
	int lookupVectorsWidth;
	int lookupVectorsHeight;
	
	float* xFrac;
	float* yFrac;
	float* xIntegers;
	float* yIntegers;
	float* indexes;
	float* xData;
	float* yData;
	float* dataIndices1;
	float* xInterpolation1;
	float* yInterpolation1;
	float* dataIndices2;
	//float* xInterpolation2;
	//float* yInterpolation2;
}

@end


@implementation InterpolationTest

-(void)setInputVectors:(float*)v layout:(MeshLayout)l
{
	inputVectors = v;
	inputLayout = l;
}

-(void)setLookupVectors:(float*)v width:(int)w height:(int)h
{
	lookupVectors = v;
	lookupVectorsWidth = w;
	lookupVectorsHeight = h;
	
	int lookupVectorsNum = lookupVectorsWidth*lookupVectorsHeight;

	xFrac = (float*)malloc(lookupVectorsNum*sizeof(float));
	yFrac = (float*)malloc(lookupVectorsNum*sizeof(float));
	xIntegers = (float*)malloc(lookupVectorsNum*sizeof(float));
	yIntegers = (float*)malloc(lookupVectorsNum*sizeof(float));
	indexes = (float*)malloc(lookupVectorsNum*sizeof(float));
	xData = (float*)malloc(lookupVectorsNum*sizeof(float)*4);
	yData = (float*)malloc(lookupVectorsNum*sizeof(float)*4);
	dataIndices1 = (float*)malloc(lookupVectorsNum*sizeof(float)*2);
	xInterpolation1 = (float*)malloc(lookupVectorsNum*sizeof(float)*2);
	yInterpolation1 = (float*)malloc(lookupVectorsNum*sizeof(float)*2);
	dataIndices2 = (float*)malloc(lookupVectorsNum*sizeof(float));
	//xInterpolation2 = (float*)malloc(lookupVectorsNum*sizeof(float));
	//yInterpolation2 = (float*)malloc(lookupVectorsNum*sizeof(float));
}

-(void) interpolate_DSP:(float*)resultVectors
{
	int lookupVectorsNum = lookupVectorsWidth*lookupVectorsHeight;
	float inputVectorRowStride = inputLayout.width+1;
	float inputVectorRowStride2 = inputVectorRowStride*2;
	
	float scalar2 = 2.0;
	float scalar_2 = -2.0;
	float scalar0 = 0.0;
	float scalar4 = 4.0;

	CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
	
	vDSP_vfrac(lookupVectors, 2, xFrac, 1, lookupVectorsNum);
	//[self printArray1:xFrac width:deformWidth height:deformHeight];
	vDSP_vsub(xFrac, 1, lookupVectors, 2, xIntegers, 1, lookupVectorsNum);
	//[self printArray1:xIntegers width:deformWidth height:deformHeight];
	
	vDSP_vfrac(lookupVectors+1, 2, yFrac, 1, lookupVectorsNum);
	//[self printArray1:yFrac width:deformWidth height:deformHeight];
	vDSP_vsub(yFrac, 1, lookupVectors+1, 2, yIntegers, 1, lookupVectorsNum);
	//[self printArray1:yIntegers width:deformWidth height:deformHeight];
	
	vDSP_vsma(yIntegers, 1, &inputVectorRowStride, xIntegers, 1, indexes, 1, lookupVectorsNum);
	vDSP_vsmul(indexes, 1, &scalar2, indexes, 1, lookupVectorsNum);
	//[self printArray1:indexes width:deformWidth height:deformHeight];
	
	vDSP_vindex(inputVectors, indexes, 1, xData, 4, lookupVectorsNum);
	vDSP_vindex(inputVectors+1, indexes, 1, yData, 4, lookupVectorsNum);
	//[self printArray1:xData width:deformWidth*4 height:deformHeight];
	vDSP_vsadd(indexes, 1, &scalar2, indexes, 1, lookupVectorsNum);
	vDSP_vindex(inputVectors, indexes, 1, xData+1, 4, lookupVectorsNum);
	vDSP_vindex(inputVectors+1, indexes, 1, yData+1, 4, lookupVectorsNum);
	//[self printArray1:xData width:deformWidth*4 height:deformHeight];
	vDSP_vsadd(indexes, 1, &inputVectorRowStride2, indexes, 1, lookupVectorsNum);
	vDSP_vindex(inputVectors, indexes, 1, xData+3, 4, lookupVectorsNum);
	vDSP_vindex(inputVectors+1, indexes, 1, yData+3, 4, lookupVectorsNum);
	vDSP_vsadd(indexes, 1, &scalar_2, indexes, 1, lookupVectorsNum);
	vDSP_vindex(inputVectors, indexes, 1, xData+2, 4, lookupVectorsNum);
	vDSP_vindex(inputVectors+1, indexes, 1, yData+2, 4, lookupVectorsNum);
	//[self printArray2:xData width:deformWidth*2 height:deformHeight];
	
	
	vDSP_vramp(&scalar0, &scalar4, dataIndices1, 2, lookupVectorsNum);
	vDSP_vadd(dataIndices1, 2, xFrac, 1, dataIndices1, 2, lookupVectorsNum);
	vDSP_vsadd(dataIndices1, 2, &scalar2, dataIndices1+1, 2, lookupVectorsNum);
	//[self printArray2:dataIndices1 width:deformWidth height:deformHeight];
	
	vDSP_vlint(xData, dataIndices1, 1, xInterpolation1, 1, lookupVectorsNum*2, lookupVectorsNum*4);
	vDSP_vlint(yData, dataIndices1, 1, yInterpolation1, 1, lookupVectorsNum*2, lookupVectorsNum*4);
	//[self printArray2:xInterpolation1 width:deformWidth height:deformHeight];
	
	vDSP_vramp(&scalar0, &scalar2, dataIndices2, 1, lookupVectorsNum);
	vDSP_vadd(dataIndices2, 1, yFrac, 1, dataIndices2, 1, lookupVectorsNum);
	//[self printArray1:dataIndices2 width:deformWidth height:deformHeight];
	
	vDSP_vlint(xInterpolation1, dataIndices2, 1, resultVectors, 2, lookupVectorsNum, lookupVectorsNum*2);
	vDSP_vlint(yInterpolation1, dataIndices2, 1, resultVectors+1, 2, lookupVectorsNum, lookupVectorsNum*2);
	//[self printArray1:xInterpolation2 width:deformWidth height:deformHeight];
	//[self printArray1:yInterpolation2 width:deformWidth height:deformHeight];

	CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();

	NSLog(@"interpolate_DSP time: %f", endTime-startTime);
}

static CGPoint interpolatedVector(CGPoint p, CGPoint* deformVectors, MeshLayout layout)
{
	//if(p.x>=0 && p.x<=layout.width && p.y>=0 && p.y<=layout.height)
	{
		int xi = (int)p.x;
		int yi = (int)p.y;
		
		float dx = p.x - xi;
		float dy = p.y - yi;
		
		int rowSize = layout.width+1;
		int index = yi*rowSize + xi;
		
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
		
		return CGPointMake(vx, vy);
	}
	//return CGPointMake(0, 0);
}

-(void) interpolate_C:(float*)resultVectors
{
	int lookupVectorsNum = lookupVectorsWidth*lookupVectorsHeight;
	CGPoint* vPtr = (CGPoint*)lookupVectors;
	CGPoint* vDst = (CGPoint*)resultVectors;
	
	CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
	
	for(int i=0; i<lookupVectorsNum; i++) {
		*vDst++ = interpolatedVector(*vPtr++, (CGPoint*)inputVectors, inputLayout);
	}
	
	CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
	
	NSLog(@"interpolate_C time: %f", endTime-startTime);
	
}




+(void) printArray2:(float*)v width:(int)w height:(int)h
{
	NSMutableString* str = [NSMutableString stringWithCapacity:(12*w+1)*h+2];
	[str appendString:@"\n"];
	for(int i=0; i<h; i++) {
		for(int j=0; j<w; j++) {
			float* p = &v[i*w*2 + j*2];
			[str appendFormat:@"\t%05.2f,%05.2f", p[0], p[1]];
		}
		[str appendString:@"\n"];
	}
	NSLog(@"%@", str);
}

+(void) printArray1:(float*)v width:(int)w height:(int)h
{
	NSMutableString* str = [NSMutableString stringWithCapacity:(6*w+1)*h+2];
	[str appendString:@"\n"];
	for(int i=0; i<h; i++) {
		for(int j=0; j<w; j++) {
			float x = v[i*w + j];
			[str appendFormat:@"\t%05.2f", x];
		}
		[str appendString:@"\n"];
	}
	NSLog(@"%@", str);
	
}

+(void) test
{
	MeshLayout layout = MeshLayoutMake(0, 0, 250, 250);
	float* vectors = (float*)malloc((layout.width+1)*(layout.height+1)*sizeof(float)*2);
	for(int i=0; i<=layout.height; i++) {
		for(int j=0; j<=layout.width; j++) {
			vectors[i*(layout.width+1)*2 + j*2] = i*10+j;
			vectors[i*(layout.width+1)*2 + j*2+1] = i*10+j;
		}
	}
	
	//[self printArray2:vectors width:layout.width+1 height:layout.height+1];
	
	
	int left = 100; int right = 200;
	int top = 100; int bottom = 200;
	int deformWidth = right-left+1;
	int deformHeight = bottom - top+1;
	
	float* deformArea = (float*)malloc(deformWidth*deformHeight*sizeof(float)*2);
	for(int i=0; i<deformHeight; i++) {
		for(int j=0; j<deformWidth; j++) {
			deformArea[i*deformWidth*2 + j*2] = 2 + 0.25*i;
			deformArea[i*deformWidth*2 + j*2 +1] = 1 + 0.5;
		}
	}
	
	//[self printArray2:deformArea width:deformWidth height:deformHeight];
	
	InterpolationTest* test = [[InterpolationTest alloc] init];
	[test setInputVectors:vectors layout:layout];
	[test setLookupVectors:deformArea width:deformWidth height:deformHeight];

	float* resultVector_DSP = (float*)malloc(deformWidth*deformHeight*sizeof(float)*2);
	[test interpolate_DSP:resultVector_DSP];
	//[self printArray2:resultVector_DSP width:deformWidth height:deformHeight];

	float* resultVector_C = (float*)malloc(deformWidth*deformHeight*sizeof(float)*2);
	[test interpolate_C:resultVector_C];
	//[self printArray2:resultVector_C width:deformWidth height:deformHeight];

	
}




@end
