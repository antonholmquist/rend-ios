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

#import "RECache.h"
#import "RETexture2D.h"


@implementation RETextureCache

+ (RETexture2D*)textureNamed:(NSString*)filename {
    
    RETexture2D *texture = nil;
    
    static NSMutableDictionary *textures = nil;
    if (!textures) textures = [[NSMutableDictionary alloc] init];
    
    texture = [textures objectForKey:filename];
    
    if (!texture) {
        if ([[filename pathExtension] isEqual:@"png"] || [[filename pathExtension] isEqual:@"jpg"] ) {
            texture = [[[RETexture2D alloc] initWithImage:[UIImage imageNamed:filename]] autorelease];
        } else if ([[filename pathExtension] isEqual:@"pvr"]) {
            NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
            
            NSString *errorMessage = [NSString stringWithFormat:@"RETextureCache: Can't find file: %@ (%@)", filename, path];
            NSAssert(path, errorMessage);
            
            NSData *data = [NSData dataWithContentsOfFile:path];
            texture = [[[RETexture2D alloc] initWithPVRData:data] autorelease];
        }
        

        [textures setObject:texture forKey:filename];
    }
    
    return texture;
}

+ (RETextureCubeMap*)cubeTextureNamed:(NSString*)filename {
    RETextureCubeMap *texture = nil;
    
    static NSMutableDictionary *textures = nil;
    if (!textures) textures = [[NSMutableDictionary alloc] init];
    
    texture = [textures objectForKey:filename];
    
    if (!texture) {
        if ([[filename pathExtension] isEqual:@"png"]) {
           // texture = [[[RETexture2D alloc] initWithImage:[UIImage imageNamed:filename]] autorelease];
            
            UIImage *image = [UIImage imageNamed:filename];
            
            texture = [[[RETextureCubeMap alloc] init] autorelease];
            [texture setImage:image forTarget:GL_TEXTURE_CUBE_MAP_NEGATIVE_X];
            [texture setImage:image forTarget:GL_TEXTURE_CUBE_MAP_POSITIVE_X];
            [texture setImage:image forTarget:GL_TEXTURE_CUBE_MAP_NEGATIVE_Y];
            
            [texture setImage:image forTarget:GL_TEXTURE_CUBE_MAP_POSITIVE_Y];
            [texture setImage:image forTarget:GL_TEXTURE_CUBE_MAP_NEGATIVE_Z];
            [texture setImage:image forTarget:GL_TEXTURE_CUBE_MAP_NEGATIVE_Z];
            [texture setImage:image forTarget:GL_TEXTURE_CUBE_MAP_POSITIVE_Z];
            
            
        } else if ([[filename pathExtension] isEqual:@"pvr"]) {
            /*
            NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
            
            NSString *errorMessage = [NSString stringWithFormat:@"RETextureCache: Can't find file: %@ (%@)", filename, path];
            NSAssert(path, errorMessage);
            
            NSData *data = [NSData dataWithContentsOfFile:path];
            texture = [[[RETexture2D alloc] initWithPVRData:data] autorelease];
             */
        }
        
        
        [textures setObject:texture forKey:filename];
    }
    
    return texture;
}

@end



@implementation REProgramCache

+ (REProgramCache*)sharedCache {
    static REProgramCache *shared = nil;
    
    if (shared == nil) {
        shared = [[self alloc] init];
    } return shared;
}

- (id)init {
    if (([super init])) {
        dictionary = [[NSMutableDictionary alloc] init];
    } return self;
}


- (REProgram*)programForKey:(id)key {
    return [dictionary objectForKey:key];
}

- (void)setProgram:(REProgram*)program forKey:(id)key {
    [dictionary setObject:program forKey:key];
}

@end

