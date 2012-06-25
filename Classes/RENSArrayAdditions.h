
#import <Foundation/Foundation.h>

@interface NSArray (REAdditions)

@end

@interface NSMutableArray (REAdditions)

+ (id)RE_arrayUsingWeakReferences;
+ (id)RE_arrayUsingWeakReferencesWithCapacity:(NSUInteger)capacity;

@end

