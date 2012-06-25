

#import <Foundation/Foundation.h>
#import "REGLTypes.h"

/* REGLState
 * ALWAYS use this to change supported state changes.
 */



@interface REGLStateManager : NSObject {
    GLint *activeTexture; // 1
    GLint *viewport; // 4
    //GLint *maxVertexAttribs; // 1
    GLint *maxVertexUniformVectors;
    
    GLboolean depthTestEnabled;
    GLboolean depthMask;
    GLboolean blendEnabled;
    GLboolean cullFaceEnabled;
    GLboolean stencilTestEnabled_;
    
    REGLColorMask colorMask_;
    REGLBlendFunc blendFunc;
    REGLStencilOp stencilOp_;
    REGLStencilFunc stencilFunc_;
    
    GLint arrayBufferBinding;
    GLint elementArrayBufferBinding;
    
    GLint currentProgram;
    GLint maxVertexAttribs;
    //GLboolean *vertexAttribArrayEnabled;
    
    GLint vertexArrayObjectBinding;
    
    GLint cullFace_;
}

+ (REGLStateManager*)sharedManager;

//@property (nonatomic, assign) GLint activeTexture;

- (GLint)activeTexture;
- (void)setActiveTexture:(GLint)v;

- (GLint*)viewport;
- (void)setViewport:(GLint)x y:(GLint)y width:(GLint)width height:(GLint)height;

- (GLint)maxVertexAttribs;
- (GLint)maxVertexUniformVectors;

- (GLboolean)depthTestEnabled;
- (void)setDepthTestEnabled:(GLboolean)yesOrNo;

- (GLboolean)depthMask;
- (void)setDepthMask:(GLboolean)yesOrNo;

- (REGLColorMask)colorMask;
- (void)setColorMask:(REGLColorMask)colorMask;

- (GLboolean)blendEnabled;
- (void)setBlendEnabled:(GLboolean)yesOrNo;

- (GLboolean)cullFaceEnabled;
- (void)setCullFaceEnabled:(GLboolean)yesOrNo;

- (GLint)cullFace;
- (void)setCullFace:(GLint)cullFace;

- (GLboolean)stencilTestEnabled;
- (void)setStencilTestEnabled:(GLboolean)yesOrNo;

- (REGLStencilOp)stencilOp;
- (void)setStencilOp:(REGLStencilOp)stencilOp;

- (REGLStencilFunc)stencilFunc;
- (void)setStencilFunc:(REGLStencilFunc)stencilFunc;

/*
 stencilOp_ = REGLStencilOpMake(GL_KEEP, GL_KEEP, GL_KEEP);
 stencilFunc_ = REGLStencilFuncMake(GL_ALWAYS, 0, 0xFFFFFFFF); // 16 ones  ~(~0 << 32)
 */

- (REGLBlendFunc)blendFunc;
- (void)setBlendFunc:(REGLBlendFunc)func;

- (void)setCurrentProgram:(GLint)program;

- (GLint)arrayBufferBinding;
- (GLint)elementArrayBufferBinding;
- (void)setArrayBufferBinding:(GLint)buffer;
- (void)setElementArrayBufferBinding:(GLint)buffer;

//- (void)setVertexAttribArray:(GLuint)index enabled:(GLboolean)enabled; DEPRECATED?

- (GLint)vertexArrayObjectBinding;
- (void)setVertexArrayObjectBinding:(GLint)object;

@end
