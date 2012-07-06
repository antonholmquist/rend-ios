//
//  SphereViewController.h
//  dgi12Projekt
//
//  Created by Anton Holmberg on 2012-05-25.
//  Copyright (c) 2012 Anton Holmberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SphereNode.h"

@interface SphereViewController : UIViewController {
    
    // Rend classes
    REGLView *glView_;
    REDirector *director_;
    REScene *scene_;
    RECamera *camera_;
    REWorld *world_;
    
    // The sphere
    SphereNode *sphereNode_;
    int sphereTextureIndex_;
    
    // Touch / rotation handling
    CGPoint lastDragPoints_[2];
    CC3Vector sphereRotationSpeed_;
    RENode *sphereRotationXNode_;
    RENode *sphereRotationYNode_;
    BOOL isTouchingSphere_;
    CGPoint touchStartPoint_;
    BOOL tapIsValid_;
    
    // Sliders
    IBOutlet UISlider *shinynessSlider_;
    IBOutlet UISlider *lightStrengthSlider_;
    IBOutlet UISlider *bumpOffsetSlider_;
    IBOutlet UIView *loadingView_;
    IBOutlet UILabel *progressLabel_;
    IBOutlet UIActivityIndicatorView *activityView_;
    
    // Images
    NSMutableArray *textureImages_;
    NSMutableArray *bumpMapImages_;
}

- (IBAction)shinynessChanged:(UISlider *)slider;
- (IBAction)lightStrengthChanged:(UISlider *)slider;
- (IBAction)bumpOffsetChanged:(UISlider *)slider;

@end
