
#import "RENSValueAdditions.h"

@implementation NSValue (REAdditions)

+ (NSValue*)valueWithREGLColorMask:(REGLColorMask)v {
    return [NSValue valueWithBytes:&v objCType:@encode(REGLColorMask)];
}

- (REGLColorMask)REGLColorMaskValue {
    REGLColorMask v;
    [self getValue:&v];
    return v;
}

+ (NSValue*)valueWithREGLBlendFunc:(REGLBlendFunc)v {
    return [NSValue valueWithBytes:&v objCType:@encode(REGLBlendFunc)];
}

- (REGLBlendFunc)REGLBlencFuncValue {
    REGLBlendFunc v;
    [self getValue:&v];
    return v;
}

+ (NSValue*)valueWithREGLStencilFunc:(REGLStencilFunc)v {
    return [NSValue valueWithBytes:&v objCType:@encode(REGLStencilFunc)];
}

- (REGLStencilFunc)REGLStencilFuncValue {
    REGLStencilFunc v;
    [self getValue:&v];
    return v;
}

+ (NSValue*)valueWithREGLStencilOp:(REGLStencilOp)v {
    return [NSValue valueWithBytes:&v objCType:@encode(REGLStencilOp)];
}

- (REGLStencilOp)REGLStencilOpValue {
    REGLStencilOp v;
    [self getValue:&v];
    return v;
}


@end
