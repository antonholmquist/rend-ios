
precision highp float;

uniform sampler2D s_texture;
uniform sampler2D s_bumpMap;

uniform float u_shinyness;
uniform float u_specularLightBrightness;
uniform float u_bumpMapOffset;

varying vec2 v_texCoord;
varying vec3 v_normal;

varying vec3 v_bumpAxisX;
varying vec3 v_bumpAxisY;

void main() {
    vec4 pixelColor = texture2D(s_texture, v_texCoord);
    
    vec4 bumpOffset = -0.5 + texture2D(s_bumpMap, v_texCoord);
    vec3 normal = normalize(v_normal + u_bumpMapOffset * bumpOffset.x * normalize(v_bumpAxisX) + u_bumpMapOffset * bumpOffset.y * normalize(v_bumpAxisY));
    vec3 directionToLight = normalize(vec3(-1, 1, 1));
    vec3 directionToViewer = vec3(0, 0, 1);
    
    // Diffuse light
    float diffuseLight = max(dot(normal, directionToLight), 0.0);
    pixelColor.rgb = pixelColor.rgb * (0.3 + 0.7 * diffuseLight);
    
    // Specular light
    vec3 reflectanceDirection = normalize(2.0 * dot(normal, directionToLight) * normal - directionToLight);
    float sl = max(dot(reflectanceDirection, directionToViewer), 0.0);
    float specularLight = pow(sl, u_shinyness);
    pixelColor.rgb = pixelColor.rgb + u_specularLightBrightness * specularLight;
    
    gl_FragColor = pixelColor;
    
}
