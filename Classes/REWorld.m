

#import "REWorld.h"

@interface REWorld () 
    

@end

@implementation REWorld

@synthesize environmentMap;

- (id)init {
    if ((self = [super init])) {
        lightsByClass_ = [[NSMutableDictionary alloc] init];
    } return self;
}

- (void)dealloc {
    [lightsByClass_ release];
    [super dealloc];
}

#pragma mark - Lights

- (NSArray*)lightsOfClass:(Class)lightClass {
    NSString *key = NSStringFromClass(lightClass);
    return [lightsByClass_ objectForKey:key];
}

- (NSArray*)lights {
    return nil; // Deprectated.
}

- (void)addLight:(RELight*)light {
    
    NSString *key = NSStringFromClass([light class]);
    NSMutableArray *lights = [lightsByClass_ objectForKey:key];
    
    // If this is the first light of it's kind. Create array.
    if (!lights) {
        lights = [NSMutableArray array];
        [lightsByClass_ setObject:lights forKey:key];
    }
    
    if ([lights indexOfObjectIdenticalTo:light] == NSNotFound) {
        [lights addObject:light];    
    }
    
}

- (void)removeLight:(RELight*)light {
    
    NSString *key = NSStringFromClass([light class]);
    NSMutableArray *lights = [lightsByClass_ objectForKey:key];
    
    if ([lights indexOfObjectIdenticalTo:light] != NSNotFound) {
        [lights removeObject:light];    
        
        // If this is the last light of it's kind. Remove array.
        if ([lights count] == 0) {
            [lightsByClass_ removeObjectForKey:key];
        }
    }
}


@end
