


#import "RENode.h"

@class RECamera;
@class RETextureCubeMap;
@class RELight;

/* REWorld
 
 Manages lights, etc.
 
 Note: Camera is moved to node, since we may have billboards and stuff wh
 */

@interface REWorld : RENode {
    //RECamera *camera; // Should camera be a node? The camera itself should not have a camera, contentSize, etc...
    
    NSMutableDictionary *lightsByClass_; // Key
    
    RETextureCubeMap *environmentMap;
}

@property (nonatomic, retain) RETextureCubeMap *environmentMap;

@property (nonatomic, readonly) NSArray *lights;

- (void)addLight:(RELight*)light;
- (void)removeLight:(RELight*)light;

- (NSArray*)lightsOfClass:(Class)lightClass;

@end
