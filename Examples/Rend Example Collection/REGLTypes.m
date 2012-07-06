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

#import "REGLTypes.h"

REGLColorMask REGLColorMaskMake(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha) {
    REGLColorMask a;
    a.red = red;
    a.green = green;
    a.blue = blue;
    a.alpha = alpha;
    return a;
}

BOOL REGLColorMaskEqualToColorMask(REGLColorMask colorMask1, REGLColorMask colorMask2) {
    return 
    colorMask1.red == colorMask2.red && 
    colorMask1.green == colorMask2.green && 
    colorMask1.blue == colorMask2.blue &&
    colorMask1.alpha == colorMask2.alpha;
}

REGLBlendFunc REGLBlendFuncMake(GLenum sfactor, GLenum dfactor) {
    REGLBlendFunc a;
    a.sfactor = sfactor;
    a.dfactor = dfactor;
    return a;
}

REGLStencilFunc REGLStencilFuncMake(GLenum func, GLint ref, GLuint mask) {
    REGLStencilFunc a;
    a.func = func;
    a.ref = ref;
    a.mask = mask;
    return a;
}

BOOL REGLStencilFuncEqualToStencilFunc(REGLStencilFunc stencilFunc1, REGLStencilFunc stencilFunc2) {
    return stencilFunc1.func == stencilFunc2.func && stencilFunc1.ref == stencilFunc2.ref && stencilFunc1.mask == stencilFunc2.mask;
}

REGLStencilOp REGLStencilOpMake(GLenum sfail, GLenum dpfail, GLenum dppass) {
    REGLStencilOp a;
    a.sfail = sfail;
    a.dpfail = dpfail;
    a.dppass = dppass;
    return a;
}

BOOL REGLStencilOpEqualToStencilOp(REGLStencilOp stencilOp1, REGLStencilOp stencilOp2) {
    return stencilOp1.sfail == stencilOp2.sfail && stencilOp1.dpfail == stencilOp2.dpfail && stencilOp1.dppass == stencilOp2.dppass;
}
