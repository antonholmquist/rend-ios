
#import <Foundation/Foundation.h>



@class RETexture, RETexture2D, RETextureCubeMap;


@interface RETextureCache : NSObject

+ (RETexture2D*)textureNamed:(NSString*)filename;
+ (RETextureCubeMap*)cubeTextureNamed:(NSString*)filename;

@end

@class REProgram;

@interface REProgramCache : NSObject {
    NSMutableDictionary *dictionary;
}

+ (REProgramCache*)sharedCache;

- (REProgram*)programForKey:(id)key;
- (void)setProgram:(REProgram*)program forKey:(id)key;


@end
