//
//  sFragmentLighting.vsh
//
//  Created by Anton Holmquist
//  Copyright 2012 Anton Holmquist. All rights reserved.
// 
//  http://antonholmquist.com
//  http://twitter.com/antonholmquist
//
//  http://github.com/antonholmquist/opengl-es-2-0-shaders
//

precision highp float;

// Matrices
uniform mat4 u_mvMatrix;
uniform mat4 u_mvpMatrix;

// Attributes
attribute vec4 a_position; 
attribute vec3 a_normal;

// Varyings
varying vec3 v_ecNormal;

void main() {
    
    // Define position and normal in model coordinates
    vec4 mcPosition = a_position;
    vec3 mcNormal = a_normal;
    
    // Calculate and normalize eye space normal
    vec3 ecNormal = vec3(u_mvMatrix * vec4(mcNormal, 0.0));
    ecNormal = ecNormal / length(ecNormal);
    v_ecNormal = ecNormal;
    
    gl_Position = u_mvpMatrix * mcPosition;    
    
}


