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

@class RETexture2D;
@class RESpriteBatchNode;
@class REBuffer;


typedef struct RESpriteAttribs {
    CC3Vector position;
    CC3Vector texCoord;
} RESpriteAttribs;

/* RESprite
 
 Creates sprite in x,y-plane.
 
 1. First clips to textureContentFrame
 2. Then flips/rotates
 */
 

@interface RESprite : RENode {
    
    RESpriteBatchNode *batchNode_;
    
    RETexture2D *texture;
    RESpriteAttribs *attribs;
    
    BOOL areTexCoordsDirty;
    
    CC3Vector *originalTexCoords;
    CC3GLMatrix *texCoordTransform;
    
    BOOL textureFlipX, textureFlipY;
    
    CGRect textureContentFrame;
    
    CC3Vector4 multiplyColor;
    
    REBuffer *attribBuffer_;
    
    BOOL alphaPremultipled_;
    BOOL isProgramDirty_;
    
}

@property (nonatomic, assign) RESpriteBatchNode *batchNode;

// Is alpha premultiplied in texture. It's better to premultiply when saving the texture, than doing it here.
// Saving with alpha premultipled can be done with pvr-textures with PVRTexTool.
@property (nonatomic, assign) BOOL alphaPremultipled; 

@property (nonatomic, retain) RETexture2D *texture; 
@property (nonatomic, assign) CGRect frame; // Undefined if rotation is set.

@property (nonatomic, assign) CGRect textureContentFrame; // Default to CGRectZero, which means use entire texture

@property (nonatomic, assign) BOOL textureFlipX, textureFlipY;
@property (nonatomic, assign) float textureRotationAngle;

@property (nonatomic, assign) CC3Vector4 multiplyColor;

@property (nonatomic, readonly) RESpriteAttribs *attribs; // To be used for batch node and maybe others. Will be of length 4.



@end
