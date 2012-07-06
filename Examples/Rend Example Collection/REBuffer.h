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

/* REBuffer (VBO)
 
 Immutable. Possible to create a mutable version later.
 
 target options:
 GL_ARRAY_BUFFER 
 GL_ELEMENT_ARRAY_BUFFER
 
 */

@interface REBuffer : NSObject {
    GLuint buffer;
    GLenum target;
    
    int length;
}

@property (nonatomic, readonly) GLuint buffer;
@property (nonatomic, readonly) int length;

- (id)initWithTarget:(GLenum)t data:(void*)data length:(int)length; // STATIC_DRAW is default usage
- (id)initWithTarget:(GLenum)t data:(void*)data length:(int)length usage:(GLenum)usage;

- (void)setSubData:(void*)data offset:(int)offset length:(int)length; // Writes data into buffer

- (void)bind;

+ (void)unbind; // Unbinds all targets
+ (void)unbindArrayBuffer;
+ (void)unbindElementArrayBuffer;

/*
 STATIC_DRAW The data store contents will be specified once by the application, and used many times as the source for GL drawing commands.
 DYNAMIC_DRAW The data store contents will be respecified repeatedly by the ap- plication, and used many times as the source for GL drawing commands.
 STREAM_DRAW The data store contents will be specified once by the application, and used at most a few times as the source of a GL drawing command.
 */

@end


/*
@interface REMutableBuffer 

@end
*/