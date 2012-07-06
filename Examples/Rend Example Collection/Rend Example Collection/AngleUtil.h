//
//  AngleUtil.h
//  Vodafone
//
//  Created by Anton Holmberg on 2011-06-17.
//  Copyright 2011 Anton Holmberg. All rights reserved.
//

@interface AngleUtil : NSObject

+ (double)spinAngle:(double)angle within360DegreesFrom:(double)intervalLowerLimitAngle;

@end