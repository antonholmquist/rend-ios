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

#import "REKeyframedMeshNode.h"
#import "REMaterial.h"
#import "RELight.h"

// This has to correspond to shader
#define kShaderMaxDirectionalLights 2

@implementation REKeyframedMeshNode

@synthesize wavefrontMeshA = wavefrontMeshA_;
@synthesize wavefrontMeshB = wavefrontMeshB_;
@synthesize meshTween, texture;
@synthesize material = material_;
@synthesize environmentMap = environmentMap_;
@synthesize environmentMixRatio = environmentMixRatio_;
@synthesize normalMap = normalMap_;

- (id)init {
    return [self initWithDefaultMesh:nil];
}

- (id)initWithDefaultMesh:(REWavefrontMesh*)mesh {
    if ((self = [super init])) {
        // Set bounding box from default mesh
        self.boundingBox = [mesh allElements].boundingBox; 
        
        // Set anchor coordinate to center of bounding box.
        self.anchorCoordinate = CC3BoundingBoxCenter(self.boundingBox);
        
        
       // NSLog(@"%f, %f, %f -> %f, %f, %f", boundingBox.minimum.x, boundingBox.minimum.y, boundingBox.minimum.z, boundingBox.maximum.x, boundingBox.maximum.y, boundingBox.maximum.z);
        
        
        environmentMixRatio_ = 0.5;
        
        material_ = [[REMaterial alloc] init];
        
        self.cullFaceEnabled = [NSNumber numberWithBool:YES];
        
        self.wavefrontMeshA = mesh;
        self.wavefrontMeshB = mesh;
        
    } return self;
}

- (void)dealloc {
    [wavefrontMeshA_ release];
    [wavefrontMeshB_ release];
    [texture release];
    [material_ release];
    [environmentMap_ release];
    [normalMap_ release];
    [super dealloc];
}

- (void)setWavefrontMeshA:(REWavefrontMesh *)wavefrontMeshA {
    [wavefrontMeshA_ release];
    wavefrontMeshA_ = [wavefrontMeshA retain];
}
 

- (void)setWavefrontMeshB:(REWavefrontMesh *)wavefrontMeshB {
    [wavefrontMeshB_ release];
    wavefrontMeshB_ = [wavefrontMeshB retain];
}

+ (REProgram*)program {
    //return [REProgram programWithVertexFilename:@"sREKeyframedMesh.vsh" fragmentFilename:@"sREKeyframedMesh.fsh"];
    
    REProgram *p = nil;
    
    if (NO) {
        p = [REProgram programWithVertexFilename:@"sREKeyframedMeshFragment.vsh" fragmentFilename:@"sREKeyframedMeshFragment.fsh"];
    } else {
        p = [REProgram programWithVertexFilename:@"sREKeyframedMesh.vsh" fragmentFilename:@"sREKeyframedMesh.fsh"];
    }
    
    return p;
    
}

- (BOOL)shouldCullTest {
    return YES;
}

// Overrides draw to set own array of mv/p-matrices
- (void)draw {
    
    [super draw];
    
    //NSLog(@"canCull: %d", canCull);
    
    // SHARED DATA
    REProgram *p = self.program;
    
    // World
    REWorld *world = self.world;
    
    NSArray *directionalLights = [world lightsOfClass:[REDirectionalLight class]];
    
    
    /*
    GLint u_materialPropertiesAmbientColor = 
    GLint u_materialPropertiesDiffuseColor = [p uniformLocation:@"u_materialProperties.diffuseColor"];
    GLint u_materialPropertiesSpecularColor = [p uniformLocation:@"u_materialProperties.specularColor"];
    GLint u_materialPropertiesSpecularExponent = [p uniformLocation:@"u_materialProperties.specularExponent"];
    
    float ambientFactor = 0.14;
    float diffuseFactor = 0.5;
    float specularFactor = 0.3;
     */
    
    glUniform4f([p uniformLocation:@"u_material.ambientFactor"], material_.ambient.x, material_.ambient.y, material_.ambient.z, material_.ambient.w);
    glUniform4f([p uniformLocation:@"u_material.diffuseFactor"], material_.diffuse.x, material_.diffuse.y, material_.diffuse.z, material_.diffuse.w);
    glUniform4f([p uniformLocation:@"u_material.specularFactor"], material_.specular.x, material_.specular.y, material_.specular.z, material_.specular.w);
    glUniform1f([p uniformLocation:@"u_material.shininess"], material_.shininess);
    
    
    int directionalLightCount = [directionalLights count] > kShaderMaxDirectionalLights ? kShaderMaxDirectionalLights : [directionalLights count];
    glUniform1f([p uniformLocation:@"u_directionalLightCount"], directionalLightCount);
    
    glUniform1f([p uniformLocation:@"u_alpha"], [self.alpha floatValue]);
    
    
    // Populate lights
    for (int i = 0; i < directionalLightCount; i++) {
//        NSLog(@"LIGHT COUNT: %d",i);
        REDirectionalLight *light = [directionalLights objectAtIndex:i];
        
        NSString *uniformDirection = nil;
        NSString *uniformHalfplane = nil;
        NSString *uniformAmbientColor = nil;
        NSString *uniformDiffuseColor = nil;
        NSString *uniformSpecularColor = nil;
        
        // Avoid generating strings dynamically for speed reasons. Can make a big difference (like 20% of total execution time).
        if (i == 0) {
            uniformDirection = @"u_directionalLight.direction";
            uniformHalfplane = @"u_directionalLight.halfplane";
            uniformAmbientColor = @"u_directionalLight.ambientColor";
            uniformDiffuseColor = @"u_directionalLight.diffuseColor";
            uniformSpecularColor = @"u_directionalLight.specularColor";
        }
        
        if (i == 1) {
            uniformDirection = @"u_directionalLight1.direction";
            uniformHalfplane = @"u_directionalLight1.halfplane";
            uniformAmbientColor = @"u_directionalLight1.ambientColor";
            uniformDiffuseColor = @"u_directionalLight1.diffuseColor";
            uniformSpecularColor = @"u_directionalLight1.specularColor";
        }
        
        // Creating strings dynamically, seems to be potentially _very_ slow. ex:
        // NSString *s = [NSString stringWithFormat:@"u_directionalLight%d.", i];
        // [s stringByAppendingFormat:@"direction"]
        GLint u_directionalLightDirection = [p uniformLocation:uniformDirection];
        GLint u_directionalLightHalfplane = [p uniformLocation:uniformHalfplane];
        GLint u_directionalLightAmbientColor = [p uniformLocation:uniformAmbientColor];
        GLint u_directionalLightDiffuseColor = [p uniformLocation:uniformDiffuseColor];
        GLint u_directionalLightSpecularColor = [p uniformLocation:uniformSpecularColor];
        
        
        
        /*
        NSString *s = [NSString stringWithFormat:@"u_directionalLight%d.", i];
        
        GLint u_directionalLightDirection = [p uniformLocation:[s stringByAppendingFormat:@"direction"]];
        GLint u_directionalLightHalfplane = [p uniformLocation:[s stringByAppendingFormat:@"halfplane"]];
        GLint u_directionalLightAmbientColor = [p uniformLocation:[s stringByAppendingFormat:@"ambientColor"]];
        GLint u_directionalLightDiffuseColor = [p uniformLocation:[s stringByAppendingFormat:@"diffuseColor"]];
        GLint u_directionalLightSpecularColor = [p uniformLocation:[s stringByAppendingFormat:@"specularColor"]];
         */
        
        
        //CC3Vector halfplane = CC3VectorNormalize(CC3VectorAdd(CC3VectorNegate(CC3VectorNormalize(light.direction)), CC3VectorMake(0, 0, 1)));
        
        CC3Vector halfplane = CC3VectorNormalize(CC3VectorAdd(CC3VectorNormalize(light.position), CC3VectorMake(0, 0, 1)));
        
        //halfplane = kCC3VectorZero;
        
        
        //glUniform3f(u_directionalLightDirection, light.direction.x, light.direction.y, light.direction.z);
        
        
        
        // We're sending position to direction. This is from OpenGL ES 2.0 programming guide p.161. This
        // seem to be valid because light (and viewer) is at infinity. position.x = 0; And they don't negate it.
        CC3Vector normalizedDirection = CC3VectorNormalize(light.direction);
        glUniform3f(u_directionalLightDirection, normalizedDirection.x, normalizedDirection.y, normalizedDirection.z);
        glUniform3f(u_directionalLightHalfplane, halfplane.x, halfplane.y, halfplane.z);
        
       // glUniform3f(u_directionalLightHalfplane, 1, 1, 1);
        glUniform4f(u_directionalLightAmbientColor, light.ambientColor.x, light.ambientColor.y, light.ambientColor.z, light.ambientColor.w);
        glUniform4f(u_directionalLightDiffuseColor, light.diffuseColor.x, light.diffuseColor.y, light.diffuseColor.z, light.diffuseColor.w);
        glUniform4f(u_directionalLightSpecularColor, light.specularColor.x, light.specularColor.y, light.specularColor.z, light.specularColor.w);
    }
    
    glUniform1f([p uniformLocation:@"u_tween"], meshTween);
    glUniform1f([p uniformLocation:@"u_environmentMixRatio"], environmentMap_ ? environmentMixRatio_ : 0.0);
    
    // Bind texture and environment map
    glUniform1i([p uniformLocation:@"s_texture"], 0);
    glUniform1i([p uniformLocation:@"s_environment"], 1);
    glUniform1i([p uniformLocation:@"s_normalMap"], 2);
    [texture bind:GL_TEXTURE0];
    [environmentMap_ bind:GL_TEXTURE1];
    [normalMap_ bind:GL_TEXTURE2];
    
    
    RECamera *cam = self.camera;    
    glUniform3f([p uniformLocation:@"u_eyePosition"], cam.position.x, cam.position.y, cam.position.z);
    
    
    REWavefrontVertexAttributes *attributesA = wavefrontMeshA_.vertexAttributes;
    REWavefrontVertexAttributes *attributesB = wavefrontMeshB_.vertexAttributes;
 
    [REBuffer unbind];
    
    if ([wavefrontMeshA_ hasBuffers]) 
        [wavefrontMeshA_ bindBuffers];
    
    GLint a_positionA = [p attribLocation:@"a_position"];
    GLint a_positionB = [p attribLocation:@"a_positionB"];
    GLint a_normalA = [p attribLocation:@"a_normal"];
    GLint a_normalB = [p attribLocation:@"a_normalB"];
    GLint a_texCoord = [p attribLocation:@"a_texCoord"];
    
    // Disable just for safety
    glDisableVertexAttribArray(0);
    glDisableVertexAttribArray(1);
    glDisableVertexAttribArray(2);
    glDisableVertexAttribArray(3);
    glDisableVertexAttribArray(4);
    
    glVertexAttribPointer(a_positionA, 3, GL_FLOAT, GL_FALSE, sizeof(REWavefrontVertexAttributes), (void*)([wavefrontMeshA_ hasBuffers] ? 0 : attributesA) + offsetof(REWavefrontVertexAttributes, vertex));
    glEnableVertexAttribArray(a_positionA);
    
    if (a_normalA >= 0) {
        glVertexAttribPointer(a_normalA, 3, GL_FLOAT, GL_FALSE, sizeof(REWavefrontVertexAttributes), (void*)([wavefrontMeshA_ hasBuffers] ? 0 : attributesA) + offsetof(REWavefrontVertexAttributes, normal));
        glEnableVertexAttribArray(a_normalA); 
    }
    
    if (a_texCoord >= 0) {
        glVertexAttribPointer(a_texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(REWavefrontVertexAttributes), (void*)([wavefrontMeshA_ hasBuffers] ? 0 : attributesA) + offsetof(REWavefrontVertexAttributes, texCoord));
        glEnableVertexAttribArray(a_texCoord); 
    }
    
    
    if ([wavefrontMeshB_ hasBuffers]) 
        [wavefrontMeshB_ bindBuffers];
    
     if (a_positionB >= 0) {
         glVertexAttribPointer(a_positionB, 3, GL_FLOAT, GL_FALSE, sizeof(REWavefrontVertexAttributes), (void*)([wavefrontMeshB_ hasBuffers] ? 0 : attributesB) + offsetof(REWavefrontVertexAttributes, vertex));
         glEnableVertexAttribArray(a_positionB); 
     }
    
    if (a_normalB >= 0) {
        glVertexAttribPointer(a_normalB, 3, GL_FLOAT, GL_FALSE, sizeof(REWavefrontVertexAttributes), (void*)([wavefrontMeshB_ hasBuffers] ? 0 : attributesB) + offsetof(REWavefrontVertexAttributes, normal));
        glEnableVertexAttribArray(a_normalB); 
    }
    
    
    glDrawElements(GL_TRIANGLES, wavefrontMeshA_.elementIndexCount, GL_UNSIGNED_SHORT, 0);
    
}



@end
