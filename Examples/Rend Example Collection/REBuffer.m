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

#import "REBuffer.h"
#import "REGLStateManager.h"

@implementation REBuffer

@synthesize buffer, length;

- (id)initWithTarget:(GLenum)t data:(void*)d length:(int)l {
    return [self initWithTarget:t data:d length:l usage:GL_STATIC_DRAW];
}

- (id)initWithTarget:(GLenum)t data:(void*)data length:(int)l usage:(GLenum)usage {
    if ((self = [super init])) {
        target = t;
        length = l;
        glGenBuffers(1, &buffer);
        //glBindBuffer(target, buffer);
        [self bind];
        glBufferData(target, length, (data ? data : NULL), usage);
    } return self;
}

- (void)dealloc {
    
    // If buffer is bound, it will be unbound when deleted. Therefore, we set state to correspond before
    if (target == GL_ARRAY_BUFFER && [[REGLStateManager sharedManager] arrayBufferBinding] == buffer) {
        [[REGLStateManager sharedManager] setArrayBufferBinding:0];
    } else if (target == GL_ELEMENT_ARRAY_BUFFER && [[REGLStateManager sharedManager] elementArrayBufferBinding] == buffer) {
        [[REGLStateManager sharedManager] setElementArrayBufferBinding:0];
    }
    
    glDeleteBuffers(1, &buffer); 
    
    [super dealloc];
}

- (void)setSubData:(void*)data offset:(int)offset length:(int)theLength {
    [self bind];
    glBufferSubData(target, offset, theLength, data);
}

#pragma mark - Binding

- (void)bind {

    //glBindBuffer(target, buffer);
    if (target == GL_ARRAY_BUFFER) {
        [[REGLStateManager sharedManager] setArrayBufferBinding:buffer];
    } else if (target == GL_ELEMENT_ARRAY_BUFFER) {
        [[REGLStateManager sharedManager] setElementArrayBufferBinding:buffer];
    }
}



+ (void)unbind {
    
    [self unbindArrayBuffer];
    [self unbindElementArrayBuffer];
    
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
 //   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

+ (void)unbindArrayBuffer {
    [[REGLStateManager sharedManager] setArrayBufferBinding:0];
}

+ (void)unbindElementArrayBuffer {
    [[REGLStateManager sharedManager] setElementArrayBufferBinding:0];
}

@end
