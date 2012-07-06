//
//  SphereViewController.m
//  dgi12Projekt
//
//  Created by Anton Holmberg on 2012-05-25.
//  Copyright (c) 2012 Anton Holmberg. All rights reserved.
//

#import "SphereViewController.h"
#import "AngleUtil.h"
#import "UIImageAdditions.h"

#define kNumberOfTextures 6
#define kImageBaseURL @"http://antonholmquist.com/files/planet_textures/"

#define kSphereIdleRotationSpeedY 0.1f
#define kSphereIdleRotationSpeedX 0.015f

@interface SphereViewController ()

- (void)rotateSphere:(CC3Vector)rotationDelta;
- (void)updateSphereIdleRotation:(float)dt;
- (void)setSphereTextureIndex:(int)textureIndex;
- (void)loadingCompleted;

@end

@implementation SphereViewController

# pragma mark - Life cycle

- (void)viewDidLoad {
    
    glView_ = [[REGLView alloc] initWithFrame:CGRectMake(0, 0, 320, 320) colorFormat:kEAGLColorFormatRGBA8 multisampling:NO];
    [self.view insertSubview:glView_ atIndex:0];
    
    camera_ = [[RECamera alloc] initWithProjection:kRECameraProjectionPerspective];
    camera_.position = CC3VectorMake(0, 0, 5);
    camera_.upDirection = CC3VectorMake(0, 1, 0);
    camera_.lookDirection = CC3VectorMake(0, 0, -1);
    camera_.frustumLeft = -1;
    camera_.frustumRight = 1;
    camera_.frustumBottom = -1;
    camera_.frustumTop = 1;
    camera_.frustumNear = 4;
    camera_.frustumFar = 10;
    
    scene_ = [[REScene alloc] init];
    scene_.camera = camera_;
    
    world_ = [[REWorld alloc] init];
    [scene_ addChild:world_];
    
    director_ = [[REDirector alloc] init];
    director_.view = glView_;
    director_.scene = scene_;
    
    sphereNode_ = [[SphereNode alloc] initWithResolutionX:50 resolutionY:30 radius:1];
    sphereNode_.cullFaceEnabled = [NSNumber numberWithBool:YES];
    sphereNode_.cullFace = [NSNumber numberWithInt:GL_FRONT];
    
    sphereRotationXNode_ = [[RENode alloc] init];
    sphereRotationYNode_ = [[RENode alloc] init];
    sphereRotationXNode_.rotationAxis = CC3VectorMake(1, 0, 0);
    sphereRotationYNode_.rotationAxis = CC3VectorMake(0, 1, 0);
    
    [sphereRotationYNode_ addChild:sphereNode_];
    [sphereRotationXNode_ addChild:sphereRotationYNode_];
    
    [world_ addChild:sphereRotationXNode_];
    
    NSString* cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask, YES) objectAtIndex:0];
    textureImages_ = [[NSKeyedUnarchiver unarchiveObjectWithFile:[cacheDirectory stringByAppendingPathComponent:@"textureImages_"]] retain];
    bumpMapImages_ = [[NSKeyedUnarchiver unarchiveObjectWithFile:[cacheDirectory stringByAppendingPathComponent:@"bumpMapImages_"]] retain];
    
    if(textureImages_ && bumpMapImages_) {
        [self loadingCompleted];
    }
    else {
        textureImages_ = [[NSMutableArray alloc] init];
        bumpMapImages_ = [[NSMutableArray alloc] init];
        [self performSelectorInBackground:@selector(downloadImages) withObject:nil];
    }
    
    
    sphereNode_.bumpMapOffset = bumpOffsetSlider_.value;
    sphereNode_.specularLightBrightness = lightStrengthSlider_.value;
    sphereNode_.shinyness = shinynessSlider_.value;
}

- (void)downloadImages {
    // All textures and bump maps can be downloaded here
    // http://antonholmquist.com/files/planet_textures/all.zip
    
    for(int i = 0; i < 2 * kNumberOfTextures; i++) {
        
        NSString *progressString = [NSString stringWithFormat:@"%d/%d", i + 1, 2 * kNumberOfTextures];
        
        int imageIndex = i / 2;
        BOOL imageIsBumpMap = i % 2 == 1;
        NSString *imageBaseName = imageIsBumpMap ? @"bump" : @"texture";
        NSString *urlString = [NSString stringWithFormat:@"%@%@_%d.png", kImageBaseURL, imageBaseName, imageIndex];
        
        NSURL *imageURL = [NSURL URLWithString:urlString];
        [progressLabel_ performSelectorOnMainThread:@selector(setText:) withObject:progressString waitUntilDone:NO];
        NSURLRequest *imageRequest = [[[NSURLRequest alloc] initWithURL:imageURL cachePolicy:NSURLCacheStorageAllowed timeoutInterval:20] autorelease];
        
        NSError *err = nil;
        NSHTTPURLResponse *response = nil;
        
        NSData * receivedData = [NSURLConnection sendSynchronousRequest:imageRequest returningResponse:&response error:&err];
        
        if(!err && response.statusCode == 200) {
            if (!imageIsBumpMap) [textureImages_ addObject:[UIImage imageWithData:receivedData]];
            else [bumpMapImages_ addObject:[UIImage imageWithData:receivedData]];
        }
        else {
            [self performSelectorOnMainThread:@selector(downloadFailedWithErrorCode:) withObject:[NSNumber numberWithInt:response.statusCode] waitUntilDone:NO];
            return;
        }
    }
    
    NSString* cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask, YES) objectAtIndex:0];
    [NSKeyedArchiver archiveRootObject:textureImages_ toFile:[cacheDirectory stringByAppendingPathComponent:@"textureImages_"]];
    [NSKeyedArchiver archiveRootObject:bumpMapImages_ toFile:[cacheDirectory stringByAppendingPathComponent:@"bumpMapImages_"]];
    
    [self performSelectorOnMainThread:@selector(loadingCompleted) withObject:nil waitUntilDone:NO];
}

- (void)loadingCompleted {
    [activityView_ stopAnimating];
    [loadingView_ removeFromSuperview];
    loadingView_ = nil;
    
    [self setSphereTextureIndex:0];
    
    director_.running = YES;
    [[REScheduler sharedScheduler] scheduleUpdateForTarget:self];
}

- (void)downloadFailedWithErrorCode:(NSNumber *)errorCode {
    [activityView_ stopAnimating];
    [activityView_ removeFromSuperview];
    
    progressLabel_.text = [NSString stringWithFormat:@"Download failed - %@", errorCode];
}

- (void)dealloc {
    [glView_ release];
    [world_ release];
    [director_ release];
    [camera_ release];
    [scene_ release];
    
    [sphereNode_ release];
    [sphereRotationXNode_ release];
    [sphereRotationYNode_ release];
    
    [textureImages_ release];
    [bumpMapImages_ release];
    
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [glView_ release], glView_ = nil;
    [director_ release], director_ = nil;
    [scene_ release], scene_ = nil;
    [world_ release], world_ = nil;
    [camera_ release], camera_ = nil;
    
    [sphereNode_ release], sphereNode_ = nil;
    [sphereRotationXNode_ release], sphereRotationXNode_ = nil;
    [sphereRotationYNode_ release], sphereRotationYNode_ = nil;
    
    [textureImages_ release], textureImages_ = nil;
    [bumpMapImages_ release], bumpMapImages_ = nil;
}

#pragma mark - Sphere texture Update

- (void)setSphereTextureIndex:(int)textureIndex {
    sphereTextureIndex_ = textureIndex;
    sphereNode_.texture = [RETexture2D textureWithImage:[textureImages_ objectAtIndex:sphereTextureIndex_]];
    sphereNode_.bumpMap = [RETexture2D textureWithImage:[bumpMapImages_ objectAtIndex:sphereTextureIndex_]];
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(loadingView_) return;
    
    isTouchingSphere_ = YES;
    tapIsValid_ = YES;
    CGPoint point = [[touches anyObject] locationInView:glView_];
    touchStartPoint_ = point;
    
    lastDragPoints_[0] = point;
    lastDragPoints_[1] = point;
    sphereRotationSpeed_ = CC3VectorMake(0, SIGN(sphereRotationSpeed_.y) * kSphereIdleRotationSpeedY, 0);
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(loadingView_) return;
    
    CGPoint point = [[touches anyObject] locationInView:glView_];
    CGPoint diff = CGPointMake(point.x - touchStartPoint_.x, point.y - touchStartPoint_.y);
    float distance = sqrtf(diff.x * diff.x + diff.y * diff.y);
    if(distance > 10) {
        tapIsValid_ = NO;
    }
    
    if(!tapIsValid_) {
        
        lastDragPoints_[0] = lastDragPoints_[1];
        lastDragPoints_[1] = point;
        CGPoint delta = CGPointMake(lastDragPoints_[1].x - lastDragPoints_[0].x, lastDragPoints_[1].y - lastDragPoints_[0].y);
        
        [self rotateSphere:CC3VectorMake(delta.y * 0.8f, delta.x * 0.8f, 0)];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(loadingView_) return;
    
    CGPoint delta = CGPointMake(lastDragPoints_[1].x - lastDragPoints_[0].x, lastDragPoints_[1].y - lastDragPoints_[0].y);
    if(ABS(delta.x) > 5) delta.y = 0;
    
    if (sqrt(delta.x * delta.x + delta.y * delta.y) > 2) {
        sphereRotationSpeed_ = CC3VectorMake(delta.y * 0.5f, delta.x * 0.5f, 0);
    }
    else {
        if(delta.x != 0 && SIGN(delta.x) != SIGN(sphereRotationSpeed_.y)) {
            sphereRotationSpeed_.y = -sphereRotationSpeed_.y;
        }
    }
    
    isTouchingSphere_ = NO;
    
    if(tapIsValid_) {
        int newTextureIndex = (sphereTextureIndex_ + 1) % textureImages_.count;
        [self setSphereTextureIndex:newTextureIndex];
    }
}

#pragma mark - Updates

- (void)update:(double)dt {
    [self updateSphereIdleRotation:dt];
}

- (void)updateSphereIdleRotation:(float)dt {
    
    // Don't idle rotate, if we're currently touching sphere
    if(isTouchingSphere_) {
        return;
    }
    
    float timeFactor = dt/(1/60.0f);
    [self rotateSphere:CC3VectorScaleUniform(sphereRotationSpeed_, timeFactor)];
    
    float deaccelerationFactorY = 0.90f;
    float deaccelerationFactorX = 0.82f;
    
    if(ABS(sphereRotationSpeed_.y) > kSphereIdleRotationSpeedY) {
        sphereRotationSpeed_.y *= powf(deaccelerationFactorY, timeFactor);
    }
    else {
        
        if(ABS(sphereRotationSpeed_.y) < kSphereIdleRotationSpeedY) {
            
            float directionY = sphereRotationSpeed_.y != 0 ? SIGN(sphereRotationSpeed_.y) : 1;
            float newRotationY = sphereRotationSpeed_.y + directionY * 0.02f;
            if(ABS(sphereRotationSpeed_.y) > kSphereIdleRotationSpeedY)
                newRotationY = SIGN(sphereRotationSpeed_.y) * kSphereIdleRotationSpeedY;
            
            sphereRotationSpeed_.y = newRotationY;
        }
    }
    
    if(ABS(sphereRotationSpeed_.x) > kSphereIdleRotationSpeedX) {
        sphereRotationSpeed_.x *= powf(deaccelerationFactorX, timeFactor);
    }
    else {
        float currentRotationX = [AngleUtil spinAngle:sphereRotationXNode_.rotationAngle within360DegreesFrom:-180];
        
        if(ABS(currentRotationX) > 0.2f) {
            float targetRotationSpeedX = kSphereIdleRotationSpeedX * -SIGN(currentRotationX);
            if(sphereRotationSpeed_.x != targetRotationSpeedX) {
                sphereRotationSpeed_.x += SIGN(targetRotationSpeedX - sphereRotationSpeed_.x) * 0.2f;
                if(ABS(sphereRotationSpeed_.x) > ABS(targetRotationSpeedX)) {
                    sphereRotationSpeed_.x = targetRotationSpeedX;
                }
            }
        }
        else {
            sphereRotationSpeed_.x = 0;
            sphereRotationXNode_.rotationAngle = 0;
        }
    }
}

- (void)rotateSphere:(CC3Vector)rotationDelta {
    
    NSAssert(rotationDelta.z == 0, @"Rotating sphere around the z-axis is not allowed");
    
    float newRotationX = [AngleUtil spinAngle:sphereRotationXNode_.rotationAngle + rotationDelta.x within360DegreesFrom:-180];
    float newRotationY = [AngleUtil spinAngle:sphereRotationYNode_.rotationAngle + rotationDelta.y within360DegreesFrom:-180];
    
    float maxRotationX = 70;
    if(newRotationX > maxRotationX) newRotationX = maxRotationX;
    if(newRotationX < -maxRotationX) newRotationX = -maxRotationX;
    
    
    sphereRotationXNode_.rotationAngle = newRotationX;
    sphereRotationYNode_.rotationAngle = newRotationY;
}

#pragma mark - IBActions

- (IBAction)shinynessChanged:(UISlider *)slider {
    sphereNode_.shinyness = slider.value;
}

- (IBAction)lightStrengthChanged:(UISlider *)slider {
    sphereNode_.specularLightBrightness = lightStrengthSlider_.value;
}

- (IBAction)bumpOffsetChanged:(UISlider *)slider {
    sphereNode_.bumpMapOffset = slider.value;
}

@end
