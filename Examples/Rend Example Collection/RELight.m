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

#import "RELight.h"

@implementation RELight

@synthesize ambientColor, diffuseColor, specularColor;

@synthesize position = position_;

+ (id)light {
    return [[[self alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
        ambientColor = CC3Vector4Make(1, 1, 1, 1);
        diffuseColor = CC3Vector4Make(1, 1, 1, 1);
        specularColor = CC3Vector4Make(1, 1, 1, 1);
    } return self;
}

@end

@implementation REDirectionalLight

@synthesize direction = direction_;

- (id)init {
    if ((self = [super init])) {
        direction_ = CC3VectorMake(1, 1, 1);
    } return self;
}

@end

@implementation REPointLight

@synthesize attenuation;

@end