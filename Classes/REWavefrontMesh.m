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

#import "REWavefrontMesh.h"
#import "REBuffer.h"
#import "RECache.h"

// An element component is indexes for (v/vt/vn) together with groups
@interface REWavefrontElementComponent : NSObject {
    NSString *attributeIndexes; // (123/4231/324)
    NSArray *groups, *smoothingGroups, *mergingGroups;
} 

@property (nonatomic, retain) NSString *attributeIndexes;
@property (nonatomic, retain) NSArray *groups, *smoothingGroups, *mergingGroups;

@end

@implementation REWavefrontElementComponent 

@synthesize attributeIndexes, groups, smoothingGroups, mergingGroups;

- (void)dealloc {
    [attributeIndexes release];
    [groups release];
    [smoothingGroups release];
    [mergingGroups release];
    [super dealloc];
}

@end


@implementation REWavefrontElementSet

@synthesize boundingBox, indexRanges;

- (id)init {
    if ((self = [super init])) {
        boundingBox = CC3BoundingBoxMake(100000, 100000, 100000,
                                         -100000, -100000, -100000);
        
        indexRanges = [[NSMutableArray alloc] init];
    } return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {

        boundingBox.minimum.x = [coder decodeFloatForKey:@"boundingBox.minimum.x"];
        boundingBox.minimum.y = [coder decodeFloatForKey:@"boundingBox.minimum.y"];
        boundingBox.minimum.z = [coder decodeFloatForKey:@"boundingBox.minimum.z"];
        
        boundingBox.maximum.x = [coder decodeFloatForKey:@"boundingBox.maximum.x"];
        boundingBox.maximum.y = [coder decodeFloatForKey:@"boundingBox.maximum.y"];
        boundingBox.maximum.z = [coder decodeFloatForKey:@"boundingBox.maximum.z"];
        
        indexRanges = [[coder decodeObjectForKey:@"indexRanges"] retain];
        
    } return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {    
    [coder encodeFloat:boundingBox.minimum.x forKey:@"boundingBox.minimum.x"];
    [coder encodeFloat:boundingBox.minimum.y forKey:@"boundingBox.minimum.y"];
    [coder encodeFloat:boundingBox.minimum.z forKey:@"boundingBox.minimum.z"];
    
    [coder encodeFloat:boundingBox.maximum.x forKey:@"boundingBox.maximum.x"];
    [coder encodeFloat:boundingBox.maximum.y forKey:@"boundingBox.maximum.y"];
    [coder encodeFloat:boundingBox.maximum.z forKey:@"boundingBox.maximum.z"];
    
    [coder encodeObject:indexRanges forKey:@"indexRanges"];
    
    
}

- (void)addIndex:(int)i {
    NSValue *lastRangeValue = [indexRanges lastObject];
    
    BOOL createNewRange = NO;
    
    if (lastRangeValue) {
        NSRange range = [lastRangeValue rangeValue];
        
        if (range.location + range.length == i) {
            [indexRanges replaceObjectAtIndex:[indexRanges indexOfObject:lastRangeValue] 
                                   withObject:[NSValue valueWithRange:NSMakeRange(range.location, range.length + 1)]];
        }
        
    } else {
        createNewRange = YES;
    }
    
    if (createNewRange) {
        NSValue *rangeValue = [NSValue valueWithRange:NSMakeRange(i, 1)];
        [indexRanges addObject:rangeValue];
    }
}

- (void)extendBoundingBox:(CC3Vector)position {
    boundingBox.minimum.x = MIN(boundingBox.minimum.x, position.x);
    boundingBox.minimum.y = MIN(boundingBox.minimum.y, position.y);
    boundingBox.minimum.z = MIN(boundingBox.minimum.z, position.z);
    boundingBox.maximum.x = MAX(boundingBox.maximum.x, position.x);
    boundingBox.maximum.y = MAX(boundingBox.maximum.y, position.y);
    boundingBox.maximum.z = MAX(boundingBox.maximum.z, position.z);
}

- (void)dealloc {
    [indexRanges release];
    [super dealloc];
}


@end


@interface REWavefrontMesh ()

@end

@implementation REWavefrontMesh

@synthesize vertexAttributes, vertexAttributeCount;
@synthesize elementIndices, elementIndexCount;
@synthesize hasNormals, hasTexCoords, groups;


+ (id)meshNamed:(NSString*)filename {
    return [REMeshCache meshNamed:filename];
}

- (id)initWithMeshNamed:(NSString*)filename {
    NSString *s = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:filename ofType:nil] encoding:NSUTF8StringEncoding error:nil];
    NSString *assertMessage = [NSString stringWithFormat:@"REWavefrontObject: Could not read file named: %@", filename];
    NSAssert(s, assertMessage);
    return [self initWithString:s];
}

- (id)initWithString:(NSString*)string {
    if ((self = [super init])) {
        
        // Get lines
        NSArray *lines = [string componentsSeparatedByString:@"\n"];   
        
        // Count number of v, vt and vn, so we can allocate temporary memory.
        uint vertexCount = 0;
        uint vertexNormalCount = 0;
        uint vertexTexCoordCount = 0;
        
        for (NSString *line in lines) {
            if ([line hasPrefix:@"v "]) {
                vertexCount++;
            } else if ([line hasPrefix:@"vt "]) {
                vertexTexCoordCount++;
            } else if ([line hasPrefix:@"vn "]) {
                vertexNormalCount++;
            } 
        }

        // See if we have texcoords and normals
        hasTexCoords = vertexTexCoordCount > 0;
        hasNormals = vertexNormalCount > 0;
        
        // Allocate temporary memory single v, vt and vn.
        CC3Vector *vertices = calloc(sizeof(CC3Vector), vertexCount);
        CC3Vector *vertexNormals = calloc(sizeof(CC3Vector), vertexNormalCount);
        CC3Vector *vertexTexCoords = calloc(sizeof(CC3Vector), vertexTexCoordCount);
        
        // Create index counters
        uint vertexIndex = 0;
        uint vertexNormalIndex = 0;
        uint vertexTexCoordIndex = 0;
        
        NSLog(@"vertexCount: %d", vertexCount);
        NSLog(@"vertexNormalCount: %d", vertexNormalCount);
        NSLog(@"vertexTexCoordCount: %d", vertexTexCoordCount);
        
       // CC3Vector boundingBoxMin = CC3VectorMake(100000, 100000, 100000);
       // CC3Vector boundingBoxMax = CC3VectorMake(-100000, -100000, -100000);
        
       // NSMutableArray *faceComponents = [NSMutableArray array]; // Array strings Facecompoenent is  (5319/5398/8736). Compontent of face.
        
        // Currently active groups. This affects faces preceding it.
        NSMutableArray *currentGroups = [NSMutableArray array];
        
        // The element components (these are fetched from the individual components on f lines). These should be considered grouped by 3
        NSMutableArray *elementComponents = [NSMutableArray array];
        
        // Define the line prefixes that we see as relevant.
        NSString *releventLinePrefixes = @"v,vt,vn,f,g";
        
        // Find the unique element component attribute indexes ex (213,432,432)
        NSMutableSet *uniqueElemementComponentAttributeIndexes = [NSMutableSet set];
        NSMutableDictionary *elementComponentsByGroup = [NSMutableDictionary dictionary];
        
        // Loop through all lines
        // For v,vt,vn store the values
        // For f, store in elementComponents together with current group and such
        //for (NSString *line in lines) {
        for (int l = 0; l < [lines count]; l++) {
            
            if (l % 100 == 0) {
                //NSLog(@"line percentage: %f %%", (float)l / (float)[lines count] * 100);
            }
            
            NSString *line = [lines objectAtIndex:l];
            
            // Start by trimming lines
            NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            // Find line prefix and content
            NSString *linePrefix = nil; // v,vt, etc..
            NSString *lineContent = nil; // Everything after predix
            
            // Create scanner to get line without precix
            NSScanner *scanner = [[[NSScanner alloc] initWithString:trimmedLine] autorelease];
            [scanner scanUpToString:@" " intoString:&linePrefix];
            [scanner scanString:@" " intoString:nil];
            
            // If line isn't defined as relevant above, just continue
            if ([[releventLinePrefixes componentsSeparatedByString:@","] indexOfObject:linePrefix] == NSNotFound) {
                continue;
            }
            
            // We now have line without prefix
            lineContent = [line substringWithRange:NSMakeRange([scanner scanLocation], [line length] - [scanner scanLocation])];
            
            NSString *lineComponentSeparator = nil;
            
            // If it's v,vt,vn,f, components are seperated by space.
            if ([linePrefix isEqual:@"v"] || [linePrefix isEqual:@"vt"] || [linePrefix isEqual:@"vn"]  || [linePrefix isEqual:@"f"] ) {
                lineComponentSeparator = @" ";
            } else if ([linePrefix isEqual:@"g"]) {
                lineComponentSeparator = @",";
            }
            
            // Find lineComponents, (and remove whitespace and irrelevant components)
            NSMutableArray *lineComponents = nil; 
            
            lineComponents = [NSMutableArray arrayWithArray:[lineContent componentsSeparatedByString:lineComponentSeparator]];
            NSMutableIndexSet *lineComponentIndexesToRemove = [NSMutableIndexSet indexSet];
            for (int i = 0; i < [lineComponents count]; i++) {
                NSString *trimmedLineComponent = [[lineComponents objectAtIndex:i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                if ([trimmedLineComponent length] == 0) {
                    [lineComponentIndexesToRemove addIndex:i];
                } else {
                    [lineComponents replaceObjectAtIndex:i withObject:trimmedLineComponent];
                }
            } [lineComponents removeObjectsAtIndexes:lineComponentIndexesToRemove];
            
            //NSLog(@"lineComponents: %@", lineComponents);
            
            // Go through the different lines based on prefix.
            // For v,vt,vn, populate vertices, vertexTexCoords, vertexNormals
            if ([linePrefix isEqual:@"v"]) {
                float x = [(NSString*)[lineComponents objectAtIndex:0] floatValue];
                float y = [(NSString*)[lineComponents objectAtIndex:1] floatValue];
                float z = [(NSString*)[lineComponents objectAtIndex:2] floatValue];
                vertices[vertexIndex] = CC3VectorMake(x, y, z); //Default
                //vertices[vertexIndex] = CC3VectorMake(x, z, -y); //TransformersMeshCoordinates
                vertexIndex++;
            } else if ([linePrefix isEqual:@"vt"]) {
                float s = [(NSString*)[lineComponents objectAtIndex:0] floatValue];
                float t = [(NSString*)[lineComponents objectAtIndex:1] floatValue];
                vertexTexCoords[vertexTexCoordIndex] = CC3VectorMake(s, t, 0);
                vertexTexCoordIndex++;
            } else if ([linePrefix isEqual:@"vn"]) {
                float x = [(NSString*)[lineComponents objectAtIndex:0] floatValue];
                float y = [(NSString*)[lineComponents objectAtIndex:1] floatValue];
                float z = [(NSString*)[lineComponents objectAtIndex:2] floatValue];
                vertexNormals[vertexNormalIndex] = CC3VectorMake(x, y, z); //Default
                //vertexNormals[vertexNormalIndex] = CC3VectorMake(x, z, -y); //TransformersMeshCoordinates
                vertexNormalIndex++;
            } else if ([linePrefix isEqual:@"f"]) {
                NSAssert([lineComponents count] == 3, @"REWavefrontObject: All faces need to have 3 components");
                static int count = 0;
                //NSLog(@"count: %d",count);
                count++;
                // lineComponents = ("189/189/154", "372/372/352", "371/371/351")
                
                // If there are no current groups, use default group
                NSArray *actualCurrentGroups = [currentGroups count] > 0 ? currentGroups : [NSArray arrayWithObject:@"DefaultGroup"];
                
                // Loop through the 3 element components
                for (int i = 0; i < 3; i++) {
                    
                    //NSArray *elementComponentAttributeIndexes = [[lineComponents objectAtIndex:i] componentsSeparatedByString:@"/"];           
                    
                    
                    
                    NSString *elementComponentAttributeIndexes = [lineComponents objectAtIndex:i];
                    // elementComponentAttributeIndexes = "189/189/154"
                    
                    REWavefrontElementComponent *elementComponent = [[[REWavefrontElementComponent alloc] init] autorelease];
                    elementComponent.attributeIndexes = elementComponentAttributeIndexes;
                    elementComponent.groups = [[actualCurrentGroups copy] autorelease];
                    [elementComponents addObject:elementComponent];
                    
                   // NSLog(@"elementComponent.attributeIndexes hash: %i, second: %i", [elementComponent.attributeIndexes hash], [[lineComponents objectAtIndex:i]  hash]);
                    
                    // Also store unique attribute indexes
                    [uniqueElemementComponentAttributeIndexes addObject:elementComponent.attributeIndexes];
                    
                    // Add to dictionary by groups
                    
                    for (NSString *group in actualCurrentGroups) {
                        NSMutableArray *groupElementComponents = [elementComponentsByGroup objectForKey:group];
                        
                        [groupElementComponents addObject:elementComponent];
                    }
                }
                 
                
                
            } else if ([line hasPrefix:@"g"]) {
                // Update current groups to affect the coming f lines.
                [currentGroups setArray:lineComponents];
                
                // Prepare to populate element components by group
                for (NSString *group in lineComponents) {
                    NSMutableArray *elementComponents = [elementComponentsByGroup objectForKey:group];
                    if (!elementComponents) {
                        elementComponents = [NSMutableArray array];
                        [elementComponentsByGroup setObject:elementComponents forKey:group];
                    }
                }
                

                
            }
        }
        

        // Move from set to array (with slight shortened name). The array contains arrays of the unique attribute indexes (123,324,234)
        NSArray *uniqueAttributeIndexes = [uniqueElemementComponentAttributeIndexes allObjects];
        
        // Special case. If there are no faces in the file, then we're creating faces so that the vertex attributes (positions) can be parsed later.
        // This may seem as a strange way to do it, but it's a bit problematic to just set the positions since they are tightly
        // connected with normals and texCoords based on faces.
        // Anyway, this can be useful it we only want read a point cloud by using the wavefront mesh parser and cache
        
        
        if ([uniqueAttributeIndexes count] == 0) {
            NSMutableArray *a = [NSMutableArray array];
            
            
            
            
            
            for (int i = 0; i < vertexCount; i++) {
                NSString *s = [NSString stringWithFormat:@"%d", i + 1];
                [a addObject:s];
                
                REWavefrontElementComponent *elementComponent = [[[REWavefrontElementComponent alloc] init] autorelease];
                elementComponent.attributeIndexes = s;
                elementComponent.groups = [NSArray arrayWithObject:@"DefaultGroup"];
                [elementComponents addObject:elementComponent];
                
            } uniqueAttributeIndexes = a;
        }
        
        // Now, it's time to collect the vertex attributes that we're really interested in
        vertexAttributeCount = [uniqueAttributeIndexes count];
        vertexAttributes = calloc([uniqueAttributeIndexes count], sizeof(REWavefrontVertexAttributes));
        
        // Key: attribute indexes (array), value: element index (nsnumber)
        NSMutableDictionary *elementIndicesByAttributeIndexes = [NSMutableDictionary dictionary];
        
        // Loop through all unique attribute indexes
        for (int i = 0; i < [uniqueAttributeIndexes count]; i++) {
            
            NSArray *attributeIndexes = [[uniqueAttributeIndexes objectAtIndex:i] componentsSeparatedByString:@"/"]; 
            
            NSString *attributeIndexesKey = [uniqueAttributeIndexes objectAtIndex:i];
            //NSString *attributeIndexes = [uniqueAttributeIndexes objectAtIndex:i];
            
          //  NSArray *attributeIndexes = [uniqueAttributeIndexes objectAtIndex:i];
            
            NSNumber *elementIndex = [elementIndicesByAttributeIndexes objectForKey:attributeIndexesKey]; // Value
            
            // If nil, poulate
            if (elementIndex == nil) {
                elementIndex = [NSNumber numberWithInt:[elementIndicesByAttributeIndexes count]];
                [elementIndicesByAttributeIndexes setObject:elementIndex forKey:attributeIndexesKey];
                
                NSString *vIndexString = [attributeIndexes objectAtIndex:0]; // Required
                NSString *vtIndexString = [attributeIndexes count] > 1 ? [attributeIndexes objectAtIndex:1] : nil; // Optional
                NSString *vnIndexString = [attributeIndexes count] > 2 ? [attributeIndexes objectAtIndex:2] : nil; // Optional
                
                // These may be empty and should then be threated as nil
                if ([vtIndexString length] < 1) vtIndexString = nil;
                if ([vnIndexString length] < 1) vnIndexString = nil;
                
                // Find the vertex attributes that we're setting
                REWavefrontVertexAttributes *vertexAttribute = &(vertexAttributes[[elementIndex intValue]]);
                
                // Populate element with correct data
                if (vIndexString) (*vertexAttribute).vertex = vertices[[vIndexString intValue] - 1];
                if (vtIndexString) (*vertexAttribute).texCoord = vertexTexCoords[[vtIndexString intValue] - 1];
                if (vnIndexString) (*vertexAttribute).normal = vertexNormals[[vnIndexString intValue] - 1];
            }
            
            // Set element indices
            //elementIndices[i] = [elementIndex intValue];
        }
        
        // We can now free temporary data
        free(vertices);
        free(vertexNormals);
        free(vertexTexCoords);
        
        
        
        // UP TO HERE, WE*VE JUST CREATED ELEMENTCOMPONETS AND POPULATED ATTRIBUTES. IT SHOULD BE NEEDED TO CHANGE THIS MUCH.
        // BELOW HERE, IT'S FLEXIBLE HOW TO ORGANIZE THE DATA.
        
        
        
        // Find groups, from above
        groups = (NSMutableArray*)[[elementComponentsByGroup allKeys] retain];
        
        
        
        // Create and populate elements
        elementIndexCount = [elementComponents count]; // Element index count is total number of element components
        elementIndices = calloc([elementComponents count], sizeof(GLushort));
        
        // Total bounding box
        //CC3BoundingBox boundingBox = CC3BoundingBoxMake(1000000, 1000000, 100000, -1000000, -1000000, -100000);
        
        allElements = [[REWavefrontElementSet alloc] init];
        
        // TOTAL (element data and total element set)
        //NSMutableDictionary *elementArrayIndexByElementIndex = [NSMutableDictionary dictionary];

        for (int i = 0; i < [elementComponents count]; i++) {
            
            
            REWavefrontElementComponent *elementComponent = [elementComponents objectAtIndex:i];
            NSString *attributeIndexes = elementComponent.attributeIndexes;
            NSNumber *elementIndex = [elementIndicesByAttributeIndexes objectForKey:attributeIndexes]; // Value   
            
            elementIndices[i] = [elementIndex intValue];
            
            //[elementArrayIndexByElementIndex setObject:[NSNumber numberWithInt:i] forKey:elementIndex];
            
            // Bounding box
            REWavefrontVertexAttributes attributes = vertexAttributes[[elementIndex intValue]];
            
            [allElements addIndex:i];
            [allElements extendBoundingBox:attributes.vertex];
        }
        
        
        
        // GROUPS
        elementsByGroup = [[NSMutableDictionary alloc] init];
        
        
        for (int i = 0; i < [elementComponents count]; i++) {
            
            
            REWavefrontElementComponent *elementComponent = [elementComponents objectAtIndex:i];
            
            NSString *attributeIndexes = elementComponent.attributeIndexes;
            NSNumber *elementIndex = [elementIndicesByAttributeIndexes objectForKey:attributeIndexes]; // Value
            
            REWavefrontVertexAttributes attributes = vertexAttributes[[elementIndex intValue]];
            
            // Loop through groups
            for (NSString *group in elementComponent.groups) {
                REWavefrontElementSet *elementSetForGroup = [elementsByGroup objectForKey:group];
                
                // Create element set for group if it doesn't exist
                if (!elementSetForGroup) {
                    elementSetForGroup = [[[REWavefrontElementSet alloc] init] autorelease];
                    [elementsByGroup setObject:elementSetForGroup forKey:group];
                }
                
                // Add index f
                [elementSetForGroup addIndex:i];
                [elementSetForGroup extendBoundingBox:attributes.vertex];
            }
        }
        

        // Calculate consistent tangents. Method from:
        // Lengyel, Eric. “Computing Tangent Space Basis Vectors for an Arbitrary Mesh”. Terathon Software 3D Graphics Library, 2001. http://www.terathon.com/code/tangent.html
               
        CC3Vector *tan1 = malloc(sizeof(CC3Vector) * vertexCount);
        //CC3Vector *tan2 = tan1 + vertexCount;
        memset(tan1, 0, sizeof(CC3Vector) * vertexCount);
        
        for (long a = 0; a < elementIndexCount; a += 3) {
            
            long i1 = elementIndices[a + 0];
            long i2 = elementIndices[a + 1];
            long i3 = elementIndices[a + 2];
            
            CC3Vector v1 = vertexAttributes[i1].vertex;
            CC3Vector v2 = vertexAttributes[i2].vertex;
            CC3Vector v3 = vertexAttributes[i3].vertex;
            
            CC3Vector w1 = vertexAttributes[i1].texCoord;
            CC3Vector w2 = vertexAttributes[i2].texCoord;
            CC3Vector w3 = vertexAttributes[i3].texCoord;
            
            float x1 = v2.x - v1.x;
            float x2 = v3.x - v1.x;
            float y1 = v2.y - v1.y;
            float y2 = v3.y - v1.y;
            float z1 = v2.z - v1.z;
            float z2 = v3.z - v1.z;
            
            float s1 = w2.x - w1.x;
            float s2 = w3.x - w1.x;
            float t1 = w2.y - w1.y;
            float t2 = w3.y - w1.y;
            
            float r = 1.0f / (s1 * t2 - s2 * t1);
            CC3Vector sdir = CC3VectorMake((t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r,
                          (t2 * z1 - t1 * z2) * r);
            
            tan1[i1] = CC3VectorAdd(tan1[i1], sdir);
            tan1[i2] = CC3VectorAdd(tan1[i2], sdir);
            tan1[i3] = CC3VectorAdd(tan1[i3], sdir);            
        }
        
        for (long a = 0; a < vertexAttributeCount; a++) {
            CC3Vector n = vertexAttributes[a].normal;
            CC3Vector t = tan1[a];
            
            vertexAttributes[a].tangent = CC3VectorNormalize(CC3VectorDifference(t, CC3VectorScaleUniform(n,CC3VectorDot(n, t))));

        }
        
        free(tan1);
            

    } return self;
}

- (void)dealloc {

    if (vertexAttributes) free(vertexAttributes);
    if (elementIndices) free(elementIndices);
    
    [allElements release];
    [elementsByGroup release];
    
    [vertexAttributeBuffer release];
    [elementIndexBuffer release];
    [groups release];
    [super dealloc];
}

#pragma mark - Coding

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        vertexAttributeCount = [coder decodeIntForKey:@"vertexAttributeCount"];
        vertexAttributes = calloc(vertexAttributeCount, sizeof(REWavefrontVertexAttributes));
        memcpy(vertexAttributes, [coder decodeBytesForKey:@"vertexAttributes" returnedLength:nil], vertexAttributeCount * sizeof(REWavefrontVertexAttributes));
        
        elementIndexCount = [coder decodeIntForKey:@"elementIndexCount"];
        elementIndices = calloc(elementIndexCount, sizeof(GLshort));
        memcpy(elementIndices, [coder decodeBytesForKey:@"elementIndices" returnedLength:nil], elementIndexCount * sizeof(GLshort));
        
        allElements = [[coder decodeObjectForKey:@"allElements"] retain];
        elementsByGroup = [[coder decodeObjectForKey:@"elementsByGroup"] retain];
        hasNormals = [coder decodeBoolForKey:@"hasNormals"];
        hasTexCoords = [coder decodeBoolForKey:@"hasTexCoords"];
        groups = [[coder decodeObjectForKey:@"groups"] retain];
    } return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeBytes:(void*)vertexAttributes length:vertexAttributeCount * sizeof(REWavefrontVertexAttributes) forKey:@"vertexAttributes"];
    [coder encodeInt:vertexAttributeCount forKey:@"vertexAttributeCount"];
    
    [coder encodeBytes:(void*)elementIndices length:elementIndexCount * sizeof(GLshort) forKey:@"elementIndices"];
    [coder encodeInt:elementIndexCount forKey:@"elementIndexCount"];
    
    [coder encodeObject:allElements forKey:@"allElements"];
    [coder encodeObject:elementsByGroup forKey:@"elementsByGroup"];
    
    [coder encodeBool:hasNormals forKey:@"hasNormals"];
    [coder encodeBool:hasTexCoords forKey:@"hasTexCoords"];
    
    [coder encodeObject:groups forKey:@"groups"];
}


#pragma mark - Getters

- (REWavefrontVertexAttributes*)vertexAttributes {
    return vertexAttributes;
}

- (uint)vertexAttributeCount {
    return vertexAttributeCount;
}

- (REWavefrontElementSet*)allElements {
    return allElements;
}

- (REWavefrontElementSet*)elementsForGroup:(NSString*)group {
    return [elementsByGroup objectForKey:group];
}

#pragma mark - Buffers

- (void)createBuffers {
    if (!vertexAttributeBuffer && !elementIndexBuffer) {
        vertexAttributeBuffer = [[REBuffer alloc] initWithTarget:GL_ARRAY_BUFFER data:vertexAttributes length:sizeof(REWavefrontVertexAttributes) * vertexAttributeCount];
        
        elementIndexBuffer = [[REBuffer alloc] initWithTarget:GL_ELEMENT_ARRAY_BUFFER data:elementIndices length:sizeof(GLshort) * elementIndexCount];
    }
}

- (void)deleteBuffers {
    [vertexAttributeBuffer release];
    vertexAttributeBuffer = nil;
    [elementIndexBuffer release];
    elementIndexBuffer = nil;
}

- (BOOL)hasBuffers {
    return vertexAttributeBuffer && elementIndexBuffer;
}
- (void)bindBuffers {
    [vertexAttributeBuffer bind];
    [elementIndexBuffer bind];
}


@end
