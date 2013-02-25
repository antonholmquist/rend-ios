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

@class REGLView;

typedef enum {
    kRECameraProjectionOrthographic,
    kRECameraProjectionPerspective,
} kRECameraProjection;

/** RECamera is defines the OpenGL camera properties.
 */

@interface RECamera : RENode {
    kRECameraProjection projection;    
    
    float frustumLeft, frustumRight;
    float frustumBottom, frustumTop;
    float frustumNear, frustumFar;
    CC3Vector upDirection;
    CC3Vector lookDirection_;
    
    CC3GLMatrix *viewMatrix;
    CC3GLMatrix *projectionMatrix;

    
    BOOL isViewMatrixDirty;
    BOOL isProjectionMatrixDirty;
    
    BOOL areFrustumPlanesDirty_;
    CC3Plane frustumNearPlane_;
    CC3Plane frustumFarPlane_;
    CC3Plane frustumTopPlane_;
    CC3Plane frustumBottomPlane_;
    CC3Plane frustumLeftPlane_;
    CC3Plane frustumRightPlane_;
}

/** Look direction of the camera */
@property (nonatomic, assign) CC3Vector lookDirection;

/** Up direction of the camera */
@property (nonatomic, assign) CC3Vector upDirection;

/** View frustum values */
@property (nonatomic, assign) float frustumLeft, frustumRight, frustumBottom, frustumTop, frustumNear, frustumFar;

/** The view matrix transforms from world space to eye space. It is calculated from position, lookDirection and upDirection. */
@property (nonatomic, readonly) CC3GLMatrix *viewMatrix;

/** The projection matrix transforms eye space to normal space. It is calculacted from the frustom values. */
@property (nonatomic, retain) CC3GLMatrix *projectionMatrix; 

/** Designated initializer. Select between perspective and orthographic projection. */
- (id)initWithProjection:(kRECameraProjection)p;

- (void)setOrientationWithHorizontalAngle:(float)horizontalAngle verticalAngle:(float)verticalAngle sideTiltAngle:(float)sideTiltAngle;

// Returns the near field point
//- (CC3Vector)convert:(CGPoint)point fromView:(REGLView*)view;

//-(CC3Ray)tmp_unprojectPoint:(CGPoint)cc2Point size:(CGSize)size;

// Convert a 2d point in a view to a 3D ray
-(CC3Ray)unprojectPoint:(CGPoint)cc2Point inView:(REGLView*)view;

// If it's inside or intersects
- (BOOL)boundingBoxIntersectsFrustum:(CC3BoundingBox)boundingBox; // Only reliable for orthographic projections for now

/** Simple cull test for bounding boxes */
- (BOOL)globalBoundingBoxCanBeCulled:(CC3BoundingBox)globalBoundingBox;

@end

