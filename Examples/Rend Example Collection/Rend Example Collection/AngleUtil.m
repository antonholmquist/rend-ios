//
//  AngleUtil.h
//  Vodafone
//
//  Created by Anton Holmberg on 2011-06-17.
//  Copyright 2011 Anton Holmberg. All rights reserved.
//

#import "AngleUtil.h"

@implementation AngleUtil

+ (double)spinAngle:(double)angle within360DegreesFrom:(double)intervalLowerLimitAngle {
    double intervalUpperLimitAngle = intervalLowerLimitAngle + 360.0f;
    if(angle < intervalLowerLimitAngle) {
        double diff = ABS(angle - intervalLowerLimitAngle);
        int nSpins = ceil(diff/360.0f);
        angle += nSpins * 360.0f;
    } else if(angle > intervalUpperLimitAngle) {
        double diff = ABS(angle - intervalUpperLimitAngle);
        int nSpins = ceil(diff/360.0f);
        angle -= nSpins * 360.0f;
    }
    return angle;
}

@end