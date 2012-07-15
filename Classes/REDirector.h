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

/** REDirector manages draw cycles. It's responsible for preparing the view for drawing, traversing the node hierarchy and presenting the renderbuffer. 
 */
 

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

/** The view we want to use for drawing. */
@property (nonatomic, retain) REGLView *view;

/** The scene which acts as the root node of the scene grahp hierarchy. */
@property (nonatomic, retain) REScene *scene;

/** When running is set to YES, drawing will be done regurarly according to frameInterval. */
@property (nonatomic, assign) BOOL running;

/** Default to 2 which means 30 frame per second. */
@property (nonatomic, assign) NSUInteger frameInterval;

/** showFPS is not implemented. */
@property (nonatomic, assign) BOOL showFPS;

/** The run loop mode of the display link. */
@property (nonatomic, retain) NSString *displayLinkRunLoopMode;

@property (nonatomic, readonly) float dt;

/** Draws the content of scene to the view. */
- (void)draw;

/** Returns snapshot of view content. */
- (UIImage*)snapshot;

@end
