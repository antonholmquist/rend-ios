//
//  UIViewAdditions.h
//  Template
//
//  Created by Monterosa iOS Team
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (Additions)

#pragma mark - Origin / Size

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

#pragma mark - Centering

- (void)centerInSuperview;
- (void)centerHorizontallyInSuperview;
- (void)centerVerticallyInSuperview;

// Creates snapshop of current content and returns image.
- (UIImage *)snapshot;

@end
