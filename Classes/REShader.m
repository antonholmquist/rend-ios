
#import "REShader.h"

@interface REShader ()

- (void)compile;

@end

@implementation REShader

@synthesize shader;

- (id)initWithType:(GLenum)t filename:(NSString*)n {
    NSString *s = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:n ofType:nil] encoding:NSUTF8StringEncoding error:nil];
    
    NSString *assertMessage = [NSString stringWithFormat:@"REShader: Can't find file named: %@", n];
    NSAssert(s, assertMessage);

    return [self initWithType:t string:s];
}

- (id)initWithType:(GLenum)t string:(NSString*)s {
    if ((self = [super init])) {
        type = t;
        string = [s retain];
        
        NSAssert(string, @"REShader: String is nil");
        
        [self compile];
    } return self;
}

- (void)dealloc {
    glDeleteShader(shader);
    [string release];
    [super dealloc];
}

- (void)compile {
    GLint status;
    
    const GLchar *source = [string UTF8String];
    shader = glCreateShader(type);

    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    
    

    // LOG     // TODO: Parse and log line from error?
    {
        GLint logLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(shader, logLength, &logLength, log);
            NSLog(@"GLProgram: (%@) Compile log:\n%s", string, log);
            free(log);
        }
    }
    
}

@end
