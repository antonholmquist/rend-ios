

@class REScene;
@class REGLView;

// WARNING!
// USES SHARED ACTION MANAGER AND SHARED SCHEDULER.


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
