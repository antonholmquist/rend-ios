/*
 * Rend
 *
 * Author: Anton Holmquist
 * Copyright (c) 2012 Anton Holmquist All rights reserved.
 * http://antonholmquist.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "REGLView.h"
#import <QuartzCore/QuartzCore.h>

@interface REGLView ()

@end

@implementation REGLView

@synthesize framebuffer, colorRenderbuffer;
@synthesize viewport;
@synthesize multisampleFramebuffer;

@synthesize multisampling = multisampling_;
//@synthesize stencilRenderBuffer = stencilRenderBuffer_;
//@synthesize depthStencilRenderbuffer = depthStencilRenderbuffer_;

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id)init {
    NSAssert(YES, @"REGLView: Use initWithFrame instead!");
    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame colorFormat:kEAGLColorFormatRGBA8];
}

- (id)initWithFrame:(CGRect)frame colorFormat:(NSString*)colorFormat  {
    return [self initWithFrame:frame colorFormat:colorFormat multisampling:NO];
}

- (id)initWithFrame:(CGRect)frame colorFormat:(NSString*)colorFormat multisampling:(BOOL)multisampling {
    return [self initWithFrame:frame colorFormat:colorFormat multisampling:multisampling scale:[[UIScreen mainScreen] scale]];
}

- (id)initWithFrame:(CGRect)frame colorFormat:(NSString*)colorFormat multisampling:(BOOL)multisampling scale:(float)scale {
    if ((self = [super initWithFrame:frame])) {
        
        //multisampling_ = TARGET_IPHONE_SIMULATOR ? NO : multisampling; // Never use multisampling on simulator (it's slow, but works)
        multisampling_ = multisampling;
        
        
        self.opaque = YES; // Should depend on colorFormat?
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES; // Should depend on colorFormat?
        self.contentScaleFactor = scale; 
        
        // Select color format
        [(CAEAGLLayer *)self.layer setDrawableProperties:
         [NSDictionary dictionaryWithObject:colorFormat forKey:kEAGLDrawablePropertyColorFormat]];
        
        glGenFramebuffers(1, &framebuffer);
        glGenRenderbuffers(1, &colorRenderbuffer);
        
       
        
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
            
        // Create renderbuffer storage.
        [[EAGLContext currentContext] renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        
        // Set framebuffer color renderbuffer to the render buffer created by the eaglcontext above.
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        
        // With and height in pixels
        GLint width, height;
            
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
        
        // http://stackoverflow.com/questions/8149944/does-ios5-support-both-gl-stencil-index-and-gl-stencil-index8
        // In iOS 4.0 and later, separate stencil buffers are not supported. Use a combined depth/stencil buffer.
        //glBindBuffer(GL_RENDERBUFFER, stencilRenderBuffer_);
        //glRenderbufferStorage(GL_RENDERBUFFER, GL_STENCIL_INDEX8, width, height);
        //glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, stencilRenderBuffer_);

        if (multisampling_) {
            
            glGenFramebuffers(1, &multisampleFramebuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, multisampleFramebuffer);
            
            glGenRenderbuffers(1, &multisampleColorRenderbuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, multisampleColorRenderbuffer);
            glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_RGBA8_OES, width, height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, multisampleColorRenderbuffer);
            
            glGenRenderbuffers(1, &multisampleDepthStencilRenderbuffer_);
            glBindRenderbuffer(GL_RENDERBUFFER, multisampleDepthStencilRenderbuffer_);
            glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, 4, GL_DEPTH24_STENCIL8_OES, width, height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, multisampleDepthStencilRenderbuffer_);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, multisampleDepthStencilRenderbuffer_);
            

            
            viewport = CGRectMake(0, 0, 1 * width, 1 * height); // Hardcoded. Should we get these values from somewhere instead?
        } else {
            /*
            glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
             */
            
            // If multisampling is used. DepthRenderbuffer will be in multisampleFramebuffer instead
            glGenRenderbuffers(1, &depthStencilRenderbuffer_);
            
            glBindRenderbuffer(GL_RENDERBUFFER, depthStencilRenderbuffer_);
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, width, height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthStencilRenderbuffer_);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, depthStencilRenderbuffer_);
            viewport = CGRectMake(0, 0, width, height);
             
        }
            
            
        //NSLog(@"error: %d", glGetError());
            
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"GLView: Failed to make complete framebuffer object %x. This happens when we don't have current EAGLContext or if view size is zero.", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        }
        

    } return self;
}

- (void)dealloc {
    
    glDeleteFramebuffers(1, &framebuffer);
    glDeleteRenderbuffers(1, &colorRenderbuffer);
    //if (depthRenderbuffer) glDeleteRenderbuffers(1, &depthRenderbuffer);
    if (depthStencilRenderbuffer_) glDeleteRenderbuffers(1, &depthStencilRenderbuffer_);
    
    if (multisampleColorRenderbuffer) glDeleteRenderbuffers(1, &multisampleColorRenderbuffer);
    if (multisampleDepthStencilRenderbuffer_) glDeleteRenderbuffers(1, &multisampleDepthStencilRenderbuffer_);
    
    [super dealloc];
}

- (void)bindFramebuffer {
    if (multisampling_) {
        glBindFramebuffer(GL_FRAMEBUFFER, multisampleFramebuffer);
    } else {
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    }
}

@end
