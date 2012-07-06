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

#import "REGLStateManager.h"
#import "RENode.h"

@implementation REGLStateManager

+ (REGLStateManager*)sharedManager {
    static REGLStateManager *singleton = nil;
    if (!singleton) {
        singleton = [[self alloc] init];
    } return singleton;
}

- (id)init {
    if ((self = [super init])) {
        
        // Active Texure
        activeTexture = malloc(1 * sizeof(GLint));
        glGetIntegerv(GL_ACTIVE_TEXTURE, activeTexture);
        
        // Viewport
        viewport = malloc(4 * sizeof(GLint));
        memset(viewport, 0, 4 * sizeof(GLint)); // Can't get state? Initialize to zero
        
        /* Moved to below
        maxVertexAttribs = malloc(1 * sizeof(GLint));
        glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, maxVertexAttribs);
         */
        
        maxVertexUniformVectors = malloc(1 * sizeof(GLint));
        glGetIntegerv(GL_MAX_VERTEX_UNIFORM_VECTORS, maxVertexUniformVectors);
        
        depthTestEnabled = glIsEnabled(GL_DEPTH_TEST);
        depthMask = GL_TRUE; // Initially enabled
        
        blendEnabled = glIsEnabled(GL_BLEND);
        cullFaceEnabled = glIsEnabled(GL_CULL_FACE);
        stencilTestEnabled_ = glIsEnabled(GL_STENCIL_TEST);
        glGetIntegerv(GL_CULL_FACE_MODE, &cullFace_);
        
        stencilOp_ = REGLStencilOpMake(GL_KEEP, GL_KEEP, GL_KEEP); // Default values. Can't read state?
        stencilFunc_ = REGLStencilFuncMake(GL_ALWAYS, 0, 0xFFFFFFFF); // Default values. Can't read state?
        
        blendFunc = REGLBlendFuncMake(GL_ONE, GL_ZERO); // Default   
        
        colorMask_ = REGLColorMaskMake(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE); // Default
        
        glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &arrayBufferBinding);
        glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &elementArrayBufferBinding);
        
        glGetIntegerv(GL_CURRENT_PROGRAM, &currentProgram);
        
        glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &maxVertexAttribs);
        
        //vertexAttribArrayEnabled = calloc(maxVertexAttribs, sizeof(GLboolean));
        //memset(vertexAttribArrayEnabled, 0, maxVertexAttribs * sizeof(GLboolean)); // Disabled by default
        
        glGetIntegerv(GL_VERTEX_ARRAY_BINDING_OES, &vertexArrayObjectBinding);

    } return self;
}

#pragma mark - Active Texture

- (GLint)activeTexture {
    return activeTexture[0];
}

- (void)setActiveTexture:(GLint)v {
    if (activeTexture[0] != v) {
        activeTexture[0] = v;
        glActiveTexture(activeTexture[0]);
    }
}

#pragma mark - Viewport

- (GLint*)viewport {
    return viewport;
}

- (void)setViewport:(GLint)x y:(GLint)y width:(GLint)width height:(GLint)height {
    // Compare size first, since it is more likely to differ (reverse compare)
    if (viewport[3] != height || viewport[2] != width || viewport[1] != y || viewport[0] != x) { 
        viewport[0] = x;
        viewport[1] = y;
        viewport[2] = width;
        viewport[3] = height;
        glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);
    }
}

#pragma mark - MaxVertexAttribs

- (GLint)maxVertexUniformVectors {
    return maxVertexUniformVectors[0];
}

#pragma mark - DepthTest

- (GLboolean)depthTestEnabled {
    return depthTestEnabled;
}

- (void)setDepthTestEnabled:(GLboolean)yesOrNo {
    if (depthTestEnabled != yesOrNo) {
        depthTestEnabled = yesOrNo;
        depthTestEnabled ? glEnable(GL_DEPTH_TEST) : glDisable(GL_DEPTH_TEST);
    }
}

#pragma mark - DepthMask

- (REGLColorMask)colorMask {
    return colorMask_;
}

- (void)setColorMask:(REGLColorMask)colorMask {
    if (!REGLColorMaskEqualToColorMask(colorMask_, colorMask)) {
        colorMask_ = colorMask;
        glColorMask(colorMask_.red, colorMask_.green, colorMask_.blue, colorMask_.alpha);
    }
}
                                               

- (GLboolean)depthMask {
    return depthMask;
}

- (void)setDepthMask:(GLboolean)yesOrNo {
    if (depthMask != yesOrNo) {
        depthMask = yesOrNo;
        glDepthMask(depthMask);
    }
}


- (GLboolean)blendEnabled {
    return blendEnabled;
}

- (void)setBlendEnabled:(GLboolean)yesOrNo {
    if (blendEnabled != yesOrNo) {
        blendEnabled = yesOrNo;
        blendEnabled ? glEnable(GL_BLEND) : glDisable(GL_BLEND);
    }
}

- (GLboolean)cullFaceEnabled {
    return cullFaceEnabled;
}

- (void)setCullFaceEnabled:(GLboolean)yesOrNo {
    if (cullFaceEnabled != yesOrNo) {
        cullFaceEnabled = yesOrNo;
        cullFaceEnabled ? glEnable(GL_CULL_FACE) : glDisable(GL_CULL_FACE);
    }
}

- (GLint)cullFace {
    return cullFace_;
}

- (void)setCullFace:(GLint)cullFace {
    if (cullFace_ != cullFace) {
        cullFace_ = cullFace;
        glCullFace(cullFace_);
    }
}

- (GLboolean)stencilTestEnabled {
    return stencilTestEnabled_;
}

- (void)setStencilTestEnabled:(GLboolean)yesOrNo {
    if (stencilTestEnabled_ != yesOrNo) {
        stencilTestEnabled_ = yesOrNo;
        stencilTestEnabled_ ? glEnable(GL_STENCIL_TEST) : glDisable(GL_STENCIL_TEST);
    }
}

- (REGLStencilOp)stencilOp {
    return stencilOp_;
}

- (void)setStencilOp:(REGLStencilOp)stencilOp {
    if (!REGLStencilOpEqualToStencilOp(stencilOp_, stencilOp)) {
        stencilOp_ = stencilOp;
        glStencilOp(stencilOp_.sfail, stencilOp_.dpfail, stencilOp_.dppass);
    }
}

- (REGLStencilFunc)stencilFunc {
    return stencilFunc_;
}

- (void)setStencilFunc:(REGLStencilFunc)stencilFunc {
    if (!REGLStencilFuncEqualToStencilFunc(stencilFunc_, stencilFunc)) {
        stencilFunc_ = stencilFunc;
        glStencilFunc(stencilFunc_.func, stencilFunc_.ref, stencilFunc_.mask);
    }
}

- (REGLBlendFunc)blendFunc {
    return blendFunc;
}

- (void)setBlendFunc:(REGLBlendFunc)func {
    if (blendFunc.sfactor != func.sfactor || blendFunc.dfactor != func.dfactor) {
        blendFunc = func;
        glBlendFunc(blendFunc.sfactor, blendFunc.dfactor);
    }
}




#pragma mark - Program

- (void)setCurrentProgram:(GLint)program {
    if (currentProgram != program) {
        currentProgram = program;
        glUseProgram(currentProgram);
    }
}

#pragma mark - Buffers

- (GLint)arrayBufferBinding {
    return arrayBufferBinding;
}

- (GLint)elementArrayBufferBinding {
    return elementArrayBufferBinding;
}

- (void)setArrayBufferBinding:(GLint)buffer {
    if (arrayBufferBinding != buffer) {
        arrayBufferBinding = buffer;
        glBindBuffer(GL_ARRAY_BUFFER, arrayBufferBinding);
    }
}

- (void)setElementArrayBufferBinding:(GLint)buffer {
    if (elementArrayBufferBinding != buffer) {
        elementArrayBufferBinding = buffer;
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementArrayBufferBinding);
    }
}


#pragma mark - VertexAttribs 

- (GLint)maxVertexAttribs {
    return maxVertexAttribs;
}

/*
- (void)setVertexAttribArray:(GLuint)index enabled:(GLboolean)enabled {
    if ((GLboolean)vertexAttribArrayEnabled[index] != enabled) {
        vertexAttribArrayEnabled[index] = enabled;
        vertexAttribArrayEnabled[index] ? glEnableVertexAttribArray(index) : glDisableVertexAttribArray(index);
    }
}
 */

#pragma mark - Vertex Array Object

- (GLint)vertexArrayObjectBinding {
    return vertexArrayObjectBinding;
}

- (void)setVertexArrayObjectBinding:(GLint)object {
    if (vertexArrayObjectBinding != object) {
        vertexArrayObjectBinding = object;
        glBindVertexArrayOES(vertexArrayObjectBinding);
    }
}

@end
