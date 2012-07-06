//
//  TeapotController.m
//  Rend Example Collection
//
//  Created by Anton Holmquist on 6/26/12.
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import "TeapotController.h"

@interface TeapotController ()

@end

@implementation TeapotController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    RELight *light = [REDirectionalLight light];
    [self.world addLight:light];
    
    
    REWavefrontMesh *teapotMesh = [REMeshCache meshNamed:@"teapot.obj"];
    
    teapotNode_ = [[[TeapotNode alloc] initWithDefaultMesh:teapotMesh] autorelease];
    teapotNode_.rotationAxis = CC3VectorMake(0.1, 1, 0.3);
    teapotNode_.material.ambient = CC3Vector4Make(0.3, 0.3, 0.3, 1.0);
    teapotNode_.material.diffuse = CC3Vector4Make(0.4, 0.2, 0.2, 1.0);
    teapotNode_.material.specular = CC3Vector4Make(0.5, 0.6, 0.5, 1.0);
    teapotNode_.material.shininess = 24;
    [teapotNode_ setSizeX:200];
    [self.world addChild:teapotNode_];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    teapotNode_ = nil;
}

- (void)update:(float)dt {
    static float angle = 0;
    
    angle += 0.4;
    teapotNode_.rotationAngle = angle;
    
    
    
    
}
                                       

@end
