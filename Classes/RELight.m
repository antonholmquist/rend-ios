

#import "RELight.h"

@implementation RELight

@synthesize ambientColor, diffuseColor, specularColor;

@synthesize position = position_;

+ (id)light {
    return [[[self alloc] init] autorelease];
}

- (id)init {
    if ((self = [super init])) {
        ambientColor = CC3Vector4Make(1, 1, 1, 1);
        diffuseColor = CC3Vector4Make(1, 1, 1, 1);
        specularColor = CC3Vector4Make(1, 1, 1, 1);
    } return self;
}

@end

@implementation REDirectionalLight

@synthesize direction = direction_;

- (id)init {
    if ((self = [super init])) {
        direction_ = CC3VectorMake(1, 1, 1);
    } return self;
}

@end

@implementation REPointLight

@synthesize attenuation;

@end