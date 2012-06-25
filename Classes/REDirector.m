

#import <QuartzCore/QuartzCore.h>
#import "REDirector.h"
#import "REScheduler.h"
#import "REGLStateManager.h"
#import "REScene.h"
#import "REGLView.h"


@interface REDisplayLink : NSObject {
    NSMutableArray *observers;
    CADisplayLink *displayLink;
}

+ (REDisplayLink*)sharedDisplayLink;

- (void)update:(CADisplayLink*)link;

- (void)addObserver:(id)object;
- (void)removeObserver:(id)object;

- (BOOL)isObserver:(id)object;

- (void)updateDisplayLink;

@end


@implementation REDisplayLink

+ (REDisplayLink*)sharedDisplayLink {
    static REDisplayLink *singleton = nil;
    if (!singleton) {
        singleton = [[self alloc] init];
    } return singleton;
}


- (void)updateDisplayLink {
    if ([observers count] > 0 && !displayLink) {
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
        displayLink.frameInterval = [(REDirector*)[observers objectAtIndex:0] frameInterval];
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    } else if ([observers count] == 0 && displayLink) {
        [displayLink invalidate];
        displayLink = nil;
    }
}

- (void)update:(CADisplayLink*)link {
    // Copy autorelease minimizes risk for mutation while enumeration
    for (id object in [[observers copy] autorelease]) {
        [object draw];
    }
}

- (id)init {
    if ((self = [super init])) {
        observers = [[NSMutableArray alloc] init];
    } return self;
}

- (BOOL)isObserver:(id)object {
    return [observers indexOfObjectIdenticalTo:object] != NSNotFound;
}

- (void)addObserver:(id)object {
    if (![self isObserver:object]) {
        [observers addObject:object];
        [self updateDisplayLink];
    }
}

- (void)removeObserver:(id)object {
    if ([self isObserver:object]) {
        [observers removeObjectIdenticalTo:object];
        [self updateDisplayLink];
    }
}

@end

static int REDirectorNumberOfRunningDirectors = 0;

@interface REDirector ()

- (void)updateStatsLabel;
- (void)updateStatsViewVisibility;

- (void)applicationDidBecomeActive:(NSNotification*)n;
- (void)applicationDidEnterBackground:(NSNotification*)n;
- (void)applicationWillResignActive:(NSNotification*)n;

@end

// Number of times to save
#define kREDirectorDrawDatesCount 10

@implementation REDirector

@synthesize view, scene, running, showFPS, frameInterval, dt, displayLinkRunLoopMode;

- (id)init {
    if ((self = [super init])) {
        
        frameInterval = 2;
        
        displayLinkRunLoopMode = [NSDefaultRunLoopMode retain];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
    }
    
    return self;
}

- (void)dealloc {
    self.running = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [statsView release];
    [displayLink invalidate];
    [scene release];
    [displayLinkRunLoopMode release];
    [view release];
    [super dealloc];
}

#pragma mark - Notifications


- (void)applicationDidBecomeActive:(NSNotification*)n {
    isAppInBackground = NO;
}

- (void)applicationWillResignActive:(NSNotification*)n {
    isAppInBackground = YES;    
    glFinish();
}

- (void)applicationDidEnterBackground:(NSNotification*)n {
    // http://developer.apple.com/library/ios/#documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/ImplementingaMultitasking-awareOpenGLESApplication/ImplementingaMultitasking-awareOpenGLESApplication.html#//apple_ref/doc/uid/TP40008793-CH5-SW1
    glFinish();
}

#pragma mark - Running

- (void)setRunning:(BOOL)r {
    running = r;
    
    // Start
    if (running && ![[REDisplayLink sharedDisplayLink] isObserver:self]) {
        [self draw]; // Draw now to avoid initial flicker
        
        [[REDisplayLink sharedDisplayLink] addObserver:self];
        
        REDirectorNumberOfRunningDirectors++;
        //NSAssert(REDirectorNumberOfRunningDirectors < 2, @"REDirector. We can only have one running director at a time!");
    } 
    
    // Stop
    else if (!running && [[REDisplayLink sharedDisplayLink] isObserver:self]) {
        
        [[REDisplayLink sharedDisplayLink] removeObserver:self];
        
        REDirectorNumberOfRunningDirectors--;
    }
}

- (void)setFrameInterval:(NSUInteger)interval {
    NSAssert(running == NO, @"REDirector: Can't set frameInterval while running!");
    frameInterval = interval;
}

- (void)setShowFPS:(BOOL)yesOrNo {
    showFPS = yesOrNo;
    [self updateStatsViewVisibility];
}

- (void)updateStatsLabel {
    
    
    NSString *text = nil;
    
    if ([drawDates count] == kREDirectorDrawDatesCount) {
        
        float targetFPS = 60.0f / displayLink.frameInterval;
        float actualFPS = ((float)kREDirectorDrawDatesCount) / [[drawDates lastObject] timeIntervalSinceDate:[drawDates objectAtIndex:0]];
        
        text = [NSString stringWithFormat:@"fps: %.1f (target %.1f)", actualFPS, targetFPS];
    } else {
        text = @"Calculating...";
    }
    
    statsLabel.text = text;
}

- (void)updateStatsViewVisibility {
    
    return;
    
    // Only create when first needed
    if (showFPS && statsView == nil) {
        statsView = [[UIView alloc] init];
        statsView.opaque = YES;
        statsView.autoresizesSubviews = YES;
        statsView.backgroundColor = [UIColor whiteColor];
        
        statsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0, statsView.frame.size.width, statsView.frame.size.height)] autorelease];;
        statsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        statsLabel.font = [UIFont boldSystemFontOfSize:12];
        [statsView addSubview:statsLabel];
    }
    
    // See if we should show it
    if (showFPS && statsView.superview != view) {
        [statsView removeFromSuperview];
        statsView.frame = CGRectMake(0, 0, view.frame.size.width, 20);
        [view addSubview:statsView];
        
    } else if (!showFPS && statsView.superview) {
        [statsView removeFromSuperview];
    }
}


- (void)setView:(REGLView *)v {
    [view release];
    view = [v retain];
    
    [self updateStatsViewVisibility];
}

#pragma mark - Draw

- (void)draw {
    
    // Don't draw if we're in background!
    if (isAppInBackground) {
        return;
    }
    
    [self drawWithoutPresentation];
    [self presentRenderbuffer];
    
}

- (void)drawWithoutPresentation {
    
    
    NSAssert(scene && view, @"REDirector: Can't draw if we don't have both scene and view");
    
    // Update dt
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    BOOL useDisplayLinkTime = NO;
    
    // If we have displayLink, get time from that. But store everything anyway.
    if (displayLink && useDisplayLinkTime) {
        dt = displayLink.frameInterval * displayLink.duration;
    } else {
        dt = lastDrawTime == 0 ? 0 : (now - lastDrawTime);
    } lastDrawTime = now;
    
    
    // Warning: Uses sharedScheduler. What is there exists multiple directors? They will tick all schedulers.
    [[REScheduler sharedScheduler] tick:dt];
    
    showFPS = NO;
    // FPS Stuff. May be moved?
    if (showFPS) {
        if (drawDates == nil) {
            drawDates = [[NSMutableArray alloc] initWithCapacity:kREDirectorDrawDatesCount];
        }
        [drawDates addObject:[NSDate date]];
        if ([drawDates count] > kREDirectorDrawDatesCount) {
            [drawDates removeObjectAtIndex:0];
        }
        //[self updateStatsLabel];
        
        //float targetFPS = 60.0f / displayLink.frameInterval;
        //float actualFPS = ((float)kREDirectorDrawDatesCount) / [[drawDates lastObject] timeIntervalSinceDate:[drawDates objectAtIndex:0]];
        
        //NSLog([NSString stringWithFormat:@"fps: %.1f (target %.1f)", actualFPS, targetFPS]);
        
        //NSLog(@"fps: %.1f (target %.1f)", actualFPS, targetFPS);
    }
    
    // Bind current framebuffer
    [view bindFramebuffer];
    
    // Set viewport
    //[[REGLStateManager sharedManager] setViewport:view.viewport.origin.x y:view.viewport.origin.y width:view.viewport.size.width height:view.viewport.size.height];
    
    [[REGLStateManager sharedManager] setViewport:0 y:0 width:view.viewport.size.width height:view.viewport.size.height];
    
    //[[REGLStateManager sharedManager] setViewport:20 y:30 width:100 height:300];
    
    // Clear
    
    
    // Importants to enable writing to dept buffer and color buffer before clearing
    [[REGLStateManager sharedManager] setDepthMask:YES];
    [[REGLStateManager sharedManager] setColorMask:REGLColorMaskMake(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE)];
    // TODO: If disabled, glStencilMask should be set to all ones YES
    
    glClearColor(0,0,0,0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
    
    // Start node iteration
    
    //NSLog(@"--- start frame");
    NSTimeInterval time1 = [NSDate timeIntervalSinceReferenceDate];
    [scene visit];
    //NSLog(@"--- end frame");    
    
    NSTimeInterval t = ([NSDate timeIntervalSinceReferenceDate] - time1) * 1000;
    
    static int i = 0;
    static int batch = 25;
    static float tMax = 0;
    static float tTotal = 0;
    
    tTotal += t;
    tMax = MAX(tMax, t);
    i++;
    
    
    static int iTotal = 0;
    static float tTotalTotal = 0;
    tTotalTotal += t;
    iTotal++;
    
    if (i == batch) {
        // NSLog(@"batch: %d, tAverage: %f, tMax: %f, totalAverage: %f", batch, tTotal / (float)batch, tMax, tTotalTotal / iTotal);
        i = 0;
        tMax = 0;
        tTotal = 0;
    }
    
    
    // NSLog(@"visit time: %f ms, inv: %f", t, 1.0/t * 1000);
    
    
    
    // If multisampling is used, we need to resolve it before displaying
    if (view.multisampling) {
        
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, view.framebuffer);
        glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, view.multisampleFramebuffer);
        glResolveMultisampleFramebufferAPPLE();
        
        const GLenum discards[]  = {GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT}; // When multisampling, discard both color and depth, since the resulta are in another framebuffer
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 3, discards);
        
        
        
    } else {
        //  A discard is a performance hint to OpenGL ES; it tells OpenGL ES that the contents of one or more renderbuffers are not used by your application after the discard command completes. By hinting to OpenGL ES that your application does not need the contents of a renderbuffer, the data in the buffers can be discarded or expensive tasks to keep the contents of those buffers updated can be avoided.   
        const GLenum discards[]  = {GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT};
        glDiscardFramebufferEXT(GL_FRAMEBUFFER, 2, discards);
    }
}

- (void)presentRenderbuffer {
    // Present renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, view.colorRenderbuffer); // This is needed here. Probably has to do with how eaglcontext works.
    [[EAGLContext currentContext] presentRenderbuffer:view.colorRenderbuffer];
}

//Code from Apple Q&A
//http://developer.apple.com/library/ios/#qa/qa1704/_index.html
// Is called in accordanced to instructions in the above Q&A: after draw and before presentation of the render buffer is presented
- (UIImage*)snapshot {
    
    // Don't draw if we're in background!
    if (isAppInBackground) {
        return nil;
    }
    
    [self drawWithoutPresentation];
    GLint backingWidth, backingHeight;
    
    // Bind the color renderbuffer used to render the OpenGL ES view
    // If your application only creates a single color renderbuffer which is already bound at this point, 
    // this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
    // Note, replace "_colorRenderbuffer" with the actual name of the renderbuffer object defined in your class.
//    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    // Get the size of the backing CAEAGLLayer
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    NSInteger x = 0, y = 0, width = backingWidth, height = backingHeight;
    NSInteger dataLength = width * height * 4;
    GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
    
    // Read pixel data from the framebuffer
    glPixelStorei(GL_PACK_ALIGNMENT, 4);
    glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
    
    // Create a CGImage with the pixel data
    // If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
    // otherwise, use kCGImageAlphaPremultipliedLast
    CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace, kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast,
                                    ref, NULL, true, kCGRenderingIntentDefault);
    
    // OpenGL ES measures data in PIXELS
    // Create a graphics context with the target size measured in POINTS
    NSInteger widthInPoints, heightInPoints;
    if (NULL != UIGraphicsBeginImageContextWithOptions) {
        // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
        // Set the scale parameter to your OpenGL ES view's contentScaleFactor
        // so that you get a high-resolution snapshot when its value is greater than 1.0
        //        CGFloat scale = eaglview.contentScaleFactor; //Crash?
        CGFloat scale = [[UIScreen mainScreen] scale];
        widthInPoints = width / scale;
        heightInPoints = height / scale;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
    }
    else {
        // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
        widthInPoints = width;
        heightInPoints = height;
        UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
    }
    
    CGContextRef cgcontext = UIGraphicsGetCurrentContext();
    
    // UIKit coordinate system is upside down to GL/Quartz coordinate system
    // Flip the CGImage by rendering it to the flipped bitmap context
    // The size of the destination area is measured in POINTS
    CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
    CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
    
    // Retrieve the UIImage from the current context
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Clean up
    free(data);
    CFRelease(ref);
    CFRelease(colorspace);
    CGImageRelease(iref);
    
    return image;
}

@end
