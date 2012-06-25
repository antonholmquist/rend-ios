

#import "REBuffer.h"
#import "REGLStateManager.h"

@implementation REBuffer

@synthesize buffer, length;

- (id)initWithTarget:(GLenum)t data:(void*)d length:(int)l {
    return [self initWithTarget:t data:d length:l usage:GL_STATIC_DRAW];
}

- (id)initWithTarget:(GLenum)t data:(void*)data length:(int)l usage:(GLenum)usage {
    if ((self = [super init])) {
        target = t;
        length = l;
        glGenBuffers(1, &buffer);
        //glBindBuffer(target, buffer);
        [self bind];
        glBufferData(target, length, (data ? data : NULL), usage);
    } return self;
}

- (void)dealloc {
    
    // If buffer is bound, it will be unbound when deleted. Therefore, we set state to correspond before
    if (target == GL_ARRAY_BUFFER && [[REGLStateManager sharedManager] arrayBufferBinding] == buffer) {
        [[REGLStateManager sharedManager] setArrayBufferBinding:0];
    } else if (target == GL_ELEMENT_ARRAY_BUFFER && [[REGLStateManager sharedManager] elementArrayBufferBinding] == buffer) {
        [[REGLStateManager sharedManager] setElementArrayBufferBinding:0];
    }
    
    glDeleteBuffers(1, &buffer); 
    
    [super dealloc];
}

- (void)setSubData:(void*)data offset:(int)offset length:(int)theLength {
    [self bind];
    glBufferSubData(target, offset, theLength, data);
}

#pragma mark - Binding

- (void)bind {

    //glBindBuffer(target, buffer);
    if (target == GL_ARRAY_BUFFER) {
        [[REGLStateManager sharedManager] setArrayBufferBinding:buffer];
    } else if (target == GL_ELEMENT_ARRAY_BUFFER) {
        [[REGLStateManager sharedManager] setElementArrayBufferBinding:buffer];
    }
}



+ (void)unbind {
    
    [self unbindArrayBuffer];
    [self unbindElementArrayBuffer];
    
//    glBindBuffer(GL_ARRAY_BUFFER, 0);
 //   glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

+ (void)unbindArrayBuffer {
    [[REGLStateManager sharedManager] setArrayBufferBinding:0];
}

+ (void)unbindElementArrayBuffer {
    [[REGLStateManager sharedManager] setElementArrayBufferBinding:0];
}

@end
