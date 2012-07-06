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

#import "RENode.h"

@class REWavefrontMesh;
@class RETexture2D;
@class RETextureCubeMap;
@class REMaterial;

/*
 Mesh node that is specialized to use with keyframe animations, since it has the ability to tween vertex positions and normals.
 
 Works very tightly with REWavefrontMesh. Associated actions also works very closely with this.
 
 Responsibility: Draw specified wavefrontMesh, with additional tween.
 Animations are responsible for setting the meshes and tween
 */

@interface REKeyframedMeshNode : RENode {
    REWavefrontMesh *wavefrontMeshA_;
    REWavefrontMesh *wavefrontMeshB_;
    
    float meshTween;
    
    RETexture2D *texture;
    REMaterial *material_;
    
    RETextureCubeMap *environmentMap_;
    float environmentMixRatio_;
    
    RETexture2D *normalMap_;
}

@property (nonatomic, retain) REWavefrontMesh *wavefrontMeshA; 
@property (nonatomic, retain) REWavefrontMesh *wavefrontMeshB; // Used for keyframe animation

@property (nonatomic, assign) float meshTween;

@property (nonatomic, retain) RETexture2D *texture;
@property (nonatomic, retain) RETexture2D *normalMap; // Converted bump map
@property (nonatomic, retain) REMaterial *material; 

// Set this to use environment mapping
@property (nonatomic, retain) RETextureCubeMap *environmentMap;

// How much of the environment that is blended onto the object [0,1]
@property (nonatomic, assign) float environmentMixRatio; 

// The default mesh sets bounding box and anchor coordinate.
- (id)initWithDefaultMesh:(REWavefrontMesh*)mesh;


@end
