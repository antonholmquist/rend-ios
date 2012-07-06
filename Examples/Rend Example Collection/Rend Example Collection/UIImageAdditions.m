
#import "UIImageAdditions.h"

@implementation UIImage(NSCoding)

- (id) initWithCoderForArchiver:(NSCoder *)decoder {
    
    if ((self = [super init]))
    {
        NSData *data = [decoder decodeObjectForKey:kEncodingKey];
        self = [self initWithData:data];
    }
    
    return self;
    
}

- (void) encodeWithCoderForArchiver:(NSCoder *)encoder {
    
    NSData *data = UIImagePNGRepresentation(self);
    [encoder encodeObject:data forKey:kEncodingKey];
    
}

@end
