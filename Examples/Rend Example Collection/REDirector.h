/*
 * Rend
 *
 * Author: Anton Holmquist
 * Copyright (c) 2012 Anton Holmquist All rights reserved.
 * http://antonholmquist.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

@class REScene;
@class REGLView;

// WARNING!
// USES SHARED SCHEDULER.


@interface REDirector : NSObject {
    CADisplayLink *displayLink;
    NSString *displayLinkRunLoopMode; // Defaults to NSDefaultRunLoopMode. If using scroll views, you may want to change it
    
    REScene *scene;
    REGLView *view;
    
    BOOL running;
    
    BOOL showFPS;
    UIView *statsView;
    UILabel *statsLabel;
    
    NSMutableArray *drawDates;
    
    NSUInteger frameInterval;
    
    float dt; // Time since previous update
    NSTimeInterval lastDrawTime;
    
    BOOL isAppInBackground; // Keep track of that the app has entered background to prevent drawing.
}

@property (nonatomic, retain) REGLView *view;
@property (nonatomic, retain) REScene *scene;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) NSUInteger frameInterval;

@property (nonatomic, assign) BOOL showFPS;
@property (nonatomic, retain) NSString *displayLinkRunLoopMode;

@property (nonatomic, readonly) float dt;

- (void)draw;
- (void)presentRenderbuffer;
- (void)drawWithoutPresentation;
- (UIImage*)snapshot;
@end
