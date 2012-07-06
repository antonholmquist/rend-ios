

precision mediump float;

uniform sampler2D s_texture; 
uniform vec4 u_multiplyColor;

varying vec2 v_texCoord;

void main() { 
    vec4 pixelColor = texture2D(s_texture, v_texCoord);
    
    pixelColor = pixelColor * u_multiplyColor;

    gl_FragColor = pixelColor; 
}
