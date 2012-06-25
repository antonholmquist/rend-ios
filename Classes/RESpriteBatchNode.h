

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
