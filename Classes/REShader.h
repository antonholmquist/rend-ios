

#import <Foundation/Foundation.h>


@interface REShader : NSObject {
    GLenum type;
    GLuint shader;
    
    NSString *string;
}

@property (nonatomic, readonly) GLuint shader;


- (id)initWithType:(GLenum)type string:(NSString*)string; // Designated
- (id)initWithType:(GLenum)type filename:(NSString*)filename;

@end
