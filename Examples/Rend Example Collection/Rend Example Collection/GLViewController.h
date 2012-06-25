//
//  GLViewController.h
//  Rend Example Collection
//
//  Created by Anton Holmquist on 6/26/12.
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLViewController : UIViewController {
    REGLView *glView_;
    REScene *scene_;
    REDirector *director_;
    RECamera *camera_;
}

@property (nonatomic, readonly) REGLView *glView;
@property (nonatomic, readonly) REScene *scene;

@end
