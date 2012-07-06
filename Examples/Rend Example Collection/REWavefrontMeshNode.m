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

#import "REWavefrontMeshNode.h"
#import "REWavefrontMeshGroupNode.h"
#import "REWavefrontMeshElementIndexBatch.h"
#import "REWavefrontMesh.h"

@implementation REWavefrontMeshNode

static const int groupsInEachBatch = 24; // number of groups to batch. Needs to correspond to shader value.

@synthesize groupNodes, texture, wavefrontMesh;

- (id)initWithWavefrontMesh:(REWavefrontMesh*)m {
    if ((self = [super init])) {
        wavefrontMesh = [m retain];
        groupNodes = [[NSMutableDictionary alloc] init];
        
        vertexArrayObjects = [[NSMutableArray alloc] init];
        
        self.boundingBox = [wavefrontMesh allElements].boundingBox;
        self.anchorCoordinate = CC3BoundingBoxCenter(self.boundingBox);
        
        for (NSString *group in wavefrontMesh.groups) {
            REWavefrontMeshGroupNode *groupNode = [[[REWavefrontMeshGroupNode alloc] initWithWavefrontMesh:wavefrontMesh group:group] autorelease];
            [groupNodes setObject:groupNode forKey:group];
            
            [self addChild:groupNode];
        }
        
        
        // Create index batches
        indexBatches = [[NSMutableArray alloc] init];
        
        for (int batchIndex = 0; batchIndex <= [wavefrontMesh.groups count] / groupsInEachBatch; batchIndex++) {
            
            NSMutableArray *elementSetsInBatch = [NSMutableArray array];
            // Loop through groups in batch
            for (int groupIndex = 0; groupIndex < groupsInEachBatch; groupIndex++) {
                int totalGroupIndex = batchIndex * groupsInEachBatch + groupIndex;
                
                if (totalGroupIndex >= [wavefrontMesh.groups count]) {
                    break; // If we're here, we're done.
                }
                
                NSString *group = [wavefrontMesh.groups objectAtIndex:totalGroupIndex];
                [elementSetsInBatch addObject:[wavefrontMesh elementsForGroup:group]];
            }
            
            
            REWavefrontMeshElementIndexBatch *indexBatch = [[[REWavefrontMeshElementIndexBatch alloc] initWithElementSets:elementSetsInBatch indices:wavefrontMesh.elementIndices] autorelease];
            [indexBatch createElementIndexBuffer];
            [indexBatch createBatchIndexAttributeBuffer];
            [indexBatches addObject:indexBatch];
            

        }
        
    } return self;
}

- (void)dealloc {
    [texture release];
    [groupNodes release];
    [wavefrontMesh release];
    [indexBatches release];
    [vertexArrayObjects release];
    [super dealloc];
}

- (void)setTexture:(RETexture2D *)t {
    [texture release];
    texture = [t retain];
    
    for (REWavefrontMeshGroupNode *groupNode in [groupNodes allValues]) {
        groupNode.texture = texture;
    }
}

+ (REProgram*)program {
    return [REProgram programWithVertexFilename:@"sREWavefrontMeshGroup.vsh" fragmentFilename:@"sREWavefrontMeshGroup.fsh"];
}

// Overrides draw to set own array of mv/p-matrices
- (void)draw {
    
    
    
    [[REGLStateManager sharedManager] setBlendEnabled:[self.blendEnabled boolValue]];
    
    // Use the default program if we have any (we also need camera)
    //glUseProgram(program.program);
    [[REGLStateManager sharedManager] setCurrentProgram:program.program];
    
    
    // SHARED DATA
    REProgram *p = self.program;
    
    GLint a_position = [p attribLocation:@"a_position"];
    GLint u_eyePosition = [p uniformLocation:@"u_eyePosition"];
    
    GLint a_texCoord = [p attribLocation:@"a_texCoord"];
    GLint a_normal = [p attribLocation:@"a_normal"];
    
    GLint s_texture = [p uniformLocation:@"s_texture"];
    
    GLint u_directional_light_direction = [p uniformLocation:@"u_directional_light.direction"];
    GLint u_directional_light_halfplane = [p uniformLocation:@"u_directional_light.halfplane"];
    GLint u_directional_light_ambient_color = [p uniformLocation:@"u_directional_light.ambient_color"];
    GLint u_directional_light_diffuse_color = [p uniformLocation:@"u_directional_light.diffuse_color"];
    GLint u_directional_light_specular_color = [p uniformLocation:@"u_directional_light.specular_color"];
    
    GLint u_material_properties_ambient_color = [p uniformLocation:@"u_material_properties.ambient_color"];
    GLint u_material_properties_diffuse_color = [p uniformLocation:@"u_material_properties.diffuse_color"];
    GLint u_material_properties_specular_color = [p uniformLocation:@"u_material_properties.specular_color"];
    GLint u_material_properties_specular_exponent = [p uniformLocation:@"u_material_properties.specular_exponent"];
    
    CC3Vector direction = CC3VectorMake(1,1,1);
    //CC3Vector halfplane = CC3VectorNormalize(CC3VectorAdd(direction, CC3VectorMake(0, 0, 1)));
    
     CC3Vector halfplane = CC3VectorNormalize(CC3VectorAdd(CC3VectorNegate(CC3VectorNormalize(direction)), CC3VectorMake(0, 0, 1)));
    
    glUniform3f(u_directional_light_direction, direction.x, direction.y, direction.z);
    glUniform3f(u_directional_light_halfplane, halfplane.x, halfplane.y, halfplane.z);
    
    // 107 186 247
    
    //glUniform4f(u_directional_light_ambient_color, 1, 1, 1, 1.0);
    glUniform4f(u_directional_light_ambient_color, 107 / 255.0, 186 / 255.0, 247 / 255.0, 1.0);
    glUniform4f(u_directional_light_diffuse_color, 1, 1, 1, 1.0);
    //glUniform4f(u_directional_light_diffuse_color, 107 / 255.0, 186 / 255.0, 247 / 255.0, 1.0);
    
    glUniform4f(u_directional_light_specular_color, 1, 1, 1, 0.5);
    
    
    
    //glUniform4f(u_directional_light_specular_color, 107 / 255.0, 186 / 255.0, 247 / 255.0, 1.0);
    
    float ambientFactor = 0.14;
    float diffuseFactor = 0.5;
    float specularFactor = 0.3;
    
    glUniform4f(u_material_properties_ambient_color, ambientFactor, ambientFactor, ambientFactor, 1.0);
    glUniform4f(u_material_properties_diffuse_color, diffuseFactor, diffuseFactor, diffuseFactor, 1.0);
    glUniform4f(u_material_properties_specular_color, specularFactor, specularFactor, specularFactor, 1.0);
    glUniform1f(u_material_properties_specular_exponent, 2);
    
    glUniform1i(s_texture, 0);
    [texture bind];
    
    
    
    NSArray *groups = wavefrontMesh.groups;
    
    RECamera *cam = self.camera;
    CC3GLMatrix *projectionMatrix = cam ? cam.projectionMatrix : [CC3GLMatrix identity];
    CC3GLMatrix *viewMatrix = cam ? cam.viewMatrix : [CC3GLMatrix identity];
    CC3GLMatrix *parentModelViewMatrix = [[viewMatrix copy] autorelease]; // Set modelview matrix based on self (and later child)
    [parentModelViewMatrix multiplyByMatrix:self.globalTransformMatrix];
    
    glUniformMatrix4fv([program uniformLocation:@"u_pMatrix"], 1, GL_FALSE, projectionMatrix.glMatrix);
    
    //glUniform3f(u_eyePosition, cam.position.x, cam.position.y, cam.position.z);
    
    //CC3Vector lookDirection = CC3VectorNormalize(cam.lookDirection);
    //CC3Vector lookDirection = kCC3VectorZero;
    glUniform3f(u_eyePosition, cam.position.x, cam.position.y, cam.position.z);
    
    REWorld *world = self.world;
    

    // Find first point light
    REPointLight *pointLight = nil; // First found point light
    for (RELight *light in world.lights) {
        if ([light isKindOfClass:[REPointLight class]]) {
            pointLight = (REPointLight*)light;
            break;
        }
    }
    
    // Set point light uniforms
    
    GLint u_point_light_zero_position;
    GLint u_point_light_zero_attenuation;
    GLint u_point_light_zero_ambient_color;
    
    GLint u_point_light_zero_diffuse_color;
    GLint u_point_light_zero_specular_color;
    GLint u_point_light_zero_specular_exponent;
    
    
    u_point_light_zero_position = [p uniformLocation:@"u_point_lights.position"];
    u_point_light_zero_attenuation = [p uniformLocation:@"u_point_lights.attenuation"];
    u_point_light_zero_ambient_color = [p uniformLocation:@"u_point_lights.ambient_color"];
    u_point_light_zero_diffuse_color = [p uniformLocation:@"u_point_lights.diffuse_color"];
    u_point_light_zero_specular_color = [p uniformLocation:@"u_point_lights.specular_color"];
    u_point_light_zero_specular_exponent = [p uniformLocation:@"u_point_lights.specular_exponent"];

    //NSLog(@"u_point_light_zero_position: %d", u_point_light_zero_position);
    //NSLog(@"u_point_light_zero_attenuation: %d", u_point_light_zero_attenuation);
    //NSLog(@"u_point_light_zero_ambient_color: %d", u_point_light_zero_ambient_color);
    
    // Set point light values
    
    // Point light position in eye coordinates
    CC3Vector ecPointLightPosition = [viewMatrix transformLocation:pointLight.position];
    
    //glUniform3f(u_point_light_zero_position, pointLight.position.x, pointLight.position.y, pointLight.position.z);
    glUniform3f(u_point_light_zero_position, ecPointLightPosition.x, ecPointLightPosition.y, ecPointLightPosition.z);
    glUniform3f(u_point_light_zero_attenuation, pointLight.attenuation.x, pointLight.attenuation.y, pointLight.attenuation.z);
    glUniform4f(u_point_light_zero_ambient_color, pointLight.ambientColor.x, pointLight.ambientColor.y, pointLight.ambientColor.z, pointLight.ambientColor.w);
    glUniform4f(u_point_light_zero_diffuse_color, pointLight.diffuseColor.x, pointLight.diffuseColor.y, pointLight.diffuseColor.z, pointLight.diffuseColor.w);
    glUniform4f(u_point_light_zero_specular_color, pointLight.specularColor.x, pointLight.specularColor.y, pointLight.specularColor.z, pointLight.specularColor.w);
   // glUniform1f(u_point_light_zero_specular_exponent, pointLight.specularExponent);
    
    // Loop through batches
    for (int batchIndex = 0; batchIndex <= [groups count] / groupsInEachBatch; batchIndex++) {
        
        GLfloat *modelViewMatrices = calloc(groupsInEachBatch, 16 * sizeof(GLfloat));

        int actualGroupsInBatch = 0;
        
        // Loop through groups in batch
        for (int groupIndex = 0; groupIndex < groupsInEachBatch; groupIndex++) {
            
            int totalGroupIndex = batchIndex * groupsInEachBatch + groupIndex;
            
            if (totalGroupIndex >= [groups count]) {
                break; // If we're here, we're done.
            } else {
                actualGroupsInBatch++;
            }
            
            NSString *group = [groups objectAtIndex:totalGroupIndex];
            REWavefrontMeshGroupNode *groupNode = [groupNodes objectForKey:group];
            
            
            //CC3GLMatrix *modelViewMatrix = [[parentModelViewMatrix copy] autorelease];
            
            [modelViewMatrix populateFrom:parentModelViewMatrix];
            [modelViewMatrix multiplyByMatrix:groupNode.transformMatrix]; // Add childs transform node
            
            memcpy(modelViewMatrices + 16 * groupIndex, modelViewMatrix.glMatrix, 16 * sizeof(GLfloat));
        }
        
    
        [REBuffer unbind];
        
        GLint u_mvMatrix = [program uniformLocation:@"u_mvMatrix"];
//#warning groupsInEachBatch may upload more than neccessary. Look for actual groups in batch instead.
        glUniformMatrix4fv(u_mvMatrix, groupsInEachBatch, GL_FALSE, modelViewMatrices); 

        REWavefrontMeshElementIndexBatch *indexBatch = [indexBatches objectAtIndex:batchIndex];
        
        
        // Create vertex array object
        REVertexArrayObject *vertexArrayObject = batchIndex < [vertexArrayObjects count] ? [vertexArrayObjects objectAtIndex:batchIndex] : nil;
        if (!vertexArrayObject) {
            vertexArrayObject = [[[REVertexArrayObject alloc] init] autorelease];
            [vertexArrayObjects addObject:vertexArrayObject];
            
            [vertexArrayObject bind];
            
            [indexBatch bindBatchIndexAttributeBuffer]; // Assume that we have it.
            GLint a_batchIndex = [p attribLocation:@"a_batchIndex"];
            glVertexAttribPointer(a_batchIndex, 1, GL_FLOAT, GL_FALSE, sizeof(GLfloat), 0);
            glEnableVertexAttribArray(a_batchIndex); // Will set to VAO
            //[[REGLStateManager sharedManager] setVertexAttribArray:a_batchIndex enabled:GL_TRUE];
            
            
            
            if ([wavefrontMesh hasBuffers]) {
                [wavefrontMesh bindBuffers];
            }
            
            //NSLog(@"hasbuffers: %d", [wavefrontMesh hasBuffers]);
            
            REWavefrontVertexAttributes *attributes = wavefrontMesh.vertexAttributes;
            
            glVertexAttribPointer(a_position, 3, GL_FLOAT, GL_FALSE, sizeof(REWavefrontVertexAttributes), (void*)([wavefrontMesh hasBuffers] ? 0 : attributes) + offsetof(REWavefrontVertexAttributes, vertex));
            glEnableVertexAttribArray(a_position); // Will set to VAO
            //[[REGLStateManager sharedManager] setVertexAttribArray:a_position enabled:GL_TRUE];
            
            glVertexAttribPointer(a_texCoord, 2, GL_FLOAT, GL_FALSE, sizeof(REWavefrontVertexAttributes), (void*)([wavefrontMesh hasBuffers] ? 0 : attributes) + offsetof(REWavefrontVertexAttributes, texCoord));
            glEnableVertexAttribArray(a_texCoord); // Will set to VAO
            //[[REGLStateManager sharedManager] setVertexAttribArray:a_texCoord enabled:GL_TRUE];
            
            glVertexAttribPointer(a_normal, 3, GL_FLOAT, GL_FALSE, sizeof(REWavefrontVertexAttributes), (void*)([wavefrontMesh hasBuffers] ? 0 : attributes) + offsetof(REWavefrontVertexAttributes, normal));
            glEnableVertexAttribArray(a_normal); // Will set to VAO
            //[[REGLStateManager sharedManager] setVertexAttribArray:a_normal enabled:GL_TRUE];
        }
        

        
        [vertexArrayObject bind];
        
        
        
        
        
        
        [indexBatch bindElementIndexBuffer];
        glDrawElements(GL_TRIANGLES, indexBatch.length, GL_UNSIGNED_SHORT, 0);

        free(modelViewMatrices);
    }

}

@end
