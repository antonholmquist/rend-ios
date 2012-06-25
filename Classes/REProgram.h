

#import "REShader.h"


// http://www.khronos.org/opengles/sdk/docs/man/xhtml/glVertexAttrib.xml
// http://www.khronos.org/opengles/sdk/docs/man/xhtml/glBindAttribLocation.xml

/* Local state of program: 
 uniform/attribute locations. 
 uniform values.
 
 Not local:
 attribute values.
 
 The binding between a generic vertex attribute index and a user-defined attribute variable in a vertex shader is part of the state of a program object, but the current value of the generic vertex attribute is not. The value of each generic vertex attribute is part of current state and it is maintained even if a different program object is used.
 */

@interface REProgram : NSObject {

    REShader *vertexShader, *fragmentShader;
    
    GLuint program;
    
    NSMutableDictionary *uniformLocations, *attribLocations;
}

@property (nonatomic, readonly) GLuint program;

+ (REProgram*)programWithVertexFilename:(NSString*)vertexFilename fragmentFilename:(NSString*)fragmentFilename;

- (id)initWithVertexShader:(REShader*)vertexShader fragmentShader:(REShader*)fragmentShader;

- (GLint)uniformLocation:(NSString*)name;
- (GLint)attribLocation:(NSString*)name;

- (void)use; // Sets to current

@end
