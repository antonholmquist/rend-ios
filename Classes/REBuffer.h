

#import <Foundation/Foundation.h>

/* REBuffer (VBO)
 
 Immutable. Possible to create a mutable version later.
 
 target options:
 GL_ARRAY_BUFFER 
 GL_ELEMENT_ARRAY_BUFFER
 
 */

@interface REBuffer : NSObject {
    GLuint buffer;
    GLenum target;
    
    int length;
}

@property (nonatomic, readonly) GLuint buffer;
@property (nonatomic, readonly) int length;

- (id)initWithTarget:(GLenum)t data:(void*)data length:(int)length; // STATIC_DRAW is default usage
- (id)initWithTarget:(GLenum)t data:(void*)data length:(int)length usage:(GLenum)usage;

- (void)setSubData:(void*)data offset:(int)offset length:(int)length; // Writes data into buffer

- (void)bind;

+ (void)unbind; // Unbinds all targets
+ (void)unbindArrayBuffer;
+ (void)unbindElementArrayBuffer;

/*
 STATIC_DRAW The data store contents will be specified once by the application, and used many times as the source for GL drawing commands.
 DYNAMIC_DRAW The data store contents will be respecified repeatedly by the ap- plication, and used many times as the source for GL drawing commands.
 STREAM_DRAW The data store contents will be specified once by the application, and used at most a few times as the source of a GL drawing command.
 */

@end


/*
@interface REMutableBuffer 

@end
*/