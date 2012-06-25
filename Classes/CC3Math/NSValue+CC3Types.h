//
//  NSValue+CC3Types.h
//  Transformers
//
//  Created by Anton Holmquist on 9/30/11.
//  Copyright 2011 Monterosa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CC3Foundation.h"

@interface NSValue (CC3Types)

+ (NSValue*)valueWithCC3Vector:(CC3Vector)v;
- (CC3Vector)CC3VectorValue;

+ (NSValue*)valueWithCC3Vector4:(CC3Vector4)v;
- (CC3Vector4)CC3Vector4Value;

@end
