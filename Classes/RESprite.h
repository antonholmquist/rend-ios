

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
