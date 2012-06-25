

#import <Foundation/Foundation.h>

@interface REGLView : UIView {
    
    // Normal framebuffer
    GLuint framebuffer; 
    GLuint colorRenderbuffer;
    //GLuint depthRenderbuffer;
    GLuint depthStencilRenderbuffer_; // Combined depth and stencil render buffer
    
    // Multisample framebuffers
    GLuint multisampleFramebuffer; // This is used for sampling
    GLuint multisampleColorRenderbuffer;
    //GLuint multisampleDepthRenderbuffer;
    GLuint multisampleDepthStencilRenderbuffer_;
    
    CGRect viewport;
    
    BOOL multisampling_;
}

@property (nonatomic, readonly) GLuint framebuffer; 
@property (nonatomic, readonly) GLuint colorRenderbuffer;
//@property (nonatomic, readonly) GLuint stencilRenderBuffer;
//@property (nonatomic, readonly) GLuint depthStencilRenderbuffer;

@property (nonatomic, readonly) GLuint multisampleFramebuffer; // Used for multisampling

@property (nonatomic, readonly) CGRect viewport;
@property (nonatomic, readonly) BOOL multisampling;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame colorFormat:(NSString*)colorFormat; // kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
- (id)initWithFrame:(CGRect)frame colorFormat:(NSString*)colorFormat multisampling:(BOOL)multisampling;
- (id)initWithFrame:(CGRect)frame colorFormat:(NSString*)colorFormat multisampling:(BOOL)multisampling scale:(float)scale; 

- (void)bindFramebuffer;

@end
