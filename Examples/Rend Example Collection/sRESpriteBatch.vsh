

attribute mediump float a_batchUnit; // batch index may be bad name? it's actually kind of sub-batchindex or "group". maybe should be called batchunit/element

uniform mat4 u_mvMatrix[24]; // Variable mv matrix
uniform mat4 u_pMatrix; 
uniform vec4 u_multiplyColor[24]; // Variable multiply color matrix


attribute highp vec4 a_position; 
attribute mediump vec2 a_texCoord;

varying mediump vec2 v_texCoord;
varying lowp vec4 v_multiplyColor;

void main() {
    
    int batchUnit = int(a_batchUnit);
    
    v_multiplyColor = u_multiplyColor[batchUnit];
    
    v_texCoord = a_texCoord;
    gl_Position = u_pMatrix * u_mvMatrix[batchUnit] * a_position;
}