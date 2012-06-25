

#import <Foundation/Foundation.h>
#import "CC3Foundation.h"

@interface RELight : NSObject {
    CC3Vector position_;
    CC3Vector4 ambientColor;
    CC3Vector4 diffuseColor;
    CC3Vector4 specularColor;
    //float specularExponent; // Shininess
}

@property (nonatomic, assign) CC3Vector position;
@property (nonatomic, assign) CC3Vector4 ambientColor;
@property (nonatomic, assign) CC3Vector4 diffuseColor;
@property (nonatomic, assign) CC3Vector4 specularColor;
//@property (nonatomic, assign) float specularExponent;

+ (id)light;

@end

@interface REDirectionalLight : RELight {
    CC3Vector direction_;
}

@property (nonatomic, assign) CC3Vector direction; // Deprecated, use position instead.

@end


@interface REPointLight : RELight {
    
    CC3Vector attenuation; // constant, linear, quadratic
}

@property (nonatomic, assign) CC3Vector attenuation;

@end
