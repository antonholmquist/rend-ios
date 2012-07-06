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

#import "RERotator.h"
#import "CC3GLMatrix.h"

@interface RERotator ()

- (void)applyRotation;

- (void)ensureRotationFromMatrix;
- (void)ensureQuaternionFromMatrix;
- (void)ensureQuaternionFromAxisAngle;
- (void)ensureAxisAngleFromQuaternion;

@end

@implementation RERotator

- (id)init {
	return [self initOnRotationMatrix: [CC3GLMatrix identity]];
}


- (id)initOnRotationMatrix:(CC3GLMatrix*) aGLMatrix {
	if ((self = [super init])) {
		self.rotationMatrix = aGLMatrix;
		rotation = kCC3VectorZero;
		quaternion = kCC3Vector4QuaternionIdentity;
		rotationAxis = kCC3VectorZero;
		rotationAngle = 0.0;
		isRotationDirty = NO;
		isQuaternionDirty = NO;
		isAxisAngleDirty = NO;
		isQuaternionDirtyByAxisAngle = NO;
		matrixIsDirtyBy = kCC3MatrixIsNotDirty;
	}
	return self;
}

- (void)dealloc {
    [rotationMatrix release];
    [super dealloc];
}

- (CC3Vector)rotation {
	[self ensureRotationFromMatrix];
	return rotation;
}

- (void)setRotation:(CC3Vector)r {
	rotation = CC3VectorRotationModulo(r);
    
	isRotationDirty = NO;
	isAxisAngleDirty = YES;
	isQuaternionDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;
    
	matrixIsDirtyBy = kCC3MatrixIsDirtyByRotation;
}

- (CC3Vector4)quaternion {
	[self ensureQuaternionFromAxisAngle];
	[self ensureQuaternionFromMatrix];
	return quaternion;
}

- (void)setQuaternion:(CC3Vector4)q {
	quaternion = q;
    
	isRotationDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirty = NO;
	isQuaternionDirtyByAxisAngle = NO;
    
	matrixIsDirtyBy = kCC3MatrixIsDirtyByQuaternion;
}

- (CC3Vector)rotationAxis {
	[self ensureAxisAngleFromQuaternion];
	return rotationAxis;
}

- (void)setRotationAxis:(CC3Vector)axis {
	rotationAxis = axis;
	
	isRotationDirty = YES;
	isAxisAngleDirty = NO;
	isQuaternionDirty = NO;
	isQuaternionDirtyByAxisAngle = YES;
	
	matrixIsDirtyBy = kCC3MatrixIsDirtyByAxisAngle;
}

- (GLfloat)rotationAngle {
	[self ensureAxisAngleFromQuaternion];
	return rotationAngle;
}

- (void)setRotationAngle:(GLfloat)angle {
	rotationAngle = Cyclic(angle, kCircleDegreesPeriod);
	
	isRotationDirty = YES;
	isAxisAngleDirty = NO;
	isQuaternionDirty = NO;
	isQuaternionDirtyByAxisAngle = YES;
	
	matrixIsDirtyBy = kCC3MatrixIsDirtyByAxisAngle;
}


#pragma mark - Rotation Matrix

- (CC3GLMatrix*)rotationMatrix {
	[self applyRotation];
	return rotationMatrix;
}

- (void)setRotationMatrix:(CC3GLMatrix*)aGLMatrix {
	id oldMtx = rotationMatrix;
	rotationMatrix = [aGLMatrix retain];
	[oldMtx release];
	
	isRotationDirty = YES;
	isQuaternionDirty = YES;
	isAxisAngleDirty = YES;
	isQuaternionDirtyByAxisAngle = NO;
    
	matrixIsDirtyBy = kCC3MatrixIsNotDirty;
}

#pragma mark - Apple

- (void)applyRotation {
    switch (matrixIsDirtyBy) {
		case kCC3MatrixIsDirtyByRotation:
			[rotationMatrix populateFromRotation:self.rotation];
			matrixIsDirtyBy = kCC3MatrixIsNotDirty;
			break;
		case kCC3MatrixIsDirtyByQuaternion:
		case kCC3MatrixIsDirtyByAxisAngle:
			[rotationMatrix populateFromQuaternion:self.quaternion];
			matrixIsDirtyBy = kCC3MatrixIsNotDirty;
			break;
		default:
			break;
	}
}

#pragma mark - Ensure

- (void)ensureRotationFromMatrix {
	if (isRotationDirty) {
		rotation = [self.rotationMatrix extractRotation];
		isRotationDirty = NO;
	}
}

/** If needed, extracts and sets the quaternion from the encapsulated rotation matrix. */
- (void)ensureQuaternionFromMatrix {
	if (isQuaternionDirty) {
		quaternion = [self.rotationMatrix extractQuaternion];
		isQuaternionDirty = NO;
	}
}

/** If needed, extracts and sets the quaternion from the encapsulated rotation axis and angle. */
- (void)ensureQuaternionFromAxisAngle {
	// If q is a quaternion, (rx, ry, rz) is the rotation axis, and ra is
	// the rotation angle (negated for right-handed coordinate system), then:
	// q = ( sin(ra/2)*rx, sin(ra/2)*ry, sin(ra/2)*rz, cos(ra/2) )
    
	if (isQuaternionDirtyByAxisAngle) {
		GLfloat halfAngle = -DegreesToRadians(rotationAngle) / 2.0;		// negate for RH system
		CC3Vector axis = CC3VectorScaleUniform(CC3VectorNormalize(rotationAxis), sinf(halfAngle));
		quaternion = CC3Vector4FromCC3Vector(axis, cosf(halfAngle));
		isQuaternionDirtyByAxisAngle = NO;
	}
}

/**
 * If needed, extracts and returns a rotation axis and angle from the encapsulated quaternion.
 * If the rotation angle is zero, the axis is undefined, and will be set to the zero vector.
 */
- (void)ensureAxisAngleFromQuaternion {
	// If q is a quaternion, (rx, ry, rz) is the rotation axis, and ra is
	// the rotation angle (negated for right-handed coordinate system), then:
	// q = ( sin(ra/2)*rx, sin(ra/2)*ry, sin(ra/2)*rz, cos(ra/2) )
	// ra = acos(q.w) * 2
	// (rx, ry, rz) = (q.x, q.y, q.z) / sin(ra/2)
    
	if (isAxisAngleDirty) {
		CC3Vector4 q = CC3Vector4Normalize(self.quaternion);
		GLfloat halfAngle = acosf(q.w);
		rotationAngle = -RadiansToDegrees(halfAngle) * 2.0;		// negate for RH system
        
		// If angle is zero, rotation axis is undefined. Use zero vector.
		if (halfAngle != 0.0f) {
			rotationAxis = CC3VectorScaleUniform(CC3VectorFromTruncatedCC3Vector4(q),
												 (1.0 / sinf(halfAngle)));
		} else {
			rotationAxis = kCC3VectorZero;
		}
		isAxisAngleDirty = NO;
	}
}




@end
