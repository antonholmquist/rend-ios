//
//  TeapotNode.m
//  Rend Example Collection
//
//  Created by Anton Holmquist on 6/26/12.
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import "TeapotNode.h"

@implementation TeapotNode

+ (REProgram*)program {
    return [REProgram programWithVertexFilename:@"sVertexLighting.vsh" fragmentFilename:@"sVertexLighting.fsh"];
    
}

@end
