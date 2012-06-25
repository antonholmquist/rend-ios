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

struct DirectionalLight {
    vec3 direction;
    vec3 halfplane;
    vec4 ambientColor;
    vec4 diffuseColor;
    vec4 specularColor;
};

struct Material {
    vec4 ambientFactor;
    vec4 diffuseFactor;
    vec4 specularFactor;
    float shininess;
};

// Light
uniform DirectionalLight u_directionalLight;

// Material
uniform Material u_material;

// Matrices
uniform mat4 u_mvMatrix;
uniform mat4 u_mvpMatrix;

// Attributes
attribute vec4 a_position; 
attribute vec3 a_normal;

// Varyings
varying vec4 v_light;

void main() {
    
    // Define position and normal in model coordinates
    vec4 mcPosition = a_position;
    vec3 mcNormal = a_normal;
    
    // Calculate and normalize eye space normal
    vec3 ecNormal = vec3(u_mvMatrix * vec4(mcNormal, 0.0));
    ecNormal = ecNormal / length(ecNormal);
    
    // Do light calculations
    float ecNormalDotLightDirection = max(0.0, dot(ecNormal, u_directionalLight.direction));
    float ecNormalDotLightHalfplane = max(0.0, dot(ecNormal, u_directionalLight.halfplane));
    
    // Ambient light
    vec4 ambientLight = u_directionalLight.ambientColor * u_material.ambientFactor;
    
    // Diffuse light
    vec4 diffuseLight = ecNormalDotLightDirection * u_directionalLight.diffuseColor * u_material.diffuseFactor;
    
    // Specular light
    vec4 specularLight = vec4(0.0);
    if (ecNormalDotLightHalfplane > 0.0) {
        specularLight = pow(ecNormalDotLightHalfplane, u_material.shininess) * u_directionalLight.specularColor * u_material.specularFactor;
    } 
    
    v_light = ambientLight + diffuseLight + specularLight;
    gl_Position = u_mvpMatrix * mcPosition;    
    
}


