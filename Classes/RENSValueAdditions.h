

#import <Foundation/Foundation.h>
#import "REGLTypes.h"

@interface NSValue (REAdditions)

// REGLColorMask
+ (NSValue*)valueWithREGLColorMask:(REGLColorMask)v;
- (REGLColorMask)REGLColorMaskValue;

// REGLBlendFunc
+ (NSValue*)valueWithREGLBlendFunc:(REGLBlendFunc)v;
- (REGLBlendFunc)REGLBlencFuncValue;

// REGLStencilFunc
+ (NSValue*)valueWithREGLStencilFunc:(REGLStencilFunc)v;
- (REGLStencilFunc)REGLStencilFuncValue;

// REGLStencilOp
+ (NSValue*)valueWithREGLStencilOp:(REGLStencilOp)v;
- (REGLStencilOp)REGLStencilOpValue;

@end
