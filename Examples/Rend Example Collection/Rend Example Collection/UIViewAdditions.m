//
//  UIViewAdditions.h
//  Template
//
//  Created by Monterosa iOS Team
//  Copyright (c) 2012 Monterosa. All rights reserved.
//

#import "UIViewAdditions.h"

@implementation UIView (Additions)

#pragma mark - Origin / Size

- (CGPoint)origin {
	return CGPointMake(self.frame.origin.x, self.frame.origin.y);
}

- (void)setOrigin:(CGPoint)origin {
	self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);
}

- (CGSize)size {
	return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

- (void)setSize:(CGSize)size {
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
}

#pragma mark - Centering

- (void)centerInSuperview {
	self.frame = CGRectMake(round(self.superview.frame.size.width / 2 - self.frame.size.width / 2), round(self.superview.frame.size.height / 2 - self.frame.size.height / 2), self.frame.size.width, self.frame.size.height);
}

- (void)centerHorizontallyInSuperview {
	self.frame = CGRectMake(round(self.superview.frame.size.width / 2 - self.frame.size.width / 2), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)centerVerticallyInSuperview {
	self.frame = CGRectMake(self.frame.origin.x, round(self.superview.frame.size.height / 2 - self.frame.size.height / 2), self.frame.size.width, self.frame.size.height);
} 

#pragma mark - Positioning

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}


- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

#pragma mark - Render

- (UIImage *)snapshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


@end
