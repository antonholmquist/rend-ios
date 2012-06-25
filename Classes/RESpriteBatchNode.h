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
#import "RESprite.h"

@class RESprite, REBuffer;

/*
 Just used for drawing sprites.
 
 Needs to be added to world so it will get visited and hence draw.
 Sprites needs to be added to world so they will get correct transform from parents.
 
 Should be added to node that uses the same camera as the sprites.
 
 Supports multiplyColor on nodes
 */

@interface RESpriteBatchNode : RENode {
    
    NSMutableArray *sprites;
    
    GLushort *elementIndices;
    GLfloat *batchUnitAttrib;
    
    REBuffer *elementIndexBuffer;
    REBuffer *batchUnitAttribBuffer;
    REBuffer *positionAttribBuffer;
    
    GLfloat *modelViewMatrices;
    GLfloat *multiplyColors;
    
    // We don't need both of these
    RESpriteAttribs *batchedAttribs; // Not used
    NSMutableArray *batchedAttribsBuffers_; // One REBuffer for each batch. Index: batch index only used for tex coords. This may be updated for each frame, for instance on animation.
    
//    NSMutableArray *batchedTexCoordAttribBuffers; // One for each batch, connected
    NSMutableArray *vertexArrayObjects; // Index: batch index
}

// Do not call these directly. Set batch node property on sprite instead. 
// Sprite batch node doesn't retain it's sprites
- (void)addSprite:(RESprite*)sprite;
- (void)removeSprite:(RESprite*)sprite;

@property (nonatomic, assign) int tag;

@end
