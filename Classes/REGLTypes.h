

typedef GLboolean REGLboolean;

typedef struct {
    GLboolean red, green, blue, alpha;
} REGLColorMask;

typedef struct {
    GLenum sfactor, dfactor;
} REGLBlendFunc;

typedef struct {
    GLenum func;
    GLint ref;
    GLuint mask;
} REGLStencilFunc;

typedef struct {
    GLenum sfail, dpfail, dppass;
} REGLStencilOp;

REGLColorMask REGLColorMaskMake(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha);
BOOL REGLColorMaskEqualToColorMask(REGLColorMask colorMask1, REGLColorMask colorMask2);

REGLBlendFunc REGLBlendFuncMake(GLenum src, GLenum dst);
REGLStencilFunc REGLStencilFuncMake(GLenum func, GLint ref, GLuint mask);
BOOL REGLStencilFuncEqualToStencilFunc(REGLStencilFunc stencilFunc1, REGLStencilFunc stencilFunc2);

REGLStencilOp REGLStencilOpMake(GLenum sfail, GLenum dpfail, GLenum dppass);
BOOL REGLStencilOpEqualToStencilOp(REGLStencilOp stencilOp1, REGLStencilOp stencilOp2);
