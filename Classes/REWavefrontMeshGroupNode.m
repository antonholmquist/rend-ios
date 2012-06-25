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

#import "REWavefrontMeshGroupNode.h"
#import "REWavefrontMesh.h"

@implementation REWavefrontMeshGroupNode

@synthesize texture, group, elementSet;
@synthesize nextFrameTween, nextFramePosition, nextFrameRotation;

- (id)initWithWavefrontMesh:(REWavefrontMesh*)m group:(NSString*)g {
    if ((self = [super init])) {
        wavefrontMesh = [m retain];
        group = [g retain];
        
        elementSet = [wavefrontMesh elementsForGroup:group];
        
        self.boundingBox = elementSet.boundingBox;
        
        // Set anchor coordinate to center
        self.anchorCoordinate = CC3BoundingBoxCenter(self.boundingBox);
        self.position = self.anchorCoordinate;
        
    } return self;
}

- (void)dealloc {
    elementSet = nil;
    [wavefrontMesh release];
    [group release];
    [texture release];
    [super dealloc];
}

+ (REProgram*)program {
    return [REProgram programWithVertexFilename:@"sREWavefrontMeshGroup.vsh" fragmentFilename:@"sREWavefrontMeshGroup.fsh"];
}


- (void)draw {

}

@end
