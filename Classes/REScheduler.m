

#import "REScheduler.h"
#import "RENSArrayAdditions.h"

@implementation REScheduler

+ (REScheduler*)sharedScheduler {
    static REScheduler *singleton = nil;
    if (singleton == nil) {
        singleton = [[[self class] alloc] init];
    } return singleton;
}

- (id)init {
    if ((self = [super init])) {
        //updateTargets = [[NSMutableArray alloc] init];
        updateTargets = [[NSMutableArray RE_arrayUsingWeakReferences] retain];
    } return self;
}

- (void)scheduleUpdateForTarget:(id)target {
    if ([updateTargets indexOfObjectIdenticalTo:target] == NSNotFound) {
        [updateTargets addObject:target];
        //[target release];
        //NSLog(@"scheduleUpdateForTarget: %p", target);
    } else {
        //NSLog(@"REScheduler: Warning: Trying to schedule update for target twice");
    }
}

- (void)unscheduleUpdateForTarget:(id)target {
    if ([updateTargets indexOfObjectIdenticalTo:target] != NSNotFound) {
        //[target retain];
        [updateTargets removeObjectIdenticalTo:target];   
        //NSLog(@"unscheduleUpdateForTarget: %p", target);
    } else {
        //NSLog(@"REScheduler: Warning: Trying to unschedule update for that isn't scheduled");
    }
}

- (void)tick:(float)dt {
    for (id target in [[updateTargets copy] autorelease]) { // WARNING! May be inefficient to copy!
        [target update:dt];
    }
}

@end
