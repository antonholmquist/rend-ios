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

#import "RECamera.h"
#import "REGLView.h"

@interface RECamera ()

// Recalculates frustum planes
- (void)updateFrustumPlanes;

@end

@implementation RECamera

@synthesize lookDirection = lookDirection_;
@synthesize upDirection;
@synthesize frustumLeft, frustumRight, frustumBottom, frustumTop, frustumNear, frustumFar;
@synthesize viewMatrix, projectionMatrix;

- (id)initWithProjection:(kRECameraProjection)p {
    if ((self = [super init])) {
        projection = p;
        
        viewMatrix = [[CC3GLMatrix alloc] init];
        projectionMatrix = [[CC3GLMatrix alloc] init];
        
        upDirection = CC3VectorMake(0, 1, 0);
        
        isViewMatrixDirty = YES;
        isProjectionMatrixDirty = YES;
        
    } return self;
}

- (void)dealloc {
    [viewMatrix release];
    [projectionMatrix release];
    [super dealloc];
}

#pragma mark - View Accessors

- (void)setPosition:(CC3Vector)p {
    [super setPosition:p];
    isViewMatrixDirty = YES;
    areFrustumPlanesDirty_ = YES;
}

- (void)setLookDirection:(CC3Vector)d {
    lookDirection_ = d;
    isViewMatrixDirty = YES;
    areFrustumPlanesDirty_ = YES;
}

- (void)setUpDirection:(CC3Vector)u {
    upDirection = u;
    isViewMatrixDirty = YES;
    areFrustumPlanesDirty_ = YES;
}


- (void)setOrientationWithHorizontalAngle:(float)horizontalAngle verticalAngle:(float)verticalAngle sideTiltAngle:(float)sideTiltAngle {
    CC3Vector direction = CC3VectorMake(sin(M_PI/2-verticalAngle) * cos(horizontalAngle - M_PI/2 + M_PI),
                                        cos(M_PI/2-verticalAngle),
                                        sin(M_PI/2-verticalAngle) * sin(horizontalAngle - M_PI/2 + M_PI));
    CC3Vector yVector = CC3VectorMake(0, 1, 0);
    CC3Vector leftVector =  CC3VectorCross(direction, yVector);
    CC3Vector rawUpVector = CC3VectorCross(leftVector, direction);
    
    self.upDirection = CC3VectorRotateVectorAroundAxisVector(rawUpVector, direction, sideTiltAngle);
    
    
    self.lookDirection = direction;
    isViewMatrixDirty = YES;
    
   // NSLog(@"self.lookDirection: %f, %f, %f", self.lookDirection.x, self.lookDirection.y, self.lookDirection.z);
    //NSLog(@"self.upDirection: %f, %f, %f", self.upDirection.x, self.upDirection.y, self.upDirection.z);
}



#pragma mark - Projection Accessors

- (void)setFrustumLeft:(float)a {
    frustumLeft = a;
    isProjectionMatrixDirty = YES;
    areFrustumPlanesDirty_ = YES;
}

- (void)setFrustumRight:(float)a {
    frustumRight = a;
    isProjectionMatrixDirty = YES;
    areFrustumPlanesDirty_ = YES;
}

- (void)setFrustumBottom:(float)a {
    frustumBottom = a;
    isProjectionMatrixDirty = YES;
    areFrustumPlanesDirty_ = YES;
}

- (void)setFrustumTop:(float)a {
    frustumTop = a;
    isProjectionMatrixDirty = YES;
    areFrustumPlanesDirty_ = YES;
}

- (void)setFrustumNear:(float)a {
    frustumNear = a;
    isProjectionMatrixDirty = YES;
    areFrustumPlanesDirty_ = YES;
}

- (void)setFrustumFar:(float)a {
    frustumFar = a;
    isProjectionMatrixDirty = YES;
    areFrustumPlanesDirty_ = YES;
}

#pragma mark - Matrixes

- (CC3GLMatrix*)viewMatrix {
    if (isViewMatrixDirty) {
        isViewMatrixDirty = NO;
        [viewMatrix populateToLookAt:CC3VectorAdd(self.position, lookDirection_) withEyeAt:self.position withUp:upDirection];
    } return viewMatrix;
}

- (CC3GLMatrix*)projectionMatrix {
    if (isProjectionMatrixDirty) {
        if (projection == kRECameraProjectionOrthographic) {
            [projectionMatrix populateOrthoFromFrustumLeft:frustumLeft andRight:frustumRight andBottom:frustumBottom andTop:frustumTop andNear:frustumNear andFar:frustumFar];
        } else if (projection == kRECameraProjectionPerspective) {
            [projectionMatrix populateFromFrustumLeft:frustumLeft andRight:frustumRight andBottom:frustumBottom andTop:frustumTop andNear:frustumNear andFar:frustumFar];
        } isProjectionMatrixDirty = NO;
    } return projectionMatrix;
}

- (void)setProjectionMatrix:(CC3GLMatrix *)matrix {
    [projectionMatrix release];
    projectionMatrix = [matrix retain];
    isProjectionMatrixDirty = NO;
}

#pragma mark - Conversions

/*
- (CC3Vector)convert:(CGPoint)point fromView:(REGLView*)view {
    
    CC3Vector worldCoordinate = CC3VectorMake(self.position.x + (point.x - view.frame.size.width / 2.0) / view.frame.size.width  * (frustumRight - frustumLeft),
                                              self.position.y - (point.y - view.frame.size.height / 2.0) / view.frame.size.height * (frustumTop - frustumBottom),
                                              self.position.z + frustumNear);
    
    NSLog(@"world: %f, %f, %f", worldCoordinate.x, worldCoordinate.y, worldCoordinate.z);
    
    
    return [self.viewMatrix transformLocation:worldCoordinate];
}
 */

/*
-(CC3Ray)tmp_unprojectPoint:(CGPoint)cc2Point size:(CGSize)size {
    // CC_CONTENT_SCALE_FACTOR = 2.0 if Retina display active, or 1.0 otherwise.
	//CGPoint glPoint = ccpMult(cc2Point, CC_CONTENT_SCALE_FACTOR());
    
    CGPoint glPoint = cc2Point;
	
	// Express the glPoint X & Y as proportion of the layer dimensions, based
	// on an origin in the center of the layer (the center of the camera's view).
	CGSize lb = size;
	GLfloat xp = ((2.0 * glPoint.x) / lb.width) - 1;
	//GLfloat yp = ((2.0 * glPoint.y) / lb.height) - 1;
    GLfloat yp = -1 * (((2.0 * glPoint.y) / lb.height) - 1);
	
	// Now that we have the location of the glPoint proportional to the layer dimensions,
	// we need to map the layer dimensions onto the frustum near clipping plane.
	// The layer dimensions change as device orientation changes, but the viewport
	// dimensions remain the same. The field of view is always measured relative to the
	// viewport height, independent of device orientation. We can find the top-right
	// corner of the view on the near clipping plane (top-right is positive X & Y from
	// the center of the camera's view) by multiplying by an orientation aspect in each
	// direction. This orientation aspect depends on the device orientation, which can
	// be expressed in terms of the relationship between the layer width and height and
	// the constant viewport height. The Z-coordinate at the near clipping plane is
	// negative since the camera points down the negative Z axis in its local coordinates.
	CGFloat vph = size.height;
	GLfloat xNearTopRight = frustumTop * (lb.width / vph);
	GLfloat yNearTopRight = frustumTop * (lb.height / vph);
	GLfloat zNearTopRight = -frustumNear;
	
	LogTrace(@"%@ view point %@ mapped to proportion (%.3f, %.3f) of view bounds %@ and viewport %@",
			 [self class], NSStringFromCGPoint(glPoint), xp, yp,
			 NSStringFromCGSize(lb), NSStringFromCC3Viewport(self.viewportManager.viewport));
	
	// We now have the location of the the top-right corner of the view, at the near
	// clipping plane, taking into account device orientation. We can now map the glPoint
	// onto the near clipping plane by multiplying by the glPoint's proportional X & Y
	// location, relative to the top-right corner of the view, which was calculated above.
	CC3Vector pointLocNear = cc3v(xNearTopRight * xp,
								  yNearTopRight * yp,
								  zNearTopRight);
    
    //NSLog(@"pointLocNear: %f, %f, %f", pointLocNear.x, pointLocNear.y, pointLocNear.z);
    
	CC3Ray ray;
    
	if (projection == kRECameraProjectionOrthographic) {
		// The location on the near clipping plane is relative to the camera's
		// local coordinates. Convert it to global coordinates before returning.
		// The ray direction is straight out from that global location in the 
		// camera's globalForwardDirection.
		//ray.startLocation =  [self.transformMatrix transformLocation:pointLocNear];
		//ray.direction = self.globalForwardDirection;
        
        NSAssert(NO, @"Not implemented, kRECameraProjectionOrthographic");
	} else {
		// The location on the near clipping plane is relative to the camera's local
		// coordinates. Since the camera's origin is zero in its local coordinates,
		// this point on the near clipping plane forms a directional vector from the
		// camera's origin. Rotate this directional vector with the camera's rotation
		// matrix to convert it to a global direction vector in global coordinates.
		// Thanks to cocos3d forum user Rogs for suggesting the use of the globalRotationMatrix.
        
        CC3Vector globalLocation = [self.globalTransformMatrix transformLocation:kCC3VectorZero];
        
        
        CC3GLMatrix *rotationMatrix = [CC3GLMatrix matrix];
        [rotationMatrix populateFromRotation:CC3VectorNegate([self.viewMatrix extractRotation])];
        
		ray.startLocation = globalLocation;
        ray.direction = [rotationMatrix transformDirection:pointLocNear];
        
        
		//ray.direction = [self.globalRotationMatrix transformDirection: pointLocNear];
        
	}
    
	
	// Ensure the direction component is normalized before returning.
	ray.direction = CC3VectorNormalize(ray.direction);
    
	return ray;

}
 */

-(CC3Ray)unprojectPoint:(CGPoint)cc2Point inView:(REGLView*)view {
    
	// CC_CONTENT_SCALE_FACTOR = 2.0 if Retina display active, or 1.0 otherwise.
	//CGPoint glPoint = ccpMult(cc2Point, CC_CONTENT_SCALE_FACTOR());
    
    CGPoint glPoint = cc2Point;
	
	// Express the glPoint X & Y as proportion of the layer dimensions, based
	// on an origin in the center of the layer (the center of the camera's view).
	CGSize lb = view.frame.size;
	GLfloat xp = ((2.0 * glPoint.x) / lb.width) - 1;
	//GLfloat yp = ((2.0 * glPoint.y) / lb.height) - 1;
    GLfloat yp = -1 * (((2.0 * glPoint.y) / lb.height) - 1);
	
	// Now that we have the location of the glPoint proportional to the layer dimensions,
	// we need to map the layer dimensions onto the frustum near clipping plane.
	// The layer dimensions change as device orientation changes, but the viewport
	// dimensions remain the same. The field of view is always measured relative to the
	// viewport height, independent of device orientation. We can find the top-right
	// corner of the view on the near clipping plane (top-right is positive X & Y from
	// the center of the camera's view) by multiplying by an orientation aspect in each
	// direction. This orientation aspect depends on the device orientation, which can
	// be expressed in terms of the relationship between the layer width and height and
	// the constant viewport height. The Z-coordinate at the near clipping plane is
	// negative since the camera points down the negative Z axis in its local coordinates.
	CGFloat vph = view.frame.size.height;
	GLfloat xNearTopRight = frustumTop * (lb.width / vph);
	GLfloat yNearTopRight = frustumTop * (lb.height / vph);
	GLfloat zNearTopRight = -frustumNear;
	
	LogTrace(@"%@ view point %@ mapped to proportion (%.3f, %.3f) of view bounds %@ and viewport %@",
			 [self class], NSStringFromCGPoint(glPoint), xp, yp,
			 NSStringFromCGSize(lb), NSStringFromCC3Viewport(self.viewportManager.viewport));
	
	// We now have the location of the the top-right corner of the view, at the near
	// clipping plane, taking into account device orientation. We can now map the glPoint
	// onto the near clipping plane by multiplying by the glPoint's proportional X & Y
	// location, relative to the top-right corner of the view, which was calculated above.
	CC3Vector pointLocNear = cc3v(xNearTopRight * xp,
								  yNearTopRight * yp,
								  zNearTopRight);
    
    //NSLog(@"pointLocNear: %f, %f, %f", pointLocNear.x, pointLocNear.y, pointLocNear.z);

	CC3Ray ray;
    
	if (projection == kRECameraProjectionOrthographic) {
		// The location on the near clipping plane is relative to the camera's
		// local coordinates. Convert it to global coordinates before returning.
		// The ray direction is straight out from that global location in the
		// camera's globalForwardDirection.
		ray.startLocation =  [self.transformMatrix transformLocation:pointLocNear];
		//ray.direction = self.globalForwardDirection;
        
        //NSAssert(NO, @"Not implemented, kRECameraProjectionOrthographic");
	} else {
		// The location on the near clipping plane is relative to the camera's local
		// coordinates. Since the camera's origin is zero in its local coordinates,
		// this point on the near clipping plane forms a directional vector from the
		// camera's origin. Rotate this directional vector with the camera's rotation
		// matrix to convert it to a global direction vector in global coordinates.
		// Thanks to cocos3d forum user Rogs for suggesting the use of the globalRotationMatrix.
        
        CC3Vector globalLocation = [self.globalTransformMatrix transformLocation:kCC3VectorZero];
        

        CC3GLMatrix *rotationMatrix = [CC3GLMatrix matrix];
        [rotationMatrix populateFromRotation:CC3VectorNegate([self.viewMatrix extractRotation])];
        
		ray.startLocation = globalLocation;
        ray.direction = [rotationMatrix transformDirection:pointLocNear];
        
        
		//ray.direction = [self.globalRotationMatrix transformDirection: pointLocNear];
        
	}
     
	
	// Ensure the direction component is normalized before returning.
	ray.direction = CC3VectorNormalize(ray.direction);
    
	return ray;
}


/*
-(CC3Ray) unprojectPoint: (CGPoint) cc2Point {
    
	// CC_CONTENT_SCALE_FACTOR = 2.0 if Retina display active, or 1.0 otherwise.
	CGPoint glPoint = ccpMult(cc2Point, CC_CONTENT_SCALE_FACTOR());
	
	// Express the glPoint X & Y as proportion of the layer dimensions, based
	// on an origin in the center of the layer (the center of the camera's view).
	CGSize lb = self.viewportManager.layerBounds.size;
	GLfloat xp = ((2.0 * glPoint.x) / lb.width) - 1;
	GLfloat yp = ((2.0 * glPoint.y) / lb.height) - 1;
	
	// Now that we have the location of the glPoint proportional to the layer dimensions,
	// we need to map the layer dimensions onto the frustum near clipping plane.
	// The layer dimensions change as device orientation changes, but the viewport
	// dimensions remain the same. The field of view is always measured relative to the
	// viewport height, independent of device orientation. We can find the top-right
	// corner of the view on the near clipping plane (top-right is positive X & Y from
	// the center of the camera's view) by multiplying by an orientation aspect in each
	// direction. This orientation aspect depends on the device orientation, which can
	// be expressed in terms of the relationship between the layer width and height and
	// the constant viewport height. The Z-coordinate at the near clipping plane is
	// negative since the camera points down the negative Z axis in its local coordinates.
	CGFloat vph = self.viewportManager.viewport.h;
	GLfloat xNearTopRight = frustum.top * (lb.width / vph);
	GLfloat yNearTopRight = frustum.top * (lb.height / vph);
	GLfloat zNearTopRight = -frustum.near;
	
	LogTrace(@"%@ view point %@ mapped to proportion (%.3f, %.3f) of view bounds %@ and viewport %@",
			 [self class], NSStringFromCGPoint(glPoint), xp, yp,
			 NSStringFromCGSize(lb), NSStringFromCC3Viewport(self.viewportManager.viewport));
	
	// We now have the location of the the top-right corner of the view, at the near
	// clipping plane, taking into account device orientation. We can now map the glPoint
	// onto the near clipping plane by multiplying by the glPoint's proportional X & Y
	// location, relative to the top-right corner of the view, which was calculated above.
	CC3Vector pointLocNear = cc3v(xNearTopRight * xp,
								  yNearTopRight * yp,
								  zNearTopRight);
	CC3Ray ray;
	if (self.isUsingParallelProjection) {
		// The location on the near clipping plane is relative to the camera's
		// local coordinates. Convert it to global coordinates before returning.
		// The ray direction is straight out from that global location in the 
		// camera's globalForwardDirection.
		ray.startLocation =  [transformMatrix transformLocation: pointLocNear];
		ray.direction = self.globalForwardDirection;
	} else {
		// The location on the near clipping plane is relative to the camera's local
		// coordinates. Since the camera's origin is zero in its local coordinates,
		// this point on the near clipping plane forms a directional vector from the
		// camera's origin. Rotate this directional vector with the camera's rotation
		// matrix to convert it to a global direction vector in global coordinates.
		// Thanks to cocos3d forum user Rogs for suggesting the use of the globalRotationMatrix.
		ray.startLocation = self.globalLocation;
		ray.direction = [self.globalRotationMatrix transformDirection: pointLocNear];
	}
	
	// Ensure the direction component is normalized before returning.
	ray.direction = CC3VectorNormalize(ray.direction);
	
	LogTrace(@"%@ unprojecting point %@ to near plane location %@ and to ray starting at %@ and pointing towards %@",
             [self class], NSStringFromCGPoint(glPoint), NSStringFromCC3Vector(pointLocNear),
             NSStringFromCC3Vector(ray.startLocation), NSStringFromCC3Vector(ray.direction));
    
	return ray;
}
 */


#pragma mark - Intersections

/* This methods updates frustumNearPlane_, etc.. All planes will have a normal pointing in towards the center of the frustum (rather than outwards).
 
 */
- (void)updateFrustumPlanes {
    areFrustumPlanesDirty_ = NO;
    
    // http://www.lighthouse3d.com/tutorials/view-frustum-culling/geometric-approach-implementation/
    
    // compute the Z axis of camera
	// this axis points in the opposite direction from
	// the looking direction
    CC3Vector Z = CC3VectorNormalize(CC3VectorNegate(lookDirection_));
    
    // X axis of camera with given "up" vector and Z axis
	CC3Vector X = CC3VectorNormalize(CC3VectorCross(upDirection, Z));
    
    // the real "up" vector is the cross product of Z and X (Anton: Why just not use upDirection?)
    CC3Vector Y = CC3VectorCross(Z, X);
    
    // Near height, near width
    float nh = frustumTop - frustumBottom;
    //float nw = frustumRight - frustumLeft;
    
    // compute the centers of the near and far planes
    CC3Vector nc = CC3VectorDifference(self.position, CC3VectorScaleUniform(Z, frustumNear));
    CC3Vector fc = CC3VectorDifference(self.position, CC3VectorScaleUniform(Z, frustumFar));
    
    // The following (more efficient) alternative may be used to replace the computation of the eight corners and the six planes in the function above.
    CC3Vector aux, normal;
        
    // NEAR PLANE
    frustumNearPlane_ = CC3PlaneFromPointAndNormal(nc, CC3VectorNegate(Z));
    // FAR PLANE
    frustumFarPlane_ = CC3PlaneFromPointAndNormal(fc, Z);
    
    // TOP PLANE
    aux = CC3VectorNormalize(CC3VectorDifference(CC3VectorAdd(nc, CC3VectorScaleUniform(Y, nh)), self.position));
    normal = CC3VectorCross(aux, X);
    frustumTopPlane_ = CC3PlaneFromPointAndNormal(CC3VectorAdd(nc, CC3VectorScaleUniform(Y, nh)), normal);
    
    // BOTTOM PLANE
    aux = CC3VectorNormalize(CC3VectorDifference(CC3VectorDifference(nc, CC3VectorScaleUniform(Y, nh)), self.position));
    normal = CC3VectorCross(X, aux);
    frustumBottomPlane_ = CC3PlaneFromPointAndNormal(CC3VectorDifference(nc, CC3VectorScaleUniform(Y, nh)), normal);
    
    /*
     aux = (nc - Y*nh) - p;
     aux.normalize();
     normal = X * aux;
     pl[BOTTOM].setNormalAndPoint(normal,nc-Y*nh);
     */
    
    // LEFT PLANE
    aux = CC3VectorNormalize(CC3VectorDifference(CC3VectorDifference(nc, CC3VectorScaleUniform(X, nh)), self.position));
    normal = CC3VectorCross(aux, Y);
    frustumLeftPlane_ = CC3PlaneFromPointAndNormal(CC3VectorDifference(nc, CC3VectorScaleUniform(X, nh)), normal);
    
    // RIGHT PLANE
    aux = CC3VectorNormalize(CC3VectorDifference(CC3VectorAdd(nc, CC3VectorScaleUniform(X, nh)), self.position));
    normal = CC3VectorCross(Y, aux);
    frustumRightPlane_ = CC3PlaneFromPointAndNormal(CC3VectorAdd(nc, CC3VectorScaleUniform(X, nh)), normal);
    
    // NORMALIZE ALL PLANES
    frustumNearPlane_ = CC3PlaneNormalize(frustumNearPlane_);
    frustumFarPlane_ = CC3PlaneNormalize(frustumFarPlane_);
    frustumTopPlane_ = CC3PlaneNormalize(frustumTopPlane_);
    frustumBottomPlane_ = CC3PlaneNormalize(frustumBottomPlane_);
    frustumLeftPlane_ = CC3PlaneNormalize(frustumLeftPlane_);
    frustumRightPlane_ = CC3PlaneNormalize(frustumRightPlane_);
    
    
    /*
     aux = (nc + Y*nh) - p;
     aux.normalize();
     normal = aux * X;
     pl[TOP].setNormalAndPoint(normal,nc+Y*nh);
     */
    
    
    
    // compute the 4 corners of the frustum on the near plane

/*    
	ntl = nc + Y * nh - X * nw;
	ntr = nc + Y * nh + X * nw;
	nbl = nc - Y * nh - X * nw;
	nbr = nc - Y * nh + X * nw;
 */


}

- (BOOL)boundingBoxIntersectsFrustum:(CC3BoundingBox)boundingBox {
    return YES;
}

- (BOOL)globalBoundingBoxCanBeCulled:(CC3BoundingBox)globalBoundingBox {

    if (projection == kRECameraProjectionPerspective) {
        
        //NSLog(@"globalBoundingBoxCanBeCulled");
        //NSLog(@"globalBoundingBox.min: %f, %f, %f", globalBoundingBox.minimum.x, globalBoundingBox.minimum.y, globalBoundingBox.minimum.z);
        //NSLog(@"globalBoundingBox.max: %f, %f, %f", globalBoundingBox.maximum.x, globalBoundingBox.maximum.y, globalBoundingBox.maximum.z);
        
        if (areFrustumPlanesDirty_) {
            [self updateFrustumPlanes];
        }
        
        CC3Plane *planes = calloc(6, sizeof(CC3Plane));
        /*
        planes[0] = frustumNearPlane_;
        planes[1] = frustumFarPlane_;
        planes[2] = frustumTopPlane_;
        planes[3] = frustumBottomPlane_;
        planes[4] = frustumLeftPlane_;
        planes[5] = frustumRightPlane_;
         */
        
        planes[0] = frustumLeftPlane_;
        planes[1] = frustumRightPlane_;
        planes[2] = frustumTopPlane_;
        planes[3] = frustumBottomPlane_;
        planes[4] = frustumNearPlane_;
        planes[5] = frustumFarPlane_;
        
        
        BOOL canCull = NO;
        
        // All 8 points of local box
        CC3Vector globalBoundingBoxPoint0 = CC3VectorMake(globalBoundingBox.minimum.x, globalBoundingBox.minimum.y, globalBoundingBox.minimum.z);
        CC3Vector globalBoundingBoxPoint1 = CC3VectorMake(globalBoundingBox.minimum.x, globalBoundingBox.minimum.y, globalBoundingBox.maximum.z);
        CC3Vector globalBoundingBoxPoint2 = CC3VectorMake(globalBoundingBox.minimum.x, globalBoundingBox.maximum.y, globalBoundingBox.minimum.z);
        CC3Vector globalBoundingBoxPoint3 = CC3VectorMake(globalBoundingBox.minimum.x, globalBoundingBox.maximum.y, globalBoundingBox.maximum.z);
        CC3Vector globalBoundingBoxPoint4 = CC3VectorMake(globalBoundingBox.maximum.x, globalBoundingBox.minimum.y, globalBoundingBox.minimum.z);
        CC3Vector globalBoundingBoxPoint5 = CC3VectorMake(globalBoundingBox.maximum.x, globalBoundingBox.minimum.y, globalBoundingBox.maximum.z);
        CC3Vector globalBoundingBoxPoint6 = CC3VectorMake(globalBoundingBox.maximum.x, globalBoundingBox.maximum.y, globalBoundingBox.minimum.z);
        CC3Vector globalBoundingBoxPoint7 = CC3VectorMake(globalBoundingBox.maximum.x, globalBoundingBox.maximum.y, globalBoundingBox.maximum.z);
        
        CC3Vector globalBoundingBoxPoints[8] = {globalBoundingBoxPoint0, globalBoundingBoxPoint1, globalBoundingBoxPoint2, globalBoundingBoxPoint3, globalBoundingBoxPoint4, globalBoundingBoxPoint5, globalBoundingBoxPoint6, globalBoundingBoxPoint7};
        
//        NSLog(@"globalBoundingBoxPoint0: %f, %f, %f", globalBoundingBoxPoint0.x, globalBoundingBoxPoint0.y, globalBoundingBoxPoint0)
        
        // for each plane do ...
        for (int i = 0; i < 6; i++) {
            CC3Plane plane = planes[i];
            
            // reset counters for corners in and out
            int inCount = 0;
            int outCount = 0;
            
            // for each corner of the box do ...
            // get out of the cycle as soon as a box as corners
            // both inside and out of the frustum
            for (int k = 0; k < 8 && (inCount == 0 || outCount == 0); k++) {
                
                //NSLog(@"[i: %d, k: %d]", i, k);
                
                CC3Vector point = globalBoundingBoxPoints[k];
                
                //NSLog(@"point: %f, %f, %f", point.x, point.y, point.z);
                
                float signedDistance = CC3DistanceFromNormalizedPlane(plane, point);
                
                //NSLog(@"plane: %f, %f, %f, %f", plane.a, plane.b, plane.c, plane.d);
                //NSLog(@"signedDistance: %f", signedDistance);
                
                
                // is the corner outside or inside
                
                /*
                if (pl[i].distance(b.getVertex(k)) < 0)
                    outCount++;
                else
                    inCount++;
                 */
                
                BOOL outside = signedDistance < 0;
                outside ? outCount++ : inCount++;
                
                //NSLog(@"outside: %d", outside);
            }
            
            //NSLog(@"inCount: %d, outCount: %d", inCount, outCount);
            
            //if all corners are out (then all corners are outside the same plane.) then we're sure we can cull
            if (inCount == 0) { 
                canCull = YES;
                break;
            }
            // if some corners are out and others are in, we can't do anything for now
            //else if (out)
              //  result = INTERSECT;
        }
        
        free(planes);
        
        return canCull;
    }
    
    return NO;
}

/*
// Only reliable for orthographic projections for no
- (BOOL)boundingBoxIntersectsFrustum:(CC3BoundingBox)boundingBox {
    NSAssert(YES, @"RECamera: boundingBoxIntersectsFrustum: Not implemented");
    return YES;
    

    
    BOOL intersects = YES;
    if (projection == kRECameraProjectionOrthographic) {
        CC3BoundingBox globalFrustum = CC3BoundingBoxFromMinMax([self.viewMatrix transformLocation:CC3VectorMake(frustumLeft, frustumBottom, -frustumNear)], [self.viewMatrix transformLocation:CC3VectorMake(frustumRight, frustumBottom, -frustumNear)]);
        if (boundingBox.minimum.x >= fru
    } else {
        intersects = YES; // Should fix this later.
    }
    return intersects;

}
 */

@end
