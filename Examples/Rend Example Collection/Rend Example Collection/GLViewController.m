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

- (void)dealloc {
    [glView_ release];
    [director_ release];
    [scene_ release];
    [camera_ release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    glView_ = [[REGLView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    director_ = [[REDirector alloc] init];
    scene_ = [[REScene alloc] init];
    camera_ = [[RECamera alloc] initWithProjection:kRECameraProjectionOrthographic];
    
    
    [self.view addSubview:glView_];
    scene_.camera = camera_;
    director_.view = glView_;
    director_.scene = scene_;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [glView_ release], glView_ = nil;
    [director_ release], director_ = nil;
    [scene_ release], scene_ = nil;
    [camera_ release], camera_ = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    director_.running = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    director_.running = NO;
}

@end
