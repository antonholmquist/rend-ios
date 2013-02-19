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
#import "CC3Foundation.h"

@class REBuffer;

/* REWavefrontMesh
 
 Contains support only for polygons with edge count 3 (triangels).
 
 This is because opengl es 2.0 draw elments doesn't support polygons with higher edge count.
 Only points, lines and triangels can be drawn.
 
 http://www.khronos.org/opengles/sdk/docs/man/xhtml/glDrawElements.xml
 GL_POINTS, GL_LINE_STRIP, GL_LINE_LOOP, GL_LINES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN, and GL_TRIANGLES
 
 Note: Should probably sse GL_TRIANGELS to draw, (at least if distinct draw mode is not specified)
 
 Design choice: We want to keep the groups and other future parameters seperate. This makes the class more flexible and easier to add stuff later.
 
 Note: All data needed to recreate class is stored in REWavefrontElementComponents. See loadFromElementComponents:
 
 */

// The vertex data: (This is passed directly to opengl together with indices)
typedef struct REWavefrontVertexAttributes {
    CC3Vector vertex;
    CC3Vector texCoord;
    CC3Vector normal;
    CC3Vector tangent;
} REWavefrontVertexAttributes;



@interface REWavefrontElementSet : NSObject <NSCoding> {
    NSMutableArray *indexRanges;
    CC3BoundingBox boundingBox;
}

@property (nonatomic, readonly) CC3BoundingBox boundingBox;

// Array of NSValues with NSRanges. Contains indexes ranges that indicade index of the original
// element indices
@property (nonatomic, readonly) NSArray *indexRanges; 

- (void)addIndex:(int)i; // Must be incremental
- (void)extendBoundingBox:(CC3Vector)position;


@end

@interface REWavefrontMesh : NSObject <NSCoding> {
    
    // This is what we want to get out:
    
    // 1. Vertex attribues
    REWavefrontVertexAttributes *vertexAttributes;
    uint vertexAttributeCount;
    
    // 2. Elements
    GLushort *elementIndices;
    uint elementIndexCount;
    
    // 3. Different element collections (could be all, or by group)
    REWavefrontElementSet *allElements;
    NSMutableDictionary *elementsByGroup;
    
    // 4. Has normals/texcoords
    BOOL hasNormals;
    BOOL hasTexCoords;
    
    NSMutableArray *groups; // Group names
    
    // Buffers
    REBuffer *vertexAttributeBuffer, *elementIndexBuffer;
    
}



@property (nonatomic, readonly) REWavefrontVertexAttributes *vertexAttributes;
@property (nonatomic, readonly) uint vertexAttributeCount;

@property (nonatomic, readonly) GLushort *elementIndices;
@property (nonatomic, readonly) uint elementIndexCount;

@property (nonatomic, readonly) BOOL hasNormals, hasTexCoords;

@property (nonatomic, readonly) NSArray *groups;

// Will use cache. Both obj and reobj are ok
+ (id)meshNamed:(NSString*)filename;

- (id)initWithString:(NSString*)string; // Designated

// Mesh filename in application bundle.
- (id)initWithMeshNamed:(NSString*)filename;

- (REWavefrontElementSet*)allElements;
- (REWavefrontElementSet*)elementsForGroup:(NSString*)group; // Collection elements by group

- (void)createBuffers; // Creates vertex attribute buffer and element index buffer
- (void)deleteBuffers;
- (BOOL)hasBuffers;
- (void)bindBuffers;

@end
