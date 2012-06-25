

#import "REProgram.h"
#import "REGLTypes.h"
#import "CC3Foundation.h"
#import "CC3GLMatrix.h"

@class REWorld;
@class RECamera;
@class REAction;
@class RERotator;

/* RENode
 *
 * Question: Should node only be drawables? (And not cameras, lights, fog, etc).
 * They may not have enough things incommon, although it's still a pretty sweet pattern that all things exist in the world, so we'll leave that decision for later
 *
 * ACTIONS: The node doesn't know about it's actions. It just cares about it's properties. And the actions will set these.
 *
 * Transform. Order of which matrixes will be applied:
 * - Node:
 * Rotation
 * Scale
 * Translation
 * - Camera:
 * CameraEye
 * CameraProjection
 * -
 *
 * Coordinate systems: All internal data i RENode should be kept in model coordinates
 *
 *
 * GL STATES (INHERETENCY OR NOT?)
 *
 * All gl states are currently fetched from parent when it's added. It's kind of inherited, but not fully. It's saved lots of traversing and messaging to do it this way instead. This is comething to think about for the future.
 */

@interface RENodeGLState : NSObject {
    id state_;
    id parentState_;
    BOOL isParentStateDirty_;
}

@property (nonatomic, retain) id state; // State of self. Like [NSNumber numberWithBool:YES] for blendEnabled.
@property (nonatomic, retain) id parentState; // Parent's state.
@property (nonatomic, readonly) BOOL isParentStateDirty;

- (void)invalidateParentState;

@end

@interface RENode : NSObject {
    RENode *parent_; // weakref
    
    NSMutableArray *children;

    RECamera *camera_;
    
    REProgram *program; // Default program. Should be ok to use more programs though.

    // These are the three internal transforms that are applied to position the node in the world.
    CC3Vector translation; // Position in world. Defaults to (0,0,0).
    CC3Vector scale; // Scale relative to ModelCoordinate Bounding Box
    RERotator *rotator;

    CC3BoundingBox boundingBox; // ModelCoordinate bounding box;

    // In model coordinates. These defaults to (0,0,0)
    CC3Vector anchorCoordinate; // In model coordinates. Default to (0,0,0) You can also use anchorCoordinate property (when boundingBox is set)

    //CC3Vector contentSize; // Size of the model. Bounding box of model coordinate vertices
    
    CC3GLMatrix *transformMatrix; // The total model matrix will be made of of transformMatrix, and parent transform matrix
    CC3GLMatrix *globalTransformMatrix; // The global transform matrix. Will be updated every time it's needed.
    CC3Vector globalPosition_;
    BOOL isTransformMatrixDirty; // Indicates that both transformMatrix and therefore globalTransformMatrix is dirty.
    BOOL isGlobalTransformMatrixDirty;
    BOOL isGlobalPositionDirty_; // Is dirty as soon as  global transform matrix is changed
    

    
    BOOL hidden;
    NSNumber *alpha_;
    
    BOOL shouldClearStencilBuffer_;
    BOOL shouldClearColorBuffer_;
    BOOL shouldClearDepthBuffer_;
    
    int zOrder_; // Used when?
    
    // Node GLStates. These internal objects the current state and the state of the parent. The parent state is invalidated on each visit. By only updating the parent state each visit, we avoid long identical chains of state lookups when state is inherited.
    RENodeGLState *blendEnabledState_;
    RENodeGLState *blendFuncState_;
    RENodeGLState *colorMaskState_;
    RENodeGLState *cullFaceState_;
    RENodeGLState *cullFaceEnabledState_;
    RENodeGLState *depthMaskState_;
    RENodeGLState *depthTestEnabledState_;
    RENodeGLState *frontFaceState_;
    RENodeGLState *stencilFuncState_;
    RENodeGLState *stencilOpState_;
    RENodeGLState *stencilTestEnabledState_;
    
    NSNumber *clearsStencilBuffer_;
    
@protected
    CC3GLMatrix *modelViewMatrix; // Most efficient to keep it here? 
}

@property (nonatomic, assign, readonly) RENode *parent; // Parent node.
@property (nonatomic, readonly) REWorld *world; // Nearest parent that is world (Recursive)
@property (nonatomic, retain) RECamera *camera; // Default to get camera from world.

@property (nonatomic, readonly) NSArray *children;

@property (nonatomic, retain) REProgram *program; 

@property (nonatomic, assign) int zOrder; // NOT SUPPORTED, MAYBE IN THE FUTURE?

// These are the interface properties of translation, scale and rotation.
@property (nonatomic, assign) CC3Vector position; // Sets translation
@property (nonatomic, assign) CC3Vector size; // Affects scale according to MC bounding box
@property (nonatomic, assign) CC3Vector scale; // Scal of MC coordinates

@property (nonatomic, assign) CC3Vector rotation; // Euler angles
@property (nonatomic, assign) CC3Vector4 quaternion; // Quaternion
@property (nonatomic, assign) CC3Vector rotationAxis; // Rotation axis
@property (nonatomic, assign) float rotationAngle; // Angle around rotation axis. I

@property (nonatomic, assign) CC3BoundingBox boundingBox;
@property (nonatomic, readonly) CC3Vector boundingBoxSize; // Size of bounding box

@property (nonatomic, readonly) CC3BoundingBox globalBoundingBox; // Slow to compute. Don't use too often. It isn't cached either.

@property (nonatomic, assign) CC3Vector anchorPoint; // Only defined if we have bounding box. When using animation and bounding box may change, it may not be appropiate to set this value. Set anchor coordinate instead.
@property (nonatomic, assign) CC3Vector anchorCoordinate; // In model coordinates. default to (0,0,0)

// transformMatrix is the local transform matrix. The global model matrix will be made of of transformMatrix, and parent transform matrix. Don't override this. Consider overriding globalTransformMatrix instead
@property (nonatomic, readonly) CC3GLMatrix *transformMatrix; 

// The globalTransformMatrix is the matrix that will be the modelMatrix when drawing. It is made up of parent global transform matrix and own transformMatrix. Override this to for instance make drawing not respect parents.  Invalidated on each visit. Depends on self's transform matrix and parents matrix. 
@property (nonatomic, readonly) CC3GLMatrix *globalTransformMatrix; 
@property (nonatomic, readonly) CC3Vector globalPosition; // Position in world



@property (nonatomic, assign) BOOL hidden; // Will also hide subnodes
@property (nonatomic, readonly) BOOL isAncestorHidden; // If self or any ancestor is hidden
@property (nonatomic, retain) NSNumber *alpha;

// If set to nil, inherit from parent. (Default is inherit or YES)
@property (nonatomic, retain) NSNumber *blendEnabled;
@property (nonatomic, retain) NSValue *blendFunc; // REGLBlendFunc
@property (nonatomic, retain) NSValue *colorMask; 
@property (nonatomic, retain) NSNumber *cullFace;
@property (nonatomic, retain) NSNumber *cullFaceEnabled; 
@property (nonatomic, retain) NSNumber *depthTestEnabled;
@property (nonatomic, retain) NSNumber *depthMask; // BOOL
//@property (nonatomic, retain) NSNumber *frontFace; // NOT IMPLEMENTED
@property (nonatomic, retain) NSNumber *stencilTestEnabled;
@property (nonatomic, retain) NSValue *stencilFunc;
@property (nonatomic, assign) NSValue *stencilOp;

@property (nonatomic, retain) NSNumber *clearsStencilBuffer; // If YES, clears stencil buffer before draw. Default is NO.


@property (nonatomic, assign) GLfloat positionX; // Convinient setter/getter for position.x
@property (nonatomic, assign) GLfloat positionY; // Convinient setter/getter for position.y
@property (nonatomic, assign) GLfloat positionZ; // Convinient setter/getter for position.z

/*

// These matrices are used for drawing. They can be overrided if neccessary. For instance, REBillboard with certain mode
// in our implementation wants to set view matrix to identify, and to clever stuff with model matrix.
- (CC3GLMatrix*)modelMatrix;
- (CC3GLMatrix*)viewMatrix;
- (CC3GLMatrix*)projectionMatrix;
 */

+ (REProgram*)program; // The program of the node. Check of what it defaults to
+ (id)node; // Convenience

- (void)visit; 
- (void)draw;

- (void)setSizeX:(float)x;

- (void)addChild:(RENode*)node;
- (void)removeChild:(RENode*)node;
//- (void)insertChild:(RENode*)node aboveChild:(RENode*)aboveNode;
//- (void)insertChild:(RENode*)node belowChild:(RENode*)belowChild;

// Called after reciever was moved to new parent node.
- (void)didMoveToParent:(RENode*)parentNode;

// Will trigger removeChild of parentNode
- (void)removeFromParentNode;

// Default to YES if we have program. This will cause GL states that affects drawing to be changed, which should be correct most times. In some cases, there may be reason to override this, for instance, RESprite may want to return NO if it belongs to a spriteBatchNode to avoid uncessesary extra state traversing for potenatially many objects.
- (BOOL)willDraw;

- (BOOL)shouldCullTest; // If we should run cull test to discard object. Good for meshes but may not be very good for sprites and other simple geometry. Default is NO

// Action handling
- (void)runAction:(REAction*)action;
- (void)stopAllActions;
- (void)stopAction:(REAction*)action;

// Closest point where ray collides. If no collision, returns kCC3VectorZero. Ray should be given in global/world coordinates.
- (NSValue*)boundingBoxIntersectionForRay:(CC3Ray)worldRay;

// Use this when
- (RENode*)childIntersectingRay:(CC3Ray)ray hitPoint:(CC3Vector4*)hitPoint; // Nearest child whose bounding box intersects ray. Point is return value.
- (void)invalidateGlobalTransformMatrix; // Force initial step?; // Will also invalidate global bounding box, since it's based on global transform matrix


@end
