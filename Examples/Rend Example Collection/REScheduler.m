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

#import "REScheduler.h"
#import "RENSArrayAdditions.h"

@implementation REScheduler

+ (REScheduler*)sharedScheduler {
    static REScheduler *singleton = nil;
    if (singleton == nil) {
        singleton = [[[self class] alloc] init];
    } return singleton;
}

- (id)init {
    if ((self = [super init])) {
        //updateTargets = [[NSMutableArray alloc] init];
        updateTargets = [[NSMutableArray RE_arrayUsingWeakReferences] retain];
    } return self;
}

- (void)scheduleUpdateForTarget:(id)target {
    if ([updateTargets indexOfObjectIdenticalTo:target] == NSNotFound) {
        [updateTargets addObject:target];
        //[target release];
        //NSLog(@"scheduleUpdateForTarget: %p", target);
    } else {
        //NSLog(@"REScheduler: Warning: Trying to schedule update for target twice");
    }
}

- (void)unscheduleUpdateForTarget:(id)target {
    if ([updateTargets indexOfObjectIdenticalTo:target] != NSNotFound) {
        //[target retain];
        [updateTargets removeObjectIdenticalTo:target];   
        //NSLog(@"unscheduleUpdateForTarget: %p", target);
    } else {
        //NSLog(@"REScheduler: Warning: Trying to unschedule update for that isn't scheduled");
    }
}

- (void)tick:(float)dt {
    for (id target in [[updateTargets copy] autorelease]) { // WARNING! May be inefficient to copy!
        [target update:dt];
    }
}

@end
