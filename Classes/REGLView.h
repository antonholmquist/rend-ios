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

#import <Foundation/Foundation.h>

@interface REGLView : UIView {
    
    // Normal framebuffer
    GLuint framebuffer; 
    GLuint colorRenderbuffer;
    //GLuint depthRenderbuffer;
    GLuint depthStencilRenderbuffer_; // Combined depth and stencil render buffer
    
    // Multisample framebuffers
    GLuint multisampleFramebuffer; // This is used for sampling
    GLuint multisampleColorRenderbuffer;
    //GLuint multisampleDepthRenderbuffer;
    GLuint multisampleDepthStencilRenderbuffer_;
    
    CGRect viewport;
    
    BOOL multisampling_;
}

/** The framebuffer associated with the view */
@property (nonatomic, readonly) GLuint framebuffer; 

/** If multisampling is used, this is the framebuffer associated with the view */
@property (nonatomic, readonly) GLuint multisampleFramebuffer; // Used for multisampling

/** The color renderbuffer associated with the view */
@property (nonatomic, readonly) GLuint colorRenderbuffer;
@property (nonatomic, readonly) GLuint multisampleColorRenderbuffer;

@property (nonatomic, readonly) CGRect viewport;
@property (nonatomic, readonly) BOOL multisampling;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame colorFormat:(NSString*)colorFormat; // kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
- (id)initWithFrame:(CGRect)frame colorFormat:(NSString*)colorFormat multisampling:(BOOL)multisampling;
- (id)initWithFrame:(CGRect)frame colorFormat:(NSString*)colorFormat multisampling:(BOOL)multisampling scale:(float)scale; 

- (void)bindFramebuffer;

@end
