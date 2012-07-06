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

#import <Foundation/Foundation.h>
#import "CC3Foundation.h"

@class CC3GLMatrix;

#define kCC3MatrixIsNotDirty				0
#define kCC3MatrixIsDirtyByRotation			1
#define kCC3MatrixIsDirtyByQuaternion		2
#define kCC3MatrixIsDirtyByAxisAngle		3


@interface RERotator : NSObject {
    
    CC3GLMatrix* rotationMatrix;
    
    CC3Vector rotation;
	CC3Vector4 quaternion;
	CC3Vector rotationAxis;
	GLfloat rotationAngle;
    
    int matrixIsDirtyBy;
	BOOL isRotationDirty;
	BOOL isQuaternionDirty;
	BOOL isAxisAngleDirty;
	BOOL isQuaternionDirtyByAxisAngle;
}

- (id)init;
- (id)initOnRotationMatrix:(CC3GLMatrix*)m;


@property(nonatomic, retain) CC3GLMatrix* rotationMatrix;
@property(nonatomic, assign) CC3Vector rotation;
@property(nonatomic, assign) CC3Vector4 quaternion;
@property(nonatomic, assign) CC3Vector rotationAxis;
@property(nonatomic, assign) GLfloat rotationAngle;

@end
