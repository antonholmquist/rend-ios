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
