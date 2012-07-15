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

#import "RESprite.h"
#import "REBuffer.h"
#import "RECache.h"
#import "RETexture.h"

@interface RESprite ()

- (void)updateTexCoords;

@end

@implementation RESprite

@synthesize texture;

@synthesize textureFlipX, textureFlipY;
@synthesize textureRotationAngle;
@synthesize textureContentFrame;

@synthesize attribs, multiplyColor;

@synthesize batchNode = batchNode_;
@synthesize alphaPremultipled = alphaPremultipled_;

- (id)init {
    if ((self = [super init])) {
        //self.rotationAxis = CC3VectorMake(0, 0, 1);
        
        attribs = calloc(sizeof(RESpriteAttribs), 4);
        
        attribs[0].position = CC3VectorMake(-0.5f, -0.5f, 0.0f); // BL
        attribs[1].position = CC3VectorMake(0.5f, -0.5f, 0.0f); // BR
        attribs[2].position = CC3VectorMake(-0.5f, 0.5f, 0.0f); // TL
        attribs[3].position = CC3VectorMake(0.5f, 0.5f, 0.0f); // TR
        
        texCoordTransform = [[CC3GLMatrix alloc] initIdentity];
        
        originalTexCoords = calloc(4, sizeof(CC3Vector));
        originalTexCoords[0] = CC3VectorMake(-0.5f, -0.5f, 0.0f); // BL
        originalTexCoords[1] = CC3VectorMake(0.5f, -0.5f, 0.0f); // BR
        originalTexCoords[2] = CC3VectorMake(-0.5f, 0.5f, 0.0f); // TL
        originalTexCoords[3] = CC3VectorMake(0.5f, 0.5f, 0.0f); // TR
        
        areTexCoordsDirty = YES;
        
        self.boundingBox = CC3BoundingBoxMake(-0.5f, -0.5f, 0.0f, 
                                              0.5f, 0.5f, 0.0f);
        
        self.anchorPoint = CC3VectorMake(0.5, 0.5, 0.0);
        
        multiplyColor = CC3Vector4Make(1, 1, 1, 1);
        
        attribBuffer_ = [[REBuffer alloc] initWithTarget:GL_ARRAY_BUFFER 
                                                    data:NULL 
                                                  length:4 * sizeof(RESpriteAttribs)];
        
        alphaPremultipled_ = YES;
        isProgramDirty_ = YES;
        
    } return self;
}

- (void)dealloc {
    
    if (batchNode_) {
        [batchNode_ removeSprite:self];
    }
    
    free(attribs);
    free(originalTexCoords);
    [texture release];
    [texCoordTransform release];
    [attribBuffer_ release];
    [super dealloc];
}

- (REProgram*)program {
    
    // Quick fix. We need to disover how we should do this. Really, supporting non-premultipled alpha this way this was a bad idea.
    if (![self isMemberOfClass:[RESprite class]]) {
        return [super program];
    }
    
    if (isProgramDirty_) {
        isProgramDirty_ = NO;
        
        
        [program release];
        
        NSString *shaderPairName = alphaPremultipled_ ? @"sRESprite" : @"sRESpriteMultiplyAlpha";
        
        program = [[REProgramCache sharedCache] programForKey:shaderPairName];
        
        if (!program) {
            program = [REProgram programWithVertexFilename:[shaderPairName stringByAppendingFormat:@".vsh"] fragmentFilename:[shaderPairName stringByAppendingFormat:@".fsh"]];
            [[REProgramCache sharedCache] setProgram:program forKey:shaderPairName];
        }
        
        [program retain];

    } return program;
}

- (void)setAlphaPremultipled:(BOOL)alphaPremultipled {
    if (alphaPremultipled_ != alphaPremultipled) {
        alphaPremultipled_ = alphaPremultipled;
        isProgramDirty_ = YES;
    }
}

- (void)setTextureRotationAngle:(float)angle {
    textureRotationAngle = angle;
    areTexCoordsDirty = YES;
}

- (void)setTextureFlipX:(BOOL)flip {
    textureFlipX = flip;
    areTexCoordsDirty = YES;
}

- (void)setTextureFlipY:(BOOL)flip {
    textureFlipY = flip;
    areTexCoordsDirty = YES;
}

- (void)setTextureContentFrame:(CGRect)f {
    textureContentFrame = f;
    areTexCoordsDirty = YES;
}


- (void)setTexture:(RETexture2D *)t {
    
    if (t == texture) {
        return;
    }
    
    // If it's new content size, we need to updateTexCoords
    if (!CGSizeEqualToSize(texture.contentSize, t.contentSize) ) {
        areTexCoordsDirty = YES;
    }
     
    
    [texture release];
    texture = [t retain];
    //areTexCoordsDirty = YES; // Cause of frame
}

- (RESpriteAttribs*)attribs {
    if (areTexCoordsDirty) {
        [self updateTexCoords];
    } return attribs;
}

- (void)updateTexCoords {
    if (areTexCoordsDirty) {
        areTexCoordsDirty = NO;
        
        // If texture is set, and textureContentFrame is non-zero
        if (texture && !CGRectEqualToRect(textureContentFrame, CGRectZero)) {
            
            CGSize textureContentSize = texture.contentSize;
            
            // Assumes that bounding box is of size 1
            attribs[0].texCoord = CC3VectorMake(originalTexCoords[0].x + CGRectGetMinX(textureContentFrame) / textureContentSize.width,
                                                originalTexCoords[0].y + (textureContentSize.height - CGRectGetMaxY(textureContentFrame)) / textureContentSize.height,
                                                0);
            attribs[1].texCoord = CC3VectorMake(originalTexCoords[0].x + CGRectGetMaxX(textureContentFrame) / textureContentSize.width,
                                                originalTexCoords[0].y + (textureContentSize.height - CGRectGetMaxY(textureContentFrame)) / textureContentSize.height,
                                                0);
            
            attribs[2].texCoord = CC3VectorMake(originalTexCoords[0].x + CGRectGetMinX(textureContentFrame) / textureContentSize.width,
                                                originalTexCoords[0].y + (textureContentSize.height - CGRectGetMinY(textureContentFrame)) / textureContentSize.height,
                                                0);
            
            attribs[3].texCoord = CC3VectorMake(originalTexCoords[0].x + CGRectGetMaxX(textureContentFrame) / textureContentSize.width,
                                                originalTexCoords[0].y + (textureContentSize.height - CGRectGetMinY(textureContentFrame)) / textureContentSize.height,
                                                0);
            

            
        } else { // Use entire texture
            attribs[0].texCoord = originalTexCoords[0];
            attribs[1].texCoord = originalTexCoords[1];
            attribs[2].texCoord = originalTexCoords[2];
            attribs[3].texCoord = originalTexCoords[3];
        }
        
        
        // Rotate or flip
        [texCoordTransform populateIdentity];
        [texCoordTransform translateBy:CC3VectorMake(0.5, 0.5, 0.5)]; // Translate to correct center. (Original is around origo, so this is needed).
        [texCoordTransform rotateByZ:textureRotationAngle];
        //[texCoordTransform scaleBy:CC3VectorMake(textureFlipX ? -1 : 1, textureFlipY ? -1 : 1, 1)];
        if(textureFlipX) {
            CC3Vector texBL = attribs[0].texCoord;
            CC3Vector texTL = attribs[2].texCoord;
            attribs[0].texCoord = attribs[1].texCoord;
            attribs[1].texCoord = texBL;
            attribs[2].texCoord = attribs[3].texCoord;
            attribs[3].texCoord = texTL;
        }
        if(textureFlipY) {
            CC3Vector texBL = attribs[0].texCoord;
            CC3Vector texBR = attribs[1].texCoord;
            attribs[0].texCoord = attribs[2].texCoord;
            attribs[2].texCoord = texBL;
            attribs[1].texCoord = attribs[3].texCoord;
            attribs[3].texCoord = texBR;
        }
        
        attribs[0].texCoord = [texCoordTransform transformLocation:attribs[0].texCoord];
        attribs[1].texCoord = [texCoordTransform transformLocation:attribs[1].texCoord];
        attribs[2].texCoord = [texCoordTransform transformLocation:attribs[2].texCoord];
        attribs[3].texCoord = [texCoordTransform transformLocation:attribs[3].texCoord];
        
        if (!batchNode_) {
            [attribBuffer_ setSubData:attribs offset:0 length:4 * sizeof(RESpriteAttribs)];
        }

    }
}

+ (REProgram*)program {
    return [REProgram programWithVertexFilename:@"sRESprite.vsh" fragmentFilename:@"sRESprite.fsh"];
}

- (CGRect)frame {
    return CGRectMake(self.position.x, self.position.y, self.size.x, self.size.y);
}

- (void)setFrame:(CGRect)f {
    self.position = CC3VectorMake(f.origin.x + f.size.width / 2.0f, f.origin.y + f.size.height / 2.0f, -8000);
    self.size = CC3VectorMake(f.size.width, f.size.height, 0);
}

- (BOOL)willDraw {
    // Don't draw if it doesn't have sprite batch node.
    return batchNode_ == nil;
}

- (BOOL)shouldCullTest {
    return YES;
}

- (void)setBatchNode:(RESpriteBatchNode *)batchNode {
    if (batchNode_ != batchNode) {
        
        if (batchNode_) {
            [batchNode_ removeSprite:self];
        }
        
        batchNode_ = batchNode;
        
        [batchNode_ addSprite:self];
    }
}

- (void)draw {
    
    
    
    if (areTexCoordsDirty) {
        [self updateTexCoords];
    }
    
    // Will be drawn by sprite batch node
    if (batchNode_) {
        return;
    }
    
    [super draw];
    
    [self.program use];
    
    GLint a_position = [self.program attribLocation:@"a_position"];
    GLint a_texCoord = [self.program attribLocation:@"a_texCoord"];
    GLint s_texture = [self.program uniformLocation:@"s_texture"];
    GLint u_multiplyColor = [self.program uniformLocation:@"u_multiplyColor"];
    
    glUniform1i(s_texture, 0);
    glUniform4f(u_multiplyColor, multiplyColor.x, multiplyColor.y, multiplyColor.z, multiplyColor.w * [self.alpha floatValue]);
    
    
    texture ? [texture bind] : [RETexture2D unbind];
    
    // Force reload self.attribbuffer (without warnings).
    RESpriteAttribs *a = self.attribs; a = a;
    
    [attribBuffer_ bind];
    
    glVertexAttribPointer(a_position, 3, GL_FLOAT, GL_FALSE, sizeof(RESpriteAttribs),(void*)offsetof(RESpriteAttribs, position));
    glEnableVertexAttribArray(a_position);
    
    glVertexAttribPointer(a_texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(RESpriteAttribs),(void*)offsetof(RESpriteAttribs, texCoord));
    glEnableVertexAttribArray(a_texCoord);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    
        
}


@end
