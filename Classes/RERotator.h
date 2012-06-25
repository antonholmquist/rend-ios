

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
