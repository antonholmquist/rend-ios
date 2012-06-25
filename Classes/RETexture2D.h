

/*
 HOW TO CREATE PVR
 // Example usage of texturetool:
 
 // -f PVR is to include header-info
 // -m  is to generate mipmaps (not required)
 
 // ./texturetool -m -f PVR -e PVRTC --channel-weighting-perceptual --bits-per-pixel-4 -o ~/Desktop/pvrtest/mega1.pvrtc -p ~/Desktop/pvrtest/mega1_preview.png ~/Desktop/pvrtest/mega1.png
 
 // IMPROVE HERE
 // https://github.com/nicklockwood/GLView/
 */

@interface RETexture : NSObject {
    GLuint texture_;
    GLenum target_;
    
    CGSize contentSize_; // Created here, but only exposed in texture2D
}

@property (nonatomic, readonly) GLuint texture;
@property (nonatomic, readonly) CGSize contentSize; // Size of content in pixels. Only available of texture is RETexture2D!

// Target must be either GL_TEXTURE_2D or GL_TEXTURE_CUBE_MAP
- (id)initWithTarget:(GLenum)target;

// Binds texture to GL_TEXTURE0
- (void)bind;

// Binds texture to specified texture unit. (GL_TEXTURE0, GL_TEXTURE1, etc..)
- (void)bind:(GLenum)textureUnit;

// Unbinds textures for all texture units.
+ (void)unbind;

@end




@interface RETexture2D : RETexture {
    
}


 // Will use cache. Both png, jpg and pvr-files are ok.
+ (id)textureNamed:(NSString*)filename;

// Will not use cache
+ (id)textureWithImage:(UIImage*)image;
+ (id)textureWithImageBuffer:(CVImageBufferRef)imageBuffer;
+ (id)textureWithRawData:(void*)pixels width:(GLsizei)width height:(GLsizei)height internalFormat:(GLint)internalFormat format:(GLint)format type:(GLint)type;



// This method uses cache.
//- (id)initWithImageNamed:(NSString*)filename; // NOT YET IMPLEMENTED

- (id)initOnTexture:(GLint)texture;
- (id)initWithImage:(UIImage*)image;
- (id)initWithImageBuffer:(CVImageBufferRef)imageBuffer;
- (id)initWithPVRData:(NSData *)pvrData;
- (id)initWithRawData:(void*)pixels width:(GLsizei)width height:(GLsizei)height internalFormat:(GLint)internalFormat format:(GLint)format type:(GLint)type;

- (void)setImageFromImageBuffer:(CVImageBufferRef)imageBuffer; // Use this if updating texture from camera. Roughly 50-60% faster.

@end


@interface RETextureCubeMap : RETexture {
    
}

// Target should be one of following:
// GL_TEXTURE_CUBE_MAP_POSITIVE_X, GL_TEXTURE_CUBE_MAP_NEGATIVE_X, GL_TEXTURE_CUBE_MAP_POSITIVE_Y, GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, GL_TEXTURE_CUBE_MAP_POSITIVE_Z, or GL_TEXTURE_CUBE_MAP_NEGATIVE_Z

// NOTE: ALL TEXTURES NEEDS TO BE OF THE SAME SIZE!
- (void)setImage:(UIImage*)image forTarget:(GLenum)target;
- (void)setImageBuffer:(CVImageBufferRef)imageBuffer forTarget:(GLenum)target;
- (void)setPVRData:(NSData*)data forTarget:(GLenum)target;
- (void)setRawData:(void*)pixels width:(GLsizei)width height:(GLsizei)height internalFormat:(GLint)internalFormat format:(GLint)format type:(GLint)type forTarget:(GLenum)target;

@end



@interface RETexture2D (Text)

- (id)initWithString:(NSString*)string font:(UIFont*)font; // Dependent on screen size

@end


