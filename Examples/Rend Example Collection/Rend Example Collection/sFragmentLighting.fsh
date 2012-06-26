//
//  sFragmentLighting.fsh
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

varying vec3 v_ecNormal;

void main() { 
    
    
    // Normalize v_ecNormal
    vec3 ecNormal = v_ecNormal / length(v_ecNormal);
    
    float ecNormalDotLightDirection = max(0.0, dot(ecNormal, u_directionalLight.direction));
    float ecNormalDotLightHalfplane = max(0.0, dot(ecNormal, u_directionalLight.halfplane));
    
    // Calculate ambient light
    vec4 ambientLight = u_directionalLight.ambientColor * u_material.ambientFactor;
    
    // Calculate diffuse light
    vec4 diffuseLight = ecNormalDotLightDirection * u_directionalLight.diffuseColor * u_material.diffuseFactor;
    
    // Calculate specular light
    vec4 specularLight = vec4(0.0);
    if (ecNormalDotLightHalfplane > 0.0) {
        specularLight = pow(ecNormalDotLightHalfplane, u_material.shininess) * u_directionalLight.specularColor * u_material.specularFactor;
    } 
    
    vec4 light = ambientLight + diffuseLight + specularLight;
    
    gl_FragColor = light;
}
