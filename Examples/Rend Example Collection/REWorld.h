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


#import "RENode.h"

@class RECamera;
@class RETextureCubeMap;
@class RELight;

/* REWorld
 
 Manages lights, etc.
 
 Note: Camera is moved to node, since we may have billboards and stuff wh
 */

@interface REWorld : RENode {
    //RECamera *camera; // Should camera be a node? The camera itself should not have a camera, contentSize, etc...
    
    NSMutableDictionary *lightsByClass_; // Key
    
    RETextureCubeMap *environmentMap;
}

@property (nonatomic, retain) RETextureCubeMap *environmentMap;

@property (nonatomic, readonly) NSArray *lights;

- (void)addLight:(RELight*)light;
- (void)removeLight:(RELight*)light;

- (NSArray*)lightsOfClass:(Class)lightClass;

@end
