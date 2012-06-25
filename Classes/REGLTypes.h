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

typedef GLboolean REGLboolean;

typedef struct {
    GLboolean red, green, blue, alpha;
} REGLColorMask;

typedef struct {
    GLenum sfactor, dfactor;
} REGLBlendFunc;

typedef struct {
    GLenum func;
    GLint ref;
    GLuint mask;
} REGLStencilFunc;

typedef struct {
    GLenum sfail, dpfail, dppass;
} REGLStencilOp;

REGLColorMask REGLColorMaskMake(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha);
BOOL REGLColorMaskEqualToColorMask(REGLColorMask colorMask1, REGLColorMask colorMask2);

REGLBlendFunc REGLBlendFuncMake(GLenum src, GLenum dst);
REGLStencilFunc REGLStencilFuncMake(GLenum func, GLint ref, GLuint mask);
BOOL REGLStencilFuncEqualToStencilFunc(REGLStencilFunc stencilFunc1, REGLStencilFunc stencilFunc2);

REGLStencilOp REGLStencilOpMake(GLenum sfail, GLenum dpfail, GLenum dppass);
BOOL REGLStencilOpEqualToStencilOp(REGLStencilOp stencilOp1, REGLStencilOp stencilOp2);
