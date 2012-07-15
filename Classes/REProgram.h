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

#import "REShader.h"


// http://www.khronos.org/opengles/sdk/docs/man/xhtml/glVertexAttrib.xml
// http://www.khronos.org/opengles/sdk/docs/man/xhtml/glBindAttribLocation.xml

/* Local state of program: 
 uniform/attribute locations. 
 uniform values.
 
 Not local:
 attribute values.
 
 The binding between a generic vertex attribute index and a user-defined attribute variable in a vertex shader is part of the state of a program object, but the current value of the generic vertex attribute is not. The value of each generic vertex attribute is part of current state and it is maintained even if a different program object is used.
 */

@interface REProgram : NSObject {

    REShader *vertexShader, *fragmentShader;
    
    GLuint program;
    
    NSMutableDictionary *uniformLocations, *attribLocations;
}

@property (nonatomic, readonly) GLuint program;

/** This is the preferred way to return a program in the node program static method. The returned program is cached. */
+ (REProgram*)programWithVertexFilename:(NSString*)vertexFilename fragmentFilename:(NSString*)fragmentFilename;

- (id)initWithVertexShader:(REShader*)vertexShader fragmentShader:(REShader*)fragmentShader;

- (GLint)uniformLocation:(NSString*)name;
- (GLint)attribLocation:(NSString*)name;

- (void)use; // Sets to current

@end
