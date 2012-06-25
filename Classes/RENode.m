
#import "RENode.h"
#import "RECamera.h"
#import "RERotator.h"
#import "RENSValueAdditions.h"
#import "RECache.h"
#import "REBuffer.h"
#import "REGLStateManager.h"
#import "RENSArrayAdditions.h"
#import "RENSValueAdditions.h"
#import "NSValue+CC3Types.h"

@interface RENode ()

@property (nonatomic, assign, readwrite) RENode *parent;

// Helper function to get state. "State" is instance variable. Returns nil if no appropiate stae could be found.
- (id)state:(RENodeGLState*)state getter:(SEL)getter;

// Helper function to set state. "State" is instance variable.
- (void)setState:(RENodeGLState*)state value:(id)value;

@end

@implementation RENode

@synthesize parent = parent_;
@synthesize camera = camera_;
@synthesize children, program, rotation, boundingBox;
@synthesize anchorCoordinate;
@synthesize globalTransformMatrix;
@synthesize hidden, depthMask;

@synthesize zOrder = zOrder_;

@synthesize alpha = alpha_;
@synthesize clearsStencilBuffer = clearsStencilBuffer_;

@synthesize globalPosition = globalPosition_;


- (id)init {
    if ((self = [super init])) {
        
        program = [[REProgramCache sharedCache] programForKey:NSStringFromClass([self class])];
        if (program == nil) {
            program = [[self class] program];
            if (program) {
                [[REProgramCache sharedCache] setProgram:program forKey:NSStringFromClass([self class])];
            }
        } [program retain];
        
        rotator = [[RERotator alloc] init]; // Will init to zero rotation (identify matrix)
        
        children = [[NSMutableArray alloc] init];
        
        translation = CC3VectorMake(0, 0, 0);
        scale = CC3VectorMake(1, 1, 1);
        
        anchorCoordinate = CC3VectorMake(0, 0, 0);
        
        self.rotationAxis = CC3VectorMake(0, 1, 0);
        
        boundingBox = CC3BoundingBoxMake(0, 0, 0, 0, 0, 0);
        
        transformMatrix = [[CC3GLMatrix alloc] initIdentity];
        globalTransformMatrix = [[CC3GLMatrix alloc] initIdentity];
        
        isTransformMatrixDirty = YES;
        isGlobalTransformMatrixDirty = YES;
        isGlobalPositionDirty_ = YES;
        
        blendEnabledState_ = [[RENodeGLState alloc] init];
        blendFuncState_ = [[RENodeGLState alloc] init];
        colorMaskState_ = [[RENodeGLState alloc] init];
        cullFaceState_ = [[RENodeGLState alloc] init];
        cullFaceEnabledState_ = [[RENodeGLState alloc] init];
        depthMaskState_ = [[RENodeGLState alloc] init];
        depthTestEnabledState_ = [[RENodeGLState alloc] init];
        frontFaceState_ = [[RENodeGLState alloc] init];
        stencilFuncState_ = [[RENodeGLState alloc] init];
        stencilOpState_ = [[RENodeGLState alloc] init];
        stencilTestEnabledState_ = [[RENodeGLState alloc] init];
        
        //stencilOp_ = REGLStencilOpMake(GL_KEEP, GL_KEEP, GL_KEEP);
        //stencilFunc_ = REGLStencilFuncMake(GL_ALWAYS, 0, 0xFFFFFFFF); // 16 ones  ~(~0 << 32)
        
        //blendFunc = REGLBlendFuncMake(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        modelViewMatrix = [[CC3GLMatrix alloc] init];
        
        alpha_ = [[NSNumber alloc] initWithInt:1.0]; // Default to 1 for speed

    } return self;
}

- (void)dealloc {
    
    [alpha_ release];
    
    [blendEnabledState_ release];
    [blendFuncState_ release];
    [colorMaskState_ release];
    [cullFaceState_ release];
    [cullFaceEnabledState_ release];
    [depthMaskState_ release];
    [depthTestEnabledState_ release];
    [frontFaceState_ release];
    [stencilFuncState_ release];
    [stencilOpState_ release];
    [stencilTestEnabledState_ release];
    [clearsStencilBuffer_ release];
    
    [rotator release];
    
    [program release];  
    [transformMatrix release];
    [globalTransformMatrix release];
    [modelViewMatrix release];
    
    for (RENode *child in children) {
        child.parent = nil;
    }
    
    [children release];
    
    [camera_ release];
    
    [super dealloc];
}


#pragma mark - General

+ (id)node {
    return [[[self alloc] init] autorelease];
}

// Defaults to: (This could easily be changed/customized later)


+ (REProgram*)program {
    
    REProgram *p = nil;
    
    // Don't default to anything. That could cause confusion and would for instance inefficieny if we would create RENode.vsh and RENode.fsh files without using them.
    
    /*
    NSString *defaultVertexShaderFilename = [NSString stringWithFormat:@"s%@.vsh", NSStringFromClass([self class])];
    NSString *defaultFragmentShaderFilename = [NSString stringWithFormat:@"s%@.fsh", NSStringFromClass([self class])];
    
    
    // 1. Shadernames given by shadername, if existing
    if ([[NSBundle mainBundle] pathForResource:defaultVertexShaderFilename ofType:nil] && [[NSBundle mainBundle] pathForResource:defaultFragmentShaderFilename ofType:nil]) {
        p = [REProgram programWithVertexFilename:defaultVertexShaderFilename fragmentFilename:defaultFragmentShaderFilename];
    }
     */
    
    // 1. Superclass's program
    if ([[self superclass] isKindOfClass:[RENode class]]) {
        p = [[self superclass] program];
    } 
    
    // 2 nil
    else {
        p = nil;
    }
    
    return p; 
}

- (REWorld*)world {
    return [self isKindOfClass:[REWorld class]] ? (REWorld*)self : parent_.world;
}

- (RECamera*)camera {
    return camera_ ? camera_ : [parent_ camera];
}

#pragma mark - GLState

// State helper
- (id)state:(RENodeGLState*)state getter:(SEL)getter {
    id v = nil;
    
    // If state has been set for this node. Use it.
    if (state.state) {
        v = state.state;
    } 
    
    // Else, if this node has no state
    else {
        
        // First check if we have parent
        if (parent_) {
            // If so, make sure that it's value is up to date, and then use that value
            if (state.isParentStateDirty) {
                state.parentState = [self.parent performSelector:getter];
            } v = state.parentState;
        } 
        
        // If we're here, we have no parent and no local state. Use default.
        else {
            v = nil;
        }
    } return v;
}

- (void)setState:(RENodeGLState*)state value:(id)value {
    state.state = value;
}

// Blend enabled. 
- (NSNumber *)blendEnabled {
    NSNumber *v = [self state:blendEnabledState_ getter:@selector(blendEnabled)];
    return v ? v : [NSNumber numberWithBool:YES];
}

- (void)setBlendEnabled:(NSNumber*)v {
    [self setState:blendEnabledState_ value:v];
}


// Blend Func
- (NSValue *)blendFunc {
    NSValue *v = [self state:blendFuncState_ getter:@selector(blendFunc)];
    return v ? v : [NSValue valueWithREGLBlendFunc:REGLBlendFuncMake(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)];
}

- (void)setBlendFunc:(NSValue *)v {
    [self setState:blendFuncState_ value:v];
}

// Cull face 
- (NSNumber *)cullFace {
    NSNumber *v = [self state:cullFaceState_ getter:@selector(cullFace)];
    return v ? v : [NSNumber numberWithInt:GL_BACK];
}

- (void)setCullFace:(NSNumber*)v {
    [self setState:cullFaceState_ value:v];
}

// Cull face enabled. 
- (NSNumber *)cullFaceEnabled {
    NSNumber *v = [self state:cullFaceEnabledState_ getter:@selector(cullFaceEnabled)];
    return v ? v : [NSNumber numberWithBool:YES];
}

- (void)setCullFaceEnabled:(NSNumber*)v {
    [self setState:cullFaceEnabledState_ value:v];
}

// Depth test enabled. 
- (NSNumber *)depthTestEnabled {
    NSNumber *v = [self state:depthTestEnabledState_ getter:@selector(depthTestEnabled)];
    return v ? v : [NSNumber numberWithBool:YES];
}

- (void)setDepthTestEnabled:(NSNumber*)v {
    [self setState:depthTestEnabledState_ value:v];
}

// Depth mask
- (NSNumber *)depthMask {
    NSNumber *v = [self state:depthMaskState_ getter:@selector(depthMask)];
    return v ? v : [NSNumber numberWithBool:YES];
}

- (void)setDepthMask:(NSNumber*)v {
    [self setState:depthMaskState_ value:v];
}

// Stencil test
- (NSNumber *)stencilTestEnabled {
    NSNumber *v = [self state:stencilTestEnabledState_ getter:@selector(stencilTestEnabled)];
    return v ? v : [NSNumber numberWithBool:NO];
}

- (void)setStencilTestEnabled:(NSNumber *)v {
    [self setState:stencilTestEnabledState_ value:v];
}

// Stencil Func
- (NSValue *)stencilFunc {
    NSNumber *v = [self state:stencilFuncState_ getter:@selector(stencilFunc)];
    return v ? v : [NSValue valueWithREGLStencilFunc:REGLStencilFuncMake(GL_EQUAL, 1, 1)];
}

- (void)setStencilFunc:(NSNumber *)v {
    [self setState:stencilFuncState_ value:v];
}

// Stencil Op
- (NSValue *)stencilOp {
    NSNumber *v = [self state:stencilOpState_ getter:@selector(stencilOp)];
    return v ? v : [NSValue valueWithREGLStencilOp:REGLStencilOpMake(GL_KEEP, GL_KEEP, GL_KEEP)];
}

- (void)setStencilOp:(NSNumber *)v {
    [self setState:stencilOpState_ value:v];
}

// Color mask
- (NSValue *)colorMask {
    NSValue *v = [self state:colorMaskState_ getter:@selector(colorMask)];
    return v ? v : [NSValue valueWithREGLColorMask:REGLColorMaskMake(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE)];
}

- (void)setColorMask:(NSValue*)v {
    [self setState:colorMaskState_ value:v];
}

#pragma mark - Alpha / Hidden

- (NSNumber*)alpha {
    return alpha_ ? alpha_ : (parent_ ? parent_.alpha : [NSNumber numberWithFloat:1.0]);
}

- (BOOL)isAncestorHidden {
    return hidden ? YES : (parent_ ? parent_.hidden : NO);
}

#pragma mark - Render buffers

- (NSNumber*)clearsStencilBuffer {
    return clearsStencilBuffer_ ? clearsStencilBuffer_ : [NSNumber numberWithBool:NO];
}

/*
 //stencilOp_ = REGLStencilOpMake(GL_KEEP, GL_KEEP, GL_KEEP);
 //stencilFunc_ = REGLStencilFuncMake(GL_ALWAYS, 0, 0xFFFFFFFF); // 16 ones  ~(~0 << 32)
 */

#pragma mark - Transformation Matrix


- (CC3GLMatrix*)transformMatrix {
    if (isTransformMatrixDirty) {
        isTransformMatrixDirty = NO;
        
        [transformMatrix populateIdentity];
        
        [transformMatrix translateBy:translation];         
        [transformMatrix rotateByQuaternion:rotator.quaternion];
        [transformMatrix scaleBy:scale];
        
        // Translate to anchor
        [transformMatrix translateBy:CC3VectorNegate(anchorCoordinate)];
        
    } return transformMatrix;
}

// This property is updated on each visit. (It can be difficult to know when it has changed.)
- (CC3GLMatrix*)globalTransformMatrix {
    // Determine how we should do this. May be complicated with wave group nodes, etc (and it's relationship to parent)
    // Invalidated on each visit
    if (isGlobalTransformMatrixDirty) {
        isGlobalTransformMatrixDirty = NO;
        isGlobalPositionDirty_ = YES; // Invalidate global position
        self.parent ? [globalTransformMatrix populateFrom:self.parent.globalTransformMatrix] : [globalTransformMatrix populateIdentity];
        [globalTransformMatrix multiplyByMatrix:self.transformMatrix];
        
        
    } return globalTransformMatrix;
}

- (CC3Vector)globalPosition {
    // Disabled if statement because of incorrect behavior
    if (YES || isGlobalPositionDirty_) {
        isGlobalPositionDirty_ = NO;
        globalPosition_ = [self.globalTransformMatrix transformLocation:translation];
    } return globalPosition_;
}

/*
#pragma mark - Draw Matrices

- (CC3GLMatrix*)modelMatrix {
    return self.globalTransformMatrix;
}

- (CC3GLMatrix*)viewMatrix {
    RECamera *c = self.camera;
    return c ? c.viewMatrix : nil;
}

- (CC3GLMatrix*)projectionMatrix {
    RECamera *c = self.camera;
    return c ? c.projectionMatrix : nil;
}
 */

#pragma mark - Visit/Draw

- (void)visit {
    
    isGlobalTransformMatrixDirty = YES; // Update on each visit
    
    // Quick return if hidden or no alpha
    if (hidden || ([self.alpha floatValue] == 0)) {
        return;
    }
    
    [REBuffer unbind];
    //[REVertexArrayObject unbind];
    
    
    
    // Inalidate parent state. THIS SEEMS TO BE VERY EXPENSIVE. NOT SURE IF IT'S WORTH IT?
    
    /*
    [blendEnabledState_ invalidateParentState];
    [blendFuncState_ invalidateParentState];
    [colorMaskState_ invalidateParentState];
    [cullFaceEnabledState_ invalidateParentState];
    [depthMaskState_ invalidateParentState];
    [depthTestEnabledState_ invalidateParentState];
    [frontFaceState_ invalidateParentState];
    [stencilFuncState_ invalidateParentState];
    [stencilOpState_ invalidateParentState];
    [stencilTestEnabledState_ invalidateParentState];
     */
     
                             
    
    

    // Set draw states if we have program
    if ([self willDraw]) {
        REGLStateManager *stateManager = [REGLStateManager sharedManager];
        [stateManager setBlendEnabled:[self.blendEnabled boolValue]];
        [stateManager setBlendFunc:[self.blendFunc REGLBlencFuncValue]];
        [stateManager setColorMask:[self.colorMask REGLColorMaskValue]];
        [stateManager setDepthTestEnabled:[self.depthTestEnabled boolValue]];
        [stateManager setDepthMask:[self.depthMask boolValue]];
        [stateManager setCullFaceEnabled:[self.cullFaceEnabled boolValue]];
        [stateManager setCullFace:[self.cullFace intValue]];
        [stateManager setStencilTestEnabled:[self.stencilTestEnabled boolValue]];
        [stateManager setStencilFunc:[self.stencilFunc REGLStencilFuncValue]];
        [stateManager setStencilOp:[self.stencilOp REGLStencilOpValue]];
    }
    
    // Clears stencil buffer if requested
    
    if ([self.clearsStencilBuffer boolValue]) {
        glClear(GL_STENCIL_BUFFER_BIT);
    }
    
    // Test if we can cull
    BOOL cull = NO;
    if ([self shouldCullTest] && [self willDraw] && !CC3BoundingBoxIsNull(boundingBox)) {
        cull = [self.camera globalBoundingBoxCanBeCulled:self.globalBoundingBox];
    }

    if ([self willDraw] && !cull) {
        
        [self.program use];
        [self draw];
    }
    
    for (RENode *child in children) {
        [child visit];
    }
}



- (void)draw {
    // Use the default program if we have any (we also need camera)
    if ([self willDraw]) {
        //glUseProgram(program.program);  
        [self.program use];
        
        RECamera *cam = self.camera;
        
        // Set model,view and projection matrix.
        // These are put in seperated methods so they can be easily overriden.
        /*
        CC3GLMatrix *modelMatrix = [self modelMatrix]; //  self.globalTransformMatrix;
        CC3GLMatrix *viewMatrix = [self viewMatrix]; // cam ? cam.viewMatrix : [CC3GLMatrix identity];
        CC3GLMatrix *projectionMatrix = [self projectionMatrix]; // cam ? cam.projectionMatrix : [CC3GLMatrix identity];
         */
        
        CC3GLMatrix *modelMatrix = self.globalTransformMatrix;
        CC3GLMatrix *viewMatrix = cam ? cam.viewMatrix : [CC3GLMatrix identity];
        CC3GLMatrix *projectionMatrix = cam ? cam.projectionMatrix : [CC3GLMatrix identity];

        
        //CC3GLMatrix *modelViewMatrix = [[viewMatrix copy] autorelease];
        [modelViewMatrix populateFrom:viewMatrix];
        [modelViewMatrix multiplyByMatrix:modelMatrix];
        
        CC3GLMatrix *modelViewProjectionMatrix = [CC3GLMatrix matrixFromGLMatrix:projectionMatrix.glMatrix];
        [modelViewProjectionMatrix multiplyByMatrix:modelViewMatrix];
        
        
        GLint u_mMatrix = [program uniformLocation:@"u_mMatrix"];
        GLint u_mvMatrix = [program uniformLocation:@"u_mvMatrix"];
        GLint u_pMatrix = [program uniformLocation:@"u_pMatrix"];
        GLint u_mvpMatrix = [program uniformLocation:@"u_mvpMatrix"];
        
        // Should make optional to have u_mvMatrix and u_pMatrix?
        if (u_mMatrix != -1) glUniformMatrix4fv(u_mMatrix, 1, GL_FALSE, modelMatrix.glMatrix);
        if (u_mvMatrix != -1) glUniformMatrix4fv(u_mvMatrix, 1, GL_FALSE, modelViewMatrix.glMatrix);
        if (u_pMatrix != -1) glUniformMatrix4fv(u_pMatrix, 1, GL_FALSE, projectionMatrix.glMatrix);
        if (u_mvpMatrix != -1) glUniformMatrix4fv(u_mvpMatrix, 1, GL_FALSE, modelViewProjectionMatrix.glMatrix);
        
        
        // Break all previous buffer bindings glVertexAttribPointer bound to buffers to avoid this error:
        // Draw call exceeded array buffer bounds
        // A draw call accessed a vertex outside the range of an array buffer in use.  This is a serious error, and may result in a crash.
        
        /*

         glVertexAttribPointer
         
         If a non-zero named buffer object is bound to the GL_ARRAY_BUFFER target (see glBindBuffer) while a generic vertex attribute array is specified, pointer is treated as a byte offset into the buffer object's data store. Also, the buffer object binding (GL_ARRAY_BUFFER_BINDING) is saved as generic vertex attribute array client-side state (GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING) for index index.
        
         // This GET can help with the problem.
        glGetVertexAttrib with arguments index and GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING
         */

    }
}

- (BOOL)willDraw {
    return program && !hidden && [self.alpha floatValue] > 0.0;
}

- (BOOL)shouldCullTest {
    return NO;
}


#pragma mark - Accessors

- (CC3Vector)boundingBoxSize {
    return CC3VectorMake(fabs(boundingBox.minimum.x - boundingBox.maximum.x), 
                         fabs(boundingBox.minimum.y - boundingBox.maximum.y),
                         fabs(boundingBox.minimum.z - boundingBox.maximum.z));
}

/*
- (CC3BoundingBox)globalBoundingBox {
    // Min/max may become distored when transforming, so make sure that it's correct.
    CC3BoundingBox box = CC3BoundingBoxFromMinMax([self.globalTransformMatrix transformLocation:boundingBox.minimum],
                                                  [self.globalTransformMatrix transformLocation:boundingBox.maximum]);
    return CC3BoundingBoxFromMinMax(CC3VectorMake(MIN(box.minimum.x, box.maximum.x), MIN(box.minimum.y, box.maximum.y), MIN(box.minimum.z, box.maximum.z)),
                                    CC3VectorMake(MAX(box.minimum.x, box.maximum.x), MAX(box.minimum.y, box.maximum.y), MAX(box.minimum.z, box.maximum.z)));
}
 */

- (CC3BoundingBox)globalBoundingBox {
    
    // All 8 points of local box
    CC3Vector boundingBoxPoint0 = CC3VectorMake(boundingBox.minimum.x, boundingBox.minimum.y, boundingBox.minimum.z);
    CC3Vector boundingBoxPoint1 = CC3VectorMake(boundingBox.minimum.x, boundingBox.minimum.y, boundingBox.maximum.z);
    CC3Vector boundingBoxPoint2 = CC3VectorMake(boundingBox.minimum.x, boundingBox.maximum.y, boundingBox.minimum.z);
    CC3Vector boundingBoxPoint3 = CC3VectorMake(boundingBox.minimum.x, boundingBox.maximum.y, boundingBox.maximum.z);
    CC3Vector boundingBoxPoint4 = CC3VectorMake(boundingBox.maximum.x, boundingBox.minimum.y, boundingBox.minimum.z);
    CC3Vector boundingBoxPoint5 = CC3VectorMake(boundingBox.maximum.x, boundingBox.minimum.y, boundingBox.maximum.z);
    CC3Vector boundingBoxPoint6 = CC3VectorMake(boundingBox.maximum.x, boundingBox.maximum.y, boundingBox.minimum.z);
    CC3Vector boundingBoxPoint7 = CC3VectorMake(boundingBox.maximum.x, boundingBox.maximum.y, boundingBox.maximum.z);
    
    // All 8 points of global box
    CC3Vector globalBoundingBoxPoint0 = [self.globalTransformMatrix transformLocation:boundingBoxPoint0];
    CC3Vector globalBoundingBoxPoint1 = [self.globalTransformMatrix transformLocation:boundingBoxPoint1];
    CC3Vector globalBoundingBoxPoint2 = [self.globalTransformMatrix transformLocation:boundingBoxPoint2];
    CC3Vector globalBoundingBoxPoint3 = [self.globalTransformMatrix transformLocation:boundingBoxPoint3];
    CC3Vector globalBoundingBoxPoint4 = [self.globalTransformMatrix transformLocation:boundingBoxPoint4];
    CC3Vector globalBoundingBoxPoint5 = [self.globalTransformMatrix transformLocation:boundingBoxPoint5];
    CC3Vector globalBoundingBoxPoint6 = [self.globalTransformMatrix transformLocation:boundingBoxPoint6];
    CC3Vector globalBoundingBoxPoint7 = [self.globalTransformMatrix transformLocation:boundingBoxPoint7];
    
    
    CC3Vector globalBoundingBoxPoints[8] = {globalBoundingBoxPoint0, globalBoundingBoxPoint1, globalBoundingBoxPoint2, globalBoundingBoxPoint3, globalBoundingBoxPoint4, globalBoundingBoxPoint5, globalBoundingBoxPoint6, globalBoundingBoxPoint7};
    
    CC3Vector globalBoundingBoxMin = globalBoundingBoxPoints[0];
    CC3Vector globalBoundingBoxMax = globalBoundingBoxPoints[0];
    
    // Find global min and max
    for (int i = 1; i < 8; i++) {
        if (globalBoundingBoxMin.x > globalBoundingBoxPoints[i].x) globalBoundingBoxMin.x = globalBoundingBoxPoints[i].x;
        if (globalBoundingBoxMin.y > globalBoundingBoxPoints[i].y) globalBoundingBoxMin.y = globalBoundingBoxPoints[i].y;
        if (globalBoundingBoxMin.z > globalBoundingBoxPoints[i].z) globalBoundingBoxMin.z = globalBoundingBoxPoints[i].z;
        
        if (globalBoundingBoxMax.x < globalBoundingBoxPoints[i].x) globalBoundingBoxMax.x = globalBoundingBoxPoints[i].x;
        if (globalBoundingBoxMax.y < globalBoundingBoxPoints[i].y) globalBoundingBoxMax.y = globalBoundingBoxPoints[i].y;
        if (globalBoundingBoxMax.z < globalBoundingBoxPoints[i].z) globalBoundingBoxMax.z = globalBoundingBoxPoints[i].z;
    }
    
    return CC3BoundingBoxFromMinMax(globalBoundingBoxMin, globalBoundingBoxMax);
    
}

- (CC3Vector)position {
    return translation;
}

- (void)setPosition:(CC3Vector)p {
    translation = p;
    isTransformMatrixDirty = YES;
}

- (void)setPositionX:(float)x { translation.x = x; isTransformMatrixDirty = YES; }
- (void)setPositionY:(float)y { translation.y = y; isTransformMatrixDirty = YES; }
- (void)setPositionZ:(float)z { translation.z = z; isTransformMatrixDirty = YES; }
- (GLfloat)positionX { return translation.x; }
- (GLfloat)positionY { return translation.y; }
- (GLfloat)positionZ { return translation.z; }

- (CC3Vector)size {    
    CC3Vector boundingBoxSize = self.boundingBoxSize;
    
    return CC3VectorMake(scale.x * boundingBoxSize.x, 
                         scale.y * boundingBoxSize.y, 
                         scale.z * boundingBoxSize.z);
}

- (void)setSize:(CC3Vector)size {
    CC3Vector boundingBoxSize = self.boundingBoxSize;
    self.scale = CC3VectorMake(boundingBoxSize.x > 0 ? size.x / boundingBoxSize.x : 0,
                          boundingBoxSize.y > 0 ? size.y / boundingBoxSize.y : 0,
                          boundingBoxSize.z > 0 ? size.z / boundingBoxSize.z : 0);
    //isTransformMatrixDirty = YES;
}

- (void)setSizeX:(float)x {
    CC3Vector boundingBoxSize = self.boundingBoxSize;
    float uniformScale = boundingBoxSize.x > 0 ? x / boundingBoxSize.x : 0;
    self.scale = CC3VectorMake(uniformScale, uniformScale, uniformScale);
    //isTransformMatrixDirty = YES;
}

- (CC3Vector)scale {
    return scale;
}

- (void)setScale:(CC3Vector)s {
    scale = s;
    isTransformMatrixDirty = YES;
}

- (CC3Vector)rotation {
    return rotator.rotation;
}

- (void)setRotation:(CC3Vector)r {
    rotator.rotation = r;
    isTransformMatrixDirty = YES;
}

- (CC3Vector4)quaternion {
    return rotator.quaternion;
}

- (void)setQuaternion:(CC3Vector4)q {
    rotator.quaternion = q;
    isTransformMatrixDirty = YES;
}

- (CC3Vector)rotationAxis {
    return rotator.rotationAxis;
}

- (void)setRotationAxis:(CC3Vector)axis {
    rotator.rotationAxis = axis;
    isTransformMatrixDirty = YES;
}

- (float)rotationAngle {
    return rotator.rotationAngle;
}

- (void)setRotationAngle:(float)angle {
    rotator.rotationAngle = angle;
    isTransformMatrixDirty = YES;
}

#pragma mark - Add/Remove Children

- (void)setParent:(RENode *)parent {
    if (parent_ != parent) {
        parent_ = parent;
        [self didMoveToParent:parent_];
    }
}

- (void)addChild:(RENode*)node {
    if (node) {

        if (node.parent) {
            [node removeFromParentNode];
        }
        
        [children addObject:node];
        node.parent = self;
    }
}

- (void)removeChild:(RENode*)node {
    
    NSInteger index = [children indexOfObjectIdenticalTo:node];
    
    // Check if node actually is a children.
    if (index != NSNotFound) {
        [children removeObjectAtIndex:index];
        node.parent = nil;
    } 
}

/* // REMOVE 
- (void)insertChild:(RENode*)node aboveChild:(RENode*)aboveNode {
    if (node) {
        int index = [children indexOfObject:aboveNode];
        NSAssert(index != NSNotFound, @"RENode: Can't insert child");
        [children insertObject:node atIndex:index + 1];
        node.parent = self;
    }
}
- (void)insertChild:(RENode*)node belowChild:(RENode*)belowChild {
    if (node) {
        int index = [children indexOfObject:belowChild];
        NSAssert(index != NSNotFound, @"RENode: Can't insert child");
        [children insertObject:node atIndex:index];
        node.parent = self;
    }
}
 */

- (void)didMoveToParent:(RENode*)parentNode {
    if (parentNode) {
        
    }
    
}

- (void)removeFromParentNode {
    if (parent_) {
        [[self retain] autorelease];
        [parent_ removeChild:self];
    }
}

#pragma mark - Anchor

- (CC3Vector)anchorPoint {
    
    CC3Vector boundingBoxSize = self.boundingBoxSize;
    
    return CC3VectorMake(boundingBoxSize.x > 0 ? (anchorCoordinate.x - boundingBox.minimum.x) / boundingBoxSize.x : 0,
                         boundingBoxSize.y > 0 ? (anchorCoordinate.y - boundingBox.minimum.y) / boundingBoxSize.y : 0,
                         boundingBoxSize.z > 0 ? (anchorCoordinate.z - boundingBox.minimum.z) / boundingBoxSize.z : 0);
     
    
}

- (void)setAnchorPoint:(CC3Vector)point {
    CC3Vector boundingBoxSize = self.boundingBoxSize;
    anchorCoordinate = CC3VectorMake(boundingBox.minimum.x + (boundingBoxSize.x > 0 ? point.x * boundingBoxSize.x : 0),
                                     boundingBox.minimum.y + (boundingBoxSize.y > 0 ? point.y * boundingBoxSize.y : 0),
                                     boundingBox.minimum.z + (boundingBoxSize.z > 0 ? point.z * boundingBoxSize.z : 0));
    isTransformMatrixDirty = YES;
}

- (CC3Vector)anchorCoordinate {
    return anchorCoordinate;
}

- (void)setAnchorCoordinate:(CC3Vector)coordinate {
    anchorCoordinate = coordinate;
}

#pragma mark - Ray Intersection

// Ray collision
- (NSValue*)boundingBoxIntersectionForRay:(CC3Ray)ray {
    //NSLog(@"boundingBoxIntersectionForRay: %f, %f, %f -> %f, %f, %f", ray.startLocation.x, ray.startLocation.y, ray.startLocation.z, ray.direction.x, ray.direction.y, ray.direction.z);
    
    
    
    // Both ray and box should be in global coordinates
    CC3BoundingBox box = self.globalBoundingBox;
    
    //NSLog(@"global box size: %f, %f, %f", box.maximum.x - box.minimum.x, box.maximum.y - box.minimum.y, box.maximum.z - box.minimum.z);
    
    // Near/Far, Bottom/Top, Left/Right
    CC3Vector boxNBL = box.minimum;
    CC3Vector boxNBR = CC3VectorAdd(box.minimum, CC3VectorMake(box.maximum.x - box.minimum.x, 0, 0));
    CC3Vector boxNTL = CC3VectorAdd(box.minimum, CC3VectorMake(0, box.maximum.y - box.minimum.y, 0));
    CC3Vector boxNTR = CC3VectorAdd(box.minimum, CC3VectorMake(box.maximum.x - box.minimum.x, box.maximum.y - box.minimum.y, 0));
    
    CC3Vector boxFBL = CC3VectorAdd(box.minimum, CC3VectorMake(0, 0, box.maximum.z - box.minimum.z));
    CC3Vector boxFBR = CC3VectorAdd(box.minimum, CC3VectorMake(box.maximum.x - box.minimum.x, 0, box.maximum.z - box.minimum.z));
    CC3Vector boxFTL = CC3VectorAdd(box.minimum, CC3VectorMake(0, box.maximum.y - box.minimum.y, box.maximum.z - box.minimum.z));
    CC3Vector boxFTR = box.maximum;
    
    
    CC3Vector *sides = calloc(6 * 4, sizeof(CC3Vector));
    
    sides[0] = boxNBL; sides[1] = boxNBR; sides[2] = boxNTL; sides[3] = boxNTR; // zNeg
    sides[4] = boxFBL; sides[5] = boxFBR; sides[6] = boxFTL; sides[7] = boxFTR; // zPos
    sides[8] = boxNBL; sides[9] = boxNTL; sides[10] = boxFBL; sides[11] = boxFTL; // xNeg
    sides[12] = boxNBR; sides[13] = boxNTR; sides[14] = boxFBR; sides[15] = boxFTR; // xPos
    sides[16] = boxNBL; sides[17] = boxNBR; sides[18] = boxFBL; sides[19] = boxFBR; // yNeg
    sides[20] = boxNTL; sides[21] = boxNTR; sides[22] = boxFTL; sides[23] = boxFTR; // yPos
    
    CC3Vector4 closestHit = kCC3Vector4Zero; // Will be non zero on first hit. Point closest to ray start location.
    
    // Loop sides
    for (int i = 0; i < 6; i++) {
        
        CC3Vector *side = sides + (i * 4);
        
        CC3Plane plane = CC3PlaneFromPoints(side[0], side[1], side[2]);
        
        CC3Vector4 planeIntersection = CC3RayIntersectionWithPlane(ray, plane);
        
        if (CC3Vector4sAreEqual(planeIntersection, kCC3Vector4Zero)) {
            continue;
        }
        
         //NSLog(@"hit: %f, %f, %f, %f", planeIntersection.x, planeIntersection.y, planeIntersection.z, planeIntersection.w);
        
        CC3Vector boxDiagonal =  CC3VectorDifference(side[3], side[0]);
        
        
        BOOL intersectsBox = 
        (fabs(boxDiagonal.x) > 0 ? (planeIntersection.x >= MIN(side[0].x, side[3].x) && planeIntersection.x <= MAX(side[0].x, side[3].x)) : YES) &&
        (fabs(boxDiagonal.y) > 0 ? (planeIntersection.y >= MIN(side[0].y, side[3].y) && planeIntersection.y <= MAX(side[0].y, side[3].y)) : YES) &&
        (fabs(boxDiagonal.z) > 0 ? (planeIntersection.z >= MIN(side[0].z, side[3].z) && planeIntersection.z <= MAX(side[0].z, side[3].z)) : YES);
        
        if (intersectsBox) {
            if (CC3Vector4sAreEqual(closestHit, kCC3Vector4Zero)) {
                closestHit = planeIntersection;
            } else if (planeIntersection.w < closestHit.w) {
                closestHit = planeIntersection;
            }
        }
        
        
        //NSLog(@"intersectsBox: %d", intersectsBox);
    }
    
    free(sides);
    
    return CC3Vector4sAreEqual(closestHit, kCC3Vector4Zero) ? nil : [NSValue valueWithCC3Vector4:closestHit];
}

- (RENode*)childIntersectingRay:(CC3Ray)ray hitPoint:(CC3Vector4*)hitPoint {
    
    CC3Vector4 closestPoint = kCC3Vector4Zero;
    
    RENode *returnNode = nil; // return node
    
    for (int i = 0; i < [children count]; i++) {
        RENode *child = [children objectAtIndex:i];
        NSValue *intersectionValue = [child boundingBoxIntersectionForRay:ray];
        
        if (intersectionValue) {
            CC3Vector4 point = [intersectionValue CC3Vector4Value];
            
            if (CC3Vector4sAreEqual(closestPoint, kCC3Vector4Zero) || point.w < closestPoint.w) {
                closestPoint = point;
                returnNode = child;
            }
        }
    }
            
    if (hitPoint) {
        (*hitPoint) = closestPoint;                
    }
    
    return returnNode;
}

#pragma mark - Force updates

- (void)invalidateGlobalTransformMatrix {
    isGlobalTransformMatrixDirty = YES;
}


@end


@implementation RENodeGLState

@synthesize state = state_;
@synthesize parentState = parentState_;
@synthesize isParentStateDirty = isParentStateDirty_;

- (id)init {
    if ((self = [super init])) {
        isParentStateDirty_ = YES;
    } return self;
}

- (void)invalidateParentState {
    isParentStateDirty_ = YES;
}

- (void)setParentState:(id)parentState {
    [parentState_ release];
    parentState_ = [parentState retain];
    //if (parentState_) {
        isParentStateDirty_ = NO;
    //}
}

- (void)dealloc {
    [state_ release];
    [parentState_ release];
    [super dealloc];
}

@end
