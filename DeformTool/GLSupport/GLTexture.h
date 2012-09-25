//
//  Texture.h
//
//  Created by Sergey Nikitenko on 7/24/11.
//  Copyright (c) 2011 Sergey Nikitenk. All rights reserved.
//  Hire me at odesk! ( www.odesk.com/users/~~1bd7ccce67734b51 )
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>

typedef enum {
	kTexture2DPixelFormat_Automatic = 0,
	kTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_A8,
} Texture2DPixelFormat;

typedef struct
{
    CGSize texture_size;
    CGSize content_size;
    Texture2DPixelFormat pixel_format;
    void* data;
} TextureRawData;


BOOL textureDataFromImage(TextureRawData* rawData, CGImageRef image);
void freeTextureData(TextureRawData* texture_data);


@interface GLTexture : NSObject
{
	GLuint textureName;
	CGSize textureSize;
    CGSize contentSize;
	GLfloat	maxS, maxT;
	Texture2DPixelFormat pixelFormat;
}

@property (nonatomic, assign) GLuint textureName;
@property (nonatomic, readonly) CGSize textureSize;
@property (nonatomic, readonly) CGSize contentSize;
@property (nonatomic, readonly) GLfloat	maxS;
@property (nonatomic, readonly) GLfloat	maxT;
@property (nonatomic, readonly) Texture2DPixelFormat pixelFormat;

-(id) initWithImage:(UIImage*)image;
-(id) initWithTextureData:(TextureRawData*)rawData;

-(GLint) releaseTexture;

@end
