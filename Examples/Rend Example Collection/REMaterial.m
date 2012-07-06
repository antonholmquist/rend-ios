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

#import "REMaterial.h"

@implementation REMaterial

@synthesize ambient = ambient_;
@synthesize diffuse = diffuse_;
@synthesize specular = specular_;
@synthesize shininess = shininess_;

+ (id)material {
    return [[[[self class] alloc] init] autorelease];
}

+ (id)materialWithAmbient:(float)ambient diffuse:(float)diffuse specular:(float)specular shininess:(float)shininess {
    REMaterial *instance = [self material];
    
    instance.ambient = CC3Vector4Make(ambient, ambient, ambient, 1);
    instance.diffuse = CC3Vector4Make(diffuse, diffuse, diffuse, 1);
    instance.specular = CC3Vector4Make(specular, specular, specular, 1);
    instance.shininess = shininess;
    
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        ambient_ = CC3Vector4Make(0.2, 0.2, 0.2, 1.0);
        diffuse_ = CC3Vector4Make(0.8, 0.8, 0.8, 1.0);
        specular_ = CC3Vector4Make(0, 0, 0, 1);
        shininess_ = 0;
    } return self;
}

@end
