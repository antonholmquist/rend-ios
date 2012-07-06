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

#import "REWavefrontMeshElementIndexBatch.h"
#import "REWavefrontMesh.h"

@implementation REWavefrontMeshElementIndexBatch

@synthesize indices, length, batchIndexAttributes, numberOfAttributes;

- (id)initWithElementSets:(NSArray*)elementSets indices:(GLushort*)rawIndices {
    if ((self = [super init])) {
        // Initialization code here.
        
        length = 0;
        
        numberOfAttributes = 0; // We can find this here, since indices higher than what we can find, won't be drawn any. We may also be able to send numberOfVertexAttributes from the mesh with (probably) the same result
        
        // Find total number of indices for this batch and store in 'length'.
        for (REWavefrontElementSet *elementSet in elementSets) {
            for (NSValue *rangeValue in elementSet.indexRanges) {
                NSRange range = [rangeValue rangeValue];
                length += range.length;
                numberOfAttributes = MAX(numberOfAttributes, range.location + range.length);
            }
        }
        
        // Allocate memory
        indices = calloc(length, sizeof(GLushort));
        batchIndexAttributes = calloc(numberOfAttributes, sizeof(GLfloat));
        
        // Loop through again to populate from raw indices
        int currentIndex = 0;
        int elementSetIndex = 0;
        for (REWavefrontElementSet *elementSet in elementSets) {
            for (NSValue *rangeValue in elementSet.indexRanges) {
                NSRange range = [rangeValue rangeValue];
                memcpy(indices + currentIndex, rawIndices + range.location, range.length * sizeof(GLushort));
                
                // Set float attribute batch indices (can't be done with memset since it doesn't support floats)
                for (int i = 0; i < range.length; i++) {
                    batchIndexAttributes[*(indices + currentIndex + i)] = (float)elementSetIndex;
                }
                
                currentIndex += range.length;
            }
            elementSetIndex ++;
        }
        
    } return self;
}

- (void)dealloc {
    free(indices);
    free(batchIndexAttributes);
    [elementIndexBuffer release];
    [batchIndexAttributeBuffer release];
    [super dealloc];
}

- (BOOL)hasElementIndexBuffer {
    return elementIndexBuffer != nil;
}

- (void)createElementIndexBuffer {
    if (!elementIndexBuffer) {
        elementIndexBuffer = [[REBuffer alloc] initWithTarget:GL_ELEMENT_ARRAY_BUFFER data:indices length:length * sizeof(GLushort)];
    }
}

- (void)bindElementIndexBuffer {
    NSAssert([self hasElementIndexBuffer], @"REWavefrontElementIndexBatch: Can't bind buffer if we have no buffer");
    [elementIndexBuffer bind];
}

- (BOOL)hasBatchIndexAttributeBuffer {
    return batchIndexAttributeBuffer != nil;
}

- (void)createBatchIndexAttributeBuffer {
    if (!batchIndexAttributeBuffer) {
        batchIndexAttributeBuffer = [[REBuffer alloc] initWithTarget:GL_ARRAY_BUFFER data:batchIndexAttributes length:numberOfAttributes * sizeof(GLfloat)];
    }
}

- (void)bindBatchIndexAttributeBuffer {
    NSAssert([self hasBatchIndexAttributeBuffer], @"REWavefrontElementIndexBatch: Can't bind buffer if we have no buffer");
    [batchIndexAttributeBuffer bind];
}

@end
