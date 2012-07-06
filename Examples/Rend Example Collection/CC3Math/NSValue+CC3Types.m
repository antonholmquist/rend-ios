//
//  NSValue+CC3Types.m
//  Transformers
//
//  Created by Anton Holmquist on 9/30/11.
//  Copyright 2011 Monterosa. All rights reserved.
//

#import "NSValue+CC3Types.h"

@implementation NSValue (CC3Types)

+ (NSValue*)valueWithCC3Vector:(CC3Vector)v {
    return [NSValue valueWithBytes:&v objCType:@encode(CC3Vector)];
}

- (CC3Vector)CC3VectorValue {
    CC3Vector v;
    [self getValue:&v];
    return v;
}

+ (NSValue*)valueWithCC3Vector4:(CC3Vector4)v {
    return [NSValue valueWithBytes:&v objCType:@encode(CC3Vector4)];
}

- (CC3Vector4)CC3Vector4Value {
    CC3Vector4 v;
    [self getValue:&v];
    return v;
}

@end


