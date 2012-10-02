//
//  Texture.m
//
//  Created by Sergey Nikitenko on 7/24/11.
//  Copyright (c) 2011 Sergey Nikitenk. All rights reserved.
//  Hire me at odesk! ( www.odesk.com/users/~~1bd7ccce67734b51 )
//

#import "GLTexture.h"


@implementation GLTexture
@synthesize textureName, textureSize, contentSize, maxS, maxT, pixelFormat;

-(id) initWithImage:(UIImage*)image
{
    self = [super init];
    if(self)
    {
        TextureRawData textureRawData;
        if( textureDataFromImage(&textureRawData, image.CGImage) ) 
        {
            self = [self initWithTextureData:&textureRawData];
            freeTextureData(&textureRawData);
        }
        else
        {
			self = nil;
        }
    }
    return self;
}

-(id) initWithTextureData:(TextureRawData*)textureRawData
{
    self = [super init];
    if(self)
    {
		glGenTextures(1, &textureName);
		glBindTexture(GL_TEXTURE_2D, textureName);
        
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		// This is necessary for non-power-of-two textures
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

		
        textureSize = textureRawData->texture_size;
        contentSize = textureRawData->content_size;
        pixelFormat = textureRawData->pixel_format;

        maxS = contentSize.width / textureSize.width;
        maxT = contentSize.height / textureSize.height;
        
		switch(pixelFormat)
        {
			case kTexture2DPixelFormat_RGBA8888:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize.width, textureSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureRawData->data);
				break;
			case kTexture2DPixelFormat_RGB565:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, textureSize.width, textureSize.height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, textureRawData->data);
				break;
			case kTexture2DPixelFormat_A8:
				glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, textureSize.width, textureSize.height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, textureRawData->data);
				break;
			default:
                self = nil;
				[NSException raise:NSInternalInconsistencyException format:@"Unknown texture pixel format"];
		}
    }

    return self;
}

-(GLint) releaseTexture
{
	GLint tex = textureName;
	textureName = 0;
	return tex;
}

- (void) dealloc
{
	if(textureName)
    {
		NSLog(@"GLTexture deleting texture %d", textureName);
        glDeleteTextures(1, &textureName);
    }
}



@end


#define kMaxTextureSize	 2048

static CGSize maxAllowedImageSize(CGSize size)
{
    if( size.width > kMaxTextureSize && size.width >= size.height) 
    {
        return CGSizeMake(kMaxTextureSize, kMaxTextureSize*size.height/size.width);
    }
    
    if( size.height > kMaxTextureSize && size.height > size.width) 
    {
        return CGSizeMake(kMaxTextureSize*size.width/size.height, kMaxTextureSize);
    }
    
    return size;
}

static int PO2(int x)
{
    /*
	if((x != 1) && (x & (x - 1)))
	{
		int i = 1;
		while(i < x)
			i *= 2;
		x = i;
	}
    */

	if( (x == 1) || (x & (x - 1)) )
	{
		int i = 2; // start from '2'
		while(i < x)
			i *= 2;
		x = i;
	}
	return x;
}

static CGSize adjustTextureSize(CGSize size)
{
	return size; // - using even non-power-of-two textures
    //return CGSizeMake(PO2(size.width), PO2(size.height));
}

BOOL textureDataFromImage(TextureRawData* rawData, CGImageRef image)
{
	CGContextRef			context = nil;
	void*					data = nil;
	CGColorSpaceRef			colorSpace;
	CGAffineTransform		transform;
	CGSize					imageSize;
	Texture2DPixelFormat    pixelFormat;    
    
    rawData->data = NULL;
    
    if(!image)
    {
        return NO;
    }
    
	if(CGImageGetColorSpace(image))
    {
        CGImageAlphaInfo info = CGImageGetAlphaInfo(image);
        BOOL hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst));
		if(hasAlpha)
            pixelFormat = kTexture2DPixelFormat_RGBA8888;
		else
			pixelFormat = kTexture2DPixelFormat_RGB565;
	} else  { //NOTE: No colorspace means a mask image
		pixelFormat = kTexture2DPixelFormat_A8;
    }
        
    imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    transform = CGAffineTransformIdentity;
    
    CGSize validImageSize = maxAllowedImageSize(imageSize);
    CGSize textureSize = adjustTextureSize(validImageSize);
    CGFloat k =  validImageSize.width / imageSize.width;
    transform = CGAffineTransformMakeScale(k, k);
    
    imageSize = validImageSize; 
    int width = textureSize.width;
    int height = textureSize.height;
    
    switch(pixelFormat) {		
        case kTexture2DPixelFormat_RGBA8888:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            data = malloc(height * width * 4);
            context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
            CGColorSpaceRelease(colorSpace);
            break;
        case kTexture2DPixelFormat_RGB565:
            colorSpace = CGColorSpaceCreateDeviceRGB();
            data = malloc(height * width * 4);
            context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
            CGColorSpaceRelease(colorSpace);
            break;
            
        case kTexture2DPixelFormat_A8:
            data = malloc(height * width);
            context = CGBitmapContextCreate(data, width, height, 8, width, NULL, kCGImageAlphaOnly);
            break;				
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
    }
    
    
	CGContextClearRect(context, CGRectMake(0, 0, width, height));
	CGContextTranslateCTM(context, 0, height - imageSize.height);
	
	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
        CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
        //Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
        if(pixelFormat == kTexture2DPixelFormat_RGB565) {
            void* tempData = malloc(height * width * 2);
            unsigned int* inPixel32 = (unsigned int*)data;
            unsigned short*	outPixel16 = (unsigned short*)tempData;
            for(int i = 0; i < width * height; ++i, ++inPixel32)
                *outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
            free(data);
            data = tempData;
        }
    
    
	CGContextRelease(context);
	
    rawData->texture_size = textureSize;
    rawData->content_size = imageSize;
    rawData->pixel_format = pixelFormat;
    rawData->data = data;
    
    return YES;
}


void freeTextureData(TextureRawData* texture_data)
{
    free(texture_data->data);
    texture_data->data = NULL;
}





