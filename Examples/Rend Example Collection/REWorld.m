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

#import "REWorld.h"

@interface REWorld () 
    

@end

@implementation REWorld

@synthesize environmentMap;

- (id)init {
    if ((self = [super init])) {
        lightsByClass_ = [[NSMutableDictionary alloc] init];
    } return self;
}

- (void)dealloc {
    [lightsByClass_ release];
    [super dealloc];
}

#pragma mark - Lights

- (NSArray*)lightsOfClass:(Class)lightClass {
    NSString *key = NSStringFromClass(lightClass);
    return [lightsByClass_ objectForKey:key];
}

- (NSArray*)lights {
    return nil; // Deprectated.
}

- (void)addLight:(RELight*)light {
    
    NSString *key = NSStringFromClass([light class]);
    NSMutableArray *lights = [lightsByClass_ objectForKey:key];
    
    // If this is the first light of it's kind. Create array.
    if (!lights) {
        lights = [NSMutableArray array];
        [lightsByClass_ setObject:lights forKey:key];
    }
    
    if ([lights indexOfObjectIdenticalTo:light] == NSNotFound) {
        [lights addObject:light];    
    }
    
}

- (void)removeLight:(RELight*)light {
    
    NSString *key = NSStringFromClass([light class]);
    NSMutableArray *lights = [lightsByClass_ objectForKey:key];
    
    if ([lights indexOfObjectIdenticalTo:light] != NSNotFound) {
        [lights removeObject:light];    
        
        // If this is the last light of it's kind. Remove array.
        if ([lights count] == 0) {
            [lightsByClass_ removeObjectForKey:key];
        }
    }
}


@end
