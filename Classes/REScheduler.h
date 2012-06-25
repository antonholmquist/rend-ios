

#import <Foundation/Foundation.h>

@interface REScheduler : NSObject {
    NSMutableArray *updateTargets;
}

+ (REScheduler*)sharedScheduler;

- (void)tick:(float)dt; // Will cause to call update targets. (dt isn't used)

- (void)scheduleUpdateForTarget:(id)target; // Will call update: before every frame
- (void)unscheduleUpdateForTarget:(id)target;


@end
