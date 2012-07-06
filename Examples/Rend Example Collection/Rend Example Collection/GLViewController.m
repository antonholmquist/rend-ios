//
//  GLViewController.m
//  Rend Example Collection
//
//  Created by Anton Holmquist on 6/26/12.
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import "GLViewController.h"

@interface GLViewController ()

@end

@implementation GLViewController

@synthesize glView = glView_;
@synthesize scene = scene_;
@synthesize world = world_;


- (void)dealloc {
    [glView_ release];
    [director_ release];
    [scene_ release];
    [world_ release];
    [camera_ release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    glView_ = [[REGLView alloc] initWithFrame:CGRectMake(0, 0, 320, 320) colorFormat:kEAGLColorFormatRGBA8 multisampling:YES];
    [self.view addSubview:glView_];
    
    camera_ = [[RECamera alloc] initWithProjection:kRECameraProjectionOrthographic];
    camera_.position = CC3VectorMake(0, 0, 320);
    camera_.upDirection = CC3VectorMake(0, 1, 0);
    camera_.lookDirection = CC3VectorMake(0, 0, -1);
    camera_.frustumNear = 10;
    camera_.frustumFar = 640;
    camera_.frustumLeft = -glView_.frame.size.width / 2.0;
    camera_.frustumRight = glView_.frame.size.width / 2.0;
    camera_.frustumBottom = -glView_.frame.size.height / 2.0;
    camera_.frustumTop = glView_.frame.size.height / 2.0;
    
    scene_ = [[REScene alloc] init];
    scene_.camera = camera_;    
    
    world_ = [[REWorld alloc] init];
    [scene_ addChild:world_];
    
    director_ = [[REDirector alloc] init];
    director_.view = glView_;
    director_.scene = scene_;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [glView_ release], glView_ = nil;
    [director_ release], director_ = nil;
    [scene_ release], scene_ = nil;
    [world_ release], world_ = nil;
    [camera_ release], camera_ = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    director_.running = YES;
    [[REScheduler sharedScheduler] scheduleUpdateForTarget:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    director_.running = NO;
    [[REScheduler sharedScheduler] unscheduleUpdateForTarget:self];
}

- (void)update:(float)dt {
    
}

@end
