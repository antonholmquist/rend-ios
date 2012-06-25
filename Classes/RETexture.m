/*
 * Rend
 *
 * Author: Anton Holmquist
 * Copyright (c) 2012 Anton Holmquist All rights reserved.
 * http://antonholmquist.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "RETexture.h"
#import "RECache.h"
#import "REGLStateManager.h"


#define PVR_TEXTURE_FLAG_TYPE_MASK	0xff

static char gPVRTexIdentifier[4] = "PVR!";

enum {
	kPVRTextureFlagTypePVRTC_2 = 24,
	kPVRTextureFlagTypePVRTC_4
};

typedef struct _PVRTexHeader {
	uint32_t headerLength;
	uint32_t height;
	uint32_t width;
	uint32_t numMipmaps;
	uint32_t flags;
	uint32_t dataLength;
	uint32_t bpp;
	uint32_t bitmaskRed;
	uint32_t bitmaskGreen;
	uint32_t bitmaskBlue;
	uint32_t bitmaskAlpha;
	uint32_t pvrTag;
	uint32_t numSurfs;
} PVRTexHeader;

typedef enum {
	OGL_RGBA_4444 = 0x10,
	OGL_RGBA_5551,
	OGL_RGBA_8888,
	OGL_RGB_565,
	OGL_RGB_555,
	OGL_RGB_888,
	OGL_I_8,
	OGL_AI_88,
	OGL_PVRTC2,
	OGL_PVRTC4
} PVRPixelType;




/* RETextureAsset
 *
 * Internal structure containing
 *
 * This is useful, because we can reuse for instance pvr unpacking code for both texture2d and cube map textures.   
 * */

typedef enum {
    kRETextureAssetTypeUIImage,
    kRETextureAssetTypeCVImageBufferRef,
    kRETextureAssetTypePVRData,
    kRETextureAssetTypeRawData,
} RETextureAssetType;
 
// Which of these are set is based on type
typedef struct {
    RETextureAssetType type;
    UIImage *image;
    CVImageBufferRef imageBuffer;
    NSData *pvrData;
    
    int rawWidth, rawHeight; 
    int rawInternalFormat, rawFormat, rawType;
    void *rawPixels;
} RETextureAsset;

typedef struct {
    GLenum target;
    GLint minFilter;
    GLint magFilter;
    GLint wrapS;
    GLint wrapT;
} RETextureAssetLoadOptions;



@interface RETexture ()

// Loads asset
- (void)load:(RETextureAsset)asset;
- (void)load:(RETextureAsset)asset options:(RETextureAssetLoadOptions)options;

@end

@implementation RETexture

@synthesize texture = texture_;
@synthesize contentSize = contentSize_;

- (id)init {
    return [self initWithTarget:GL_TEXTURE_2D];
}

- (id)initWithTarget:(GLenum)target {
    if ((self = [super init])) {
        glGenTextures(1, &texture_);
        target_ = target;
        
    } return self;
}

- (id)initOnTexture:(GLint)texture {
    if ((self = [super init])) {
        texture_ = texture;
        target_ = GL_TEXTURE_2D;
        
    } return self;
}

+ (BOOL)deviceSupportsCVOpenGLESTextureCache {
    return NO; //[[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0;
}

- (void)dealloc {
    glDeleteTextures(1, &texture_);
    
    [super dealloc];
}

- (void)bind {
    [self bind:GL_TEXTURE0];
}

- (void)bind:(GLenum)textureUnit {
    [[REGLStateManager sharedManager] setActiveTexture:textureUnit];
    glBindTexture(target_, texture_);
}

+ (void)unbind {
    
    REGLStateManager *stateManager = [REGLStateManager sharedManager];
    
    [stateManager setActiveTexture:GL_TEXTURE0];
    glBindTexture(GL_TEXTURE_2D, 0);
    [stateManager setActiveTexture:GL_TEXTURE1];
    glBindTexture(GL_TEXTURE_2D, 0);
    [stateManager setActiveTexture:GL_TEXTURE2];
    glBindTexture(GL_TEXTURE_2D, 0);
    [stateManager setActiveTexture:GL_TEXTURE3];
    glBindTexture(GL_TEXTURE_2D, 0);
    [stateManager setActiveTexture:GL_TEXTURE4];
    glBindTexture(GL_TEXTURE_2D, 0);
    [stateManager setActiveTexture:GL_TEXTURE5];
    glBindTexture(GL_TEXTURE_2D, 0);
    [stateManager setActiveTexture:GL_TEXTURE6];
    glBindTexture(GL_TEXTURE_2D, 0);
    [stateManager setActiveTexture:GL_TEXTURE7];
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)load:(RETextureAsset)asset {
    RETextureAssetLoadOptions options;
    options.target = GL_TEXTURE_2D;
    options.minFilter = GL_LINEAR;
    options.magFilter = GL_LINEAR;
    options.wrapS = GL_CLAMP_TO_EDGE;
    options.wrapT = GL_CLAMP_TO_EDGE;
    [self load:asset options:options];
}

- (void)load:(RETextureAsset)asset options:(RETextureAssetLoadOptions)options {
    
    // Always bind to default texture unit when loading. It can be set to other texture unit later.
    [self bind];
    
    glTexParameteri(target_, GL_TEXTURE_MIN_FILTER, options.minFilter);
    glTexParameteri(target_, GL_TEXTURE_MAG_FILTER, options.magFilter);
    glTexParameteri(target_, GL_TEXTURE_WRAP_S, options.wrapS);
    glTexParameteri(target_, GL_TEXTURE_WRAP_T, options.wrapT);
    
    //  kRETextureAssetTypeUIImage
    if (asset.type == kRETextureAssetTypeUIImage) {
        
        UIImage *image = asset.image;
        
        GLuint width = CGImageGetWidth(image.CGImage);
        GLuint height = CGImageGetHeight(image.CGImage);
        //GLuint bpc = CGImageGetBitsPerComponent(image.CGImage);
        //GLuint bpr = CGImageGetBytesPerRow(image.CGImage);
        //GLuint bpp = CGImageGetBitsPerPixel(image.CGImage);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        //void *imageData = malloc(height * width * bpp / 8);
        void *imageData = malloc(height * width * 4);
        CGContextRef context = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
        //CGContextRef context = CGBitmapContextCreate( imageData, width, height, bpc, bpr, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
        CGContextTranslateCTM (context, 0, height);
        CGContextScaleCTM (context, 1.0, -1.0);
        CGColorSpaceRelease( colorSpace );
        CGContextClearRect(context, CGRectMake(0, 0, width, height));
        CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
        
        glTexImage2D(options.target, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
 
        CGContextRelease(context);
        
        free(imageData);
        
        contentSize_ = CGSizeMake(width, height);
    }
    
    // CVImageBufferRef

    if (asset.type == kRETextureAssetTypeCVImageBufferRef) {
        
        CVPixelBufferLockBaseAddress(asset.imageBuffer, 0);
        
            /*
        
        if ([[self class] deviceSupportsCVOpenGLESTextureCache]) {
            
            if (!cvTextureCacheRef_) {
                 CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, (__bridge void *)[EAGLContext currentContext], NULL, &cvTextureCacheRef_);
                if (err) {
                    NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreate %d");
                }
            } else {
                if (cvTextureRef_) CFRelease(cvTextureRef_), cvTextureRef_ = 0;
                if (cvTextureCacheRef_) CVOpenGLESTextureCacheFlush(cvTextureCacheRef_, 0);
            }
            
            
        
            CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, 
                                                         cvTextureCacheRef_,
                                                         asset.imageBuffer,
                                                         NULL,
                                                         GL_TEXTURE_2D,
                                                         GL_RGBA,
                                                         CVPixelBufferGetWidth(asset.imageBuffer),
                                                         CVPixelBufferGetHeight(asset.imageBuffer),
                                                         GL_BGRA,
                                                         GL_UNSIGNED_BYTE,
                                                         0,
                                                         &cvTextureRef_);
            
            // We must redo this here, since binding requires cvTextureCacheRef_
            [self bind];
            glTexParameteri(target_, GL_TEXTURE_MIN_FILTER, options.minFilter);
            glTexParameteri(target_, GL_TEXTURE_MAG_FILTER, options.magFilter);
            glTexParameteri(target_, GL_TEXTURE_WRAP_S, options.wrapS);
            glTexParameteri(target_, GL_TEXTURE_WRAP_T, options.wrapT);
            
             
            
            if (!cvTextureRef_ || err) {
                NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err);  
            }
        } else {
            
            
            
        
        }
        
        
     
     */
    
        CVPixelBufferUnlockBaseAddress(asset.imageBuffer, 0);
        
        int width = CVPixelBufferGetWidth(asset.imageBuffer);
        int height = CVPixelBufferGetHeight(asset.imageBuffer);
        
        glTexImage2D(options.target, 
                     0, 
                     GL_RGBA, 
                     width,
                     height,
                     0,
                     GL_BGRA,
                     GL_UNSIGNED_BYTE,
                     CVPixelBufferGetBaseAddress(asset.imageBuffer));
        
        contentSize_ = CGSizeMake(width, height);
        
    }
    
    
    
    // kRETextureAssetTypePVRData
    if (asset.type == kRETextureAssetTypePVRData) {
        
        NSData *data = asset.pvrData;
        
        BOOL success = FALSE;
        PVRTexHeader *header = NULL;
        uint32_t flags, pvrTag;
        uint32_t dataLength = 0, dataOffset = 0, dataSize = 0;
        uint32_t blockSize = 0, widthBlocks = 0, heightBlocks = 0;
        uint32_t width = 0, height = 0;
        uint8_t *bytes = NULL;
        uint32_t formatFlags;
        
        header = (PVRTexHeader *)[data bytes];
        
        pvrTag = CFSwapInt32LittleToHost(header->pvrTag);
        
        
        if (gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
            gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
            gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
            gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff))
        {
            NSLog(@"RETexture2D!! Unsupported stuff? Makes no sense from here..");
            //return;
        }
         
        
        flags = CFSwapInt32LittleToHost(header->flags);
        formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;
        
        
        BOOL hasAlpha = CFSwapInt32LittleToHost(header->bitmaskAlpha) ? TRUE : FALSE;
        
        GLuint format;
        GLuint type;
        BOOL compressed;
        int bitsPerPixel;
        
        // MORE HERE: https://github.com/nicklockwood/GLView/blob/master/GLView/GLImage.m
        
        switch (formatFlags) {
            case OGL_RGBA_8888:
                compressed = NO;
                bitsPerPixel = 32;
                format = GL_RGBA;
                type = GL_UNSIGNED_BYTE;
                break;
            case OGL_RGBA_4444:
                compressed = NO;
                bitsPerPixel = 16;
                format = GL_RGBA;
                type = GL_UNSIGNED_SHORT_4_4_4_4;
                break;
            case OGL_I_8:
                compressed = NO;
                bitsPerPixel = 8;
                format = GL_ALPHA;
                type = GL_UNSIGNED_BYTE;
                break;
            case OGL_PVRTC2:
                compressed = YES;
                bitsPerPixel = 2;
                format = hasAlpha? GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG: GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG;
                type = 0;
                break;
                
            case OGL_PVRTC4:
                compressed = YES;
                bitsPerPixel = 4;
                format = hasAlpha? GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG: GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG;
                type = 0;
                break;
                
            default:
                NSLog(@"FATAL ERROR! Unrecognised PVR image format: %i", header->flags & 0xff);
                break;
        }
        
        //if (formatFlags == kPVRTextureFlagTypePVRTC_4 || formatFlags == kPVRTextureFlagTypePVRTC_2)
            
            // Stuff that we're instance variables in last implementation
            NSMutableArray *imageData = [NSMutableArray array];
            //GLenum internalFormat;
            
            
            /*
            if (formatFlags == kPVRTextureFlagTypePVRTC_4)
                internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
            else if (formatFlags == kPVRTextureFlagTypePVRTC_2)
                internalFormat = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
             */
            
            width = CFSwapInt32LittleToHost(header->width);
            height = CFSwapInt32LittleToHost(header->height);
            contentSize_ = CGSizeMake(width, height);
            
            
            dataLength = CFSwapInt32LittleToHost(header->dataLength);
            //NSLog(@"dataLength: %d", dataLength);
            
            bytes = ((uint8_t *)[data bytes]) + sizeof(PVRTexHeader);
        
            int level = 0;
            
            // Calculate the data size for each texture level and respect the minimum number of blocks
            while (dataOffset < dataLength)
            {
                if (formatFlags == kPVRTextureFlagTypePVRTC_4)
                {
                    blockSize = 4 * 4; // Pixel by pixel block size for 4bpp
                    widthBlocks = width / 4;
                    heightBlocks = height / 4;
                }
                else if (formatFlags == kPVRTextureFlagTypePVRTC_2)
                {
                    blockSize = 8 * 4; // Pixel by pixel block size for 2bpp
                    widthBlocks = width / 8;
                    heightBlocks = height / 4;
                } 
                
                // Clamp to minimum number of blocks
                if (widthBlocks < 2)
                    widthBlocks = 2;
                if (heightBlocks < 2)
                    heightBlocks = 2;
                
                
                if (formatFlags == kPVRTextureFlagTypePVRTC_4 || formatFlags == kPVRTextureFlagTypePVRTC_2) {
                    dataSize = widthBlocks * heightBlocks * ((blockSize  * bitsPerPixel) / 8);
                } else {
                    dataSize = (bitsPerPixel / 8.0) * width * height;
                }
                
                NSData *data = [NSData dataWithBytes:bytes+dataOffset length:dataSize];
                
                dataOffset += dataSize;

                if (compressed) {
                    glCompressedTexImage2D(options.target, level, format, width, height, 0, [data length], [data bytes]);
                }
                else {
                    glTexImage2D(options.target, level, format, width, height, 0, format, type, [data bytes]);
                }
                
                level++;
                width = MAX(width >> 1, 1);
                height = MAX(height >> 1, 1);
            }
            
            success = TRUE;
            
            
            
            // UNPACK DONE. START reading it.
        
            //SHOULD WE REALLY SET THESE HERE? THEY SHOULD BE DETEMINED BY OPTIONS?
            if ([imageData count] > 1)
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            else
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
         
            
            //NSData *data = nil;
            //GLenum err;
            
                /*
            // NEED TO RESET THESE HERE
            width = CFSwapInt32LittleToHost(header->width);
            height = CFSwapInt32LittleToHost(header->height);
            
            for (int i=0; i < [imageData count]; i++) {
                data = [imageData objectAtIndex:i];
                
                
                //glCompressedTexImage2D(GL_TEXTURE_2D, i, internalFormat, width, height, 0, [data length], [data bytes]);
                
                
                
                err = glGetError();
                if (err != GL_NO_ERROR)
                {
                    NSLog(@"Error uploading compressed texture level: %d. glError: 0x%04X", i, err);
                }
                
                width = MAX(width >> 1, 1);
                height = MAX(height >> 1, 1);
            }
            
            [imageData removeAllObjects];
                 */
        //}
        
        
        
        

    }
    
    if (asset.type == kRETextureAssetTypeRawData) {
        glTexImage2D(options.target, 0, asset.rawInternalFormat, asset.rawWidth, asset.rawHeight, 0, asset.rawFormat, asset.rawType, asset.rawPixels);
        contentSize_ = CGSizeMake(asset.rawWidth, asset.rawHeight);
    }
    
}

@end





@implementation RETexture2D

+ (id)textureNamed:(NSString*)filename {
    return [RETextureCache textureNamed:filename];
}

+ (id)textureWithImage:(UIImage*)image {
    return [[[[self class] alloc] initWithImage:image] autorelease];
}

+ (id)textureWithImageBuffer:(CVImageBufferRef)imageBuffer {
    return [[[[self class] alloc] initWithImageBuffer:imageBuffer] autorelease];
}

+ (id)textureWithRawData:(void*)pixels width:(GLsizei)width height:(GLsizei)height internalFormat:(GLint)internalFormat format:(GLint)format type:(GLint)type {
    return [[[[self class] alloc] initWithRawData:pixels width:width height:height internalFormat:internalFormat format:format type:type] autorelease];
}

- (id)initWithImageBuffer:(CVImageBufferRef)imageBuffer {
    
    if ((self = [super initWithTarget:GL_TEXTURE_2D])) {
        [self setImageFromImageBuffer:imageBuffer];
    } return self;
    
}

- (void)setImageFromImageBuffer:(CVImageBufferRef)imageBuffer {
    
    
    RETextureAsset asset;
    asset.type = kRETextureAssetTypeCVImageBufferRef;
    asset.imageBuffer = imageBuffer;
    
    [self load:asset];
    
    
    
    /*
    [self bind];
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    int bufferWidth = CVPixelBufferGetWidth(imageBuffer);
    int bufferHeight = CVPixelBufferGetHeight(imageBuffer);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    contentSize = CGSizeMake(bufferWidth, bufferHeight);
    
    
    
    // This is necessary for non-power-of-two textures
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, bufferWidth, bufferHeight, GL_BGRA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(imageBuffer));
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
     */
}

- (id)initWithImage:(UIImage*)image {
    
    NSAssert(image, @"RETexture2D: Could not load UIImage");
        
    if ((self = [super initWithTarget:GL_TEXTURE_2D])) {
        RETextureAsset asset;
        asset.type = kRETextureAssetTypeUIImage;
        asset.image = image;
        
        [self load:asset];
        
    } return self;
}


- (id)initWithPVRData:(NSData *)pvrData {
    if ((self = [super initWithTarget:GL_TEXTURE_2D])) {
        RETextureAsset asset;
        asset.type = kRETextureAssetTypePVRData;
        asset.pvrData = pvrData;
        
        [self load:asset];
        
    } return self;
}

- (id)initWithRawData:(void*)pixels width:(GLsizei)width height:(GLsizei)height internalFormat:(GLint)internalFormat format:(GLint)format type:(GLint)type {
    if ((self = [super initWithTarget:GL_TEXTURE_2D])) {
        RETextureAsset asset;
        asset.type = kRETextureAssetTypeRawData;
        asset.rawPixels = pixels;
        asset.rawWidth = width;
        asset.rawHeight = height;
        asset.rawFormat = format;
        asset.rawInternalFormat = internalFormat;
        asset.rawType = type;
        
        [self load:asset];
        
    } return self;
}


@end


@implementation RETextureCubeMap

- (id)init {
    if ((self = [super initWithTarget:GL_TEXTURE_CUBE_MAP])) {
        
    } return self;
}

- (void)setImage:(UIImage*)image forTarget:(GLenum)target {
    RETextureAsset asset;
    asset.type = kRETextureAssetTypeUIImage;
    asset.image = image;
    
    RETextureAssetLoadOptions options;
    options.target = target;
    options.minFilter = GL_LINEAR;
    options.magFilter = GL_LINEAR;
    options.wrapS = GL_CLAMP_TO_EDGE;
    options.wrapT = GL_CLAMP_TO_EDGE;
    
    [self load:asset options:options];
}

- (void)setImageBuffer:(CVImageBufferRef)imageBuffer forTarget:(GLenum)target {
    RETextureAsset asset;
    asset.type = kRETextureAssetTypeCVImageBufferRef;
    asset.imageBuffer = imageBuffer;
    
    RETextureAssetLoadOptions options;
    options.target = target;
    options.minFilter = GL_LINEAR;
    options.magFilter = GL_LINEAR;
    options.wrapS = GL_CLAMP_TO_EDGE;
    options.wrapT = GL_CLAMP_TO_EDGE;
    
    [self load:asset options:options];
}

- (void)setPVRData:(NSData*)data forTarget:(GLenum)target {
    RETextureAsset asset;
    asset.type = kRETextureAssetTypePVRData;
    asset.pvrData = data;
    
    RETextureAssetLoadOptions options;
    options.target = target;
    options.minFilter = GL_LINEAR;
    options.magFilter = GL_LINEAR;
    options.wrapS = GL_CLAMP_TO_EDGE;
    options.wrapT = GL_CLAMP_TO_EDGE;
    
    [self load:asset options:options];
}

- (void)setRawData:(void*)pixels width:(GLsizei)width height:(GLsizei)height internalFormat:(GLint)internalFormat format:(GLint)format type:(GLint)type forTarget:(GLenum)target {
    
    RETextureAsset asset;
    asset.type = kRETextureAssetTypeRawData;
    asset.rawPixels = pixels;
    asset.rawWidth = width;
    asset.rawHeight = height;
    asset.rawFormat = format;
    asset.rawInternalFormat = internalFormat;
    asset.rawType = type;
    
    RETextureAssetLoadOptions options;
    options.target = target;
    options.minFilter = GL_LINEAR;
    options.magFilter = GL_LINEAR;
    options.wrapS = GL_CLAMP_TO_EDGE;
    options.wrapT = GL_CLAMP_TO_EDGE;
    
    [self load:asset options:options];
}

@end

@implementation RETexture2D (Text)

- (id)initWithString:(NSString*)string font:(UIFont*)font {
    
    if ((self = [super initWithTarget:GL_TEXTURE_2D])) {
    
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        float screenScale = [[UIScreen mainScreen] scale];
        
        contentSize_ = [string sizeWithFont:font];
        CGSize size = CGSizeMake(contentSize_.width * screenScale, contentSize_.height * screenScale);
        
        unsigned char*			data;
        
        CGContextRef			context;
        CGColorSpaceRef			colorSpace;
        
        data = calloc((int)(size.width * size.height), 1);
        
        colorSpace = CGColorSpaceCreateDeviceGray();
        context = CGBitmapContextCreate(data, size.width, size.height, 8, size.width, colorSpace, kCGImageAlphaNone);
        
        CGContextClearRect(context, CGRectMake(0, 0, size.width, size.height));
        
        CGContextSetGrayFillColor(context, 1.0f, 1.0f);
        CGContextTranslateCTM(context, 0.0f, size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        
        UIGraphicsPushContext(context);
        
        [string drawInRect:CGRectMake(0, 0, size.width, size.height) withFont:font];

        UIGraphicsPopContext();
        CGContextRelease(context);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, size.width, size.height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
        
        free(data);
    } return self;
}

@end
