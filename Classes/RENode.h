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

#import "REProgram.h"
#import "REGLTypes.h"
#import "CC3Foundation.h"
#import "CC3GLMatrix.h"

@class REWorld;
@class RECamera;
@class REAction;
@class RERotator;
@class RENodeGLState;

/** RENode is the main element that makes up the scene graph.
 Nodes can contain children and may or may not be drawable.
 
 Subclasses: RECamera, RESprite, etc.
 */

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

/** Parent node. This property is set automatically by the parent when adding a child. */
@property (nonatomic, assign, readonly) RENode *parent;

/** Camera. If camera property is set the getter returns that object. Defaults to inherit from parent. */
@property (nonatomic, retain) RECamera *camera; 

/** Nearest parent of type REWorld. This is useful since the world may contain lights affecting the node. May be nil. */
@property (nonatomic, readonly) REWorld *world; 

/** List of children. The children will be visited according to the order in which they appear in the array. */
@property (nonatomic, readonly) NSArray *children;

/** Program used for drawing. */
@property (nonatomic, retain) REProgram *program; 

/** zOrder is currently not supported or implemented. */
@property (nonatomic, assign) int zOrder;

/** Position of the node relative to it's parent. */
@property (nonatomic, assign) CC3Vector position; 

/** Convenitent accessors for position.x/y/z */
@property (nonatomic, assign) GLfloat positionX, positionY, positionZ;

/** Size of the node in world space. This effectively sets the scale value by calculating it according to the bounding box. If the bounding box is of zero size, setting this property results in undefined behavior. */
@property (nonatomic, assign) CC3Vector size; 

/** Scale determines the scale value relative to its parent and size in model space. */
@property (nonatomic, assign) CC3Vector scale; 

/** Euler angles rotation of the node relative to its parent */
@property (nonatomic, assign) CC3Vector rotation; 

/** Quaternion rotation of the node relative to its parent. */
@property (nonatomic, assign) CC3Vector4 quaternion; 

/** Rotation axis of the node relative to its parent */
@property (nonatomic, assign) CC3Vector rotationAxis; // Rotation axis

/** Rotation angle around rotationAxis of the node relative to its parent */
@property (nonatomic, assign) float rotationAngle;

/** Bounding box in local model space. */
@property (nonatomic, assign) CC3BoundingBox boundingBox;

/** Bounding box size in local model space. Calculated lazily from boundingBox. */
@property (nonatomic, readonly) CC3Vector boundingBoxSize; 

/** Global bounding box in world space. Calculated on request by transforming bounding box corners according to the global transorm matrix. This may be slow to compute, and the result is not cached. */
@property (nonatomic, readonly) CC3BoundingBox globalBoundingBox; 

/** Anchor coordinate defines the coordinate in model space around which translation, scale and rotation is made */
@property (nonatomic, assign) CC3Vector anchorCoordinate; // In model coordinates. default to (0,0,0)

/** Anchor point is a conveniece method for setting anchor coordinate relative to bounding box. If bounding box is zero, setting this property results in undefined behaviour. */
@property (nonatomic, assign) CC3Vector anchorPoint; 

/** Transform matrix defines the full transform relative to it's parent. It's calculated from position, scale and rotation properties once per draw cycle. */
@property (nonatomic, readonly) CC3GLMatrix *transformMatrix; 

/** The global transform matrix defines the entire transform hierarchy from model to world space. It's created by traversing the node hierarchy and multiplying the ancestor nodes' transform matrices. Invalidated and re-calculated on each visit. */
@property (nonatomic, readonly) CC3GLMatrix *globalTransformMatrix; 

/** Global position in the world. Calculated by transforming the position property according to the global transform matrix. Calculated on each call and is not cached, so this method may be expensive */
@property (nonatomic, readonly) CC3Vector globalPosition; 

/** If hidden, the node is not visited */
@property (nonatomic, assign) BOOL hidden;

/** Returns YES if node or any ancestor node is hidden. NOTE: Not sure if this method is really needed. */
@property (nonatomic, readonly) BOOL isAncestorHidden; 

/** Alpha value [0,1] of the node. It's up to the drawing method to respect this. */
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

/** If YES, clears stencil buffer before draw. Default is NO. **/
@property (nonatomic, retain) NSNumber *clearsStencilBuffer; 


/** Convenieve method */
+ (id)node; 

/** The shader program of this node, may be nil. A node should use only one program for drawing, if you need multiple programs, consider separariting them into separate node subclasses. Use [REProgram programWithVertexFilename:fragmentFilename:] to create the program since it caches the result.  */
+ (REProgram*)program;

/** The node is visited once each frame. This method sets the defined GL state as well as the current shader program. */
- (void)visit; 

/** If the node contains a program, this method should be overridden by subclasses to perform any drawing using this program. The GL state defined like blendEnabled, blendFunc, cullFace, etc are already set here. */
- (void)draw;

/** Sets a uniform size based on x value. Should be renamed by setSizeUniformX:. */
- (void)setSizeX:(float)x;

/** Add a child to the node hierarchy. */
- (void)addChild:(RENode*)node;

/** Will trigger removeChild of parentNode '*/
- (void)removeFromParentNode;

/** Called after reciever was moved to new parent node. */
- (void)didMoveToParent:(RENode*)parentNode;

/** Default to YES if we have program. This will cause GL states that affects drawing to be changed, which should be correct most times. In some cases, there may be reason to override this, for instance, RESprite may want to return NO if it belongs to a spriteBatchNode to avoid uncessesary extra state traversing for potenatially many objects. */
- (BOOL)willDraw;

/** Defines whether we should run cull test to discard object. Good for meshes but may not be very good for sprites and other simple geometry. Default is NO. */
- (BOOL)shouldCullTest; 

/** Closest point where given ray collides with the nodes bounding box in global coordinates. If no collision, returns kCC3VectorZero/nil. Ray should be given in global world coordinates. */
- (NSValue*)boundingBoxIntersectionForRay:(CC3Ray)worldRay;

/** Nearest child whose bounding box intersects given ray. Point is return value. */
- (RENode*)childIntersectingRay:(CC3Ray)ray hitPoint:(CC3Vector4*)hitPoint; 

/** Invalutes global transform matrix. This is done once per draw cycle. */
- (void)invalidateGlobalTransformMatrix;

@end


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
