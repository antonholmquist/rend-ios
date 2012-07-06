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

@interface REShader ()

- (void)compile;

@end

@implementation REShader

@synthesize shader;

- (id)initWithType:(GLenum)t filename:(NSString*)n {
    NSString *s = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:n ofType:nil] encoding:NSUTF8StringEncoding error:nil];
    
    NSString *assertMessage = [NSString stringWithFormat:@"REShader: Can't find file named: %@", n];
    NSAssert(s, assertMessage);

    return [self initWithType:t string:s];
}

- (id)initWithType:(GLenum)t string:(NSString*)s {
    if ((self = [super init])) {
        type = t;
        string = [s retain];
        
        NSAssert(string, @"REShader: String is nil");
        
        [self compile];
    } return self;
}

- (void)dealloc {
    glDeleteShader(shader);
    [string release];
    [super dealloc];
}

- (void)compile {
    GLint status;
    
    const GLchar *source = [string UTF8String];
    shader = glCreateShader(type);

    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    
    

    // LOG     // TODO: Parse and log line from error?
    {
        GLint logLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(shader, logLength, &logLength, log);
            NSLog(@"GLProgram: (%@) Compile log:\n%s", string, log);
            free(log);
        }
    }
    
}

@end
