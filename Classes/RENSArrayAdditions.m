

#import "RENSArrayAdditions.h"

@implementation NSArray (REAdditions)

@end


@implementation NSMutableArray (REAdditions)

+ (id)RE_arrayUsingWeakReferences {
    return [self RE_arrayUsingWeakReferencesWithCapacity:0];
}

+ (id)RE_arrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity {
    CFArrayCallBacks callbacks = {0, NULL, NULL, CFCopyDescription, CFEqual};
    // We create a weak reference array
    return (id)(CFArrayCreateMutable(0, capacity, &callbacks));
    
    
}

@end