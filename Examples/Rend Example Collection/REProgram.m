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

#import "REProgram.h"
#import "REGLStateManager.h"

@interface REProgram ()

- (void)link;

@end

@implementation REProgram

@synthesize program;

+ (REProgram*)programWithVertexFilename:(NSString*)vertexFilename fragmentFilename:(NSString*)fragmentFilename {
    return [[[[self class] alloc] initWithVertexShader:[[[REShader alloc] initWithType:GL_VERTEX_SHADER filename:vertexFilename] autorelease]
                                        fragmentShader:[[[REShader alloc] initWithType:GL_FRAGMENT_SHADER filename:fragmentFilename] autorelease]] autorelease];
}

- (id)initWithVertexShader:(REShader*)v fragmentShader:(REShader*)f {
    if ((self = [super init])) {
        
        vertexShader = [v retain];
        fragmentShader = [f retain];
        
        uniformLocations = [[NSMutableDictionary alloc] init];
        attribLocations = [[NSMutableDictionary alloc] init];
        
        program = glCreateProgram();
        
        [self link];
        
    } return self;
}

- (void)dealloc {
    [vertexShader release];
    [fragmentShader release];
    [uniformLocations release];
    [attribLocations release];
    glDeleteProgram(program);
    [super dealloc];
}

- (void)link {
    glAttachShader(program, vertexShader.shader);
    glAttachShader(program, fragmentShader.shader);
    glLinkProgram(program);

    //glValidateProgram(program);
    /* IT MAY BE TO EARLY TO VALIDATE HERE! DO IT BEFORE DRAWING IF YOU LIKE
     glValidateProgram() is validating current context state (the sampler uniforms, the draw framebuffer, the current vertex array state, etc--- anything that can cause a draw-time error when used with the program.) You shouldn't validate immediately after linking.
     
     Really you should validate right before drawing. And only in your debug build; it's a tool for you to debug with.
     */
    
    GLint status;

    glGetProgramiv(program, GL_LINK_STATUS, &status);
    
    
    // LOG     // TODO: Parse and log line from error?
    {
        GLint logLength;
            
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetProgramInfoLog(program, logLength, &logLength, log);
            NSLog(@"REProgram: Compile log:\n%s", log);
            free(log);
        }
    }
}

- (void)use {
    [[REGLStateManager sharedManager] setCurrentProgram:program];
}

#pragma mark - Uniform/Attribute Locations

- (GLint)uniformLocation:(NSString*)name {
    NSNumber *number = [uniformLocations objectForKey:name];
    if (number == nil) {
        GLint location = glGetUniformLocation(program, [name UTF8String]);
        number = [NSNumber numberWithInt:location];
        [uniformLocations setObject:number forKey:name];
    } return [number intValue];
}

- (GLint)attribLocation:(NSString*)name {
    NSNumber *number = [attribLocations objectForKey:name];
    if (number == nil) {
        GLint location = glGetAttribLocation(program, [name UTF8String]);
        number = [NSNumber numberWithInt:location];
        [attribLocations setObject:number forKey:name];
    } return [number intValue];
}


@end
