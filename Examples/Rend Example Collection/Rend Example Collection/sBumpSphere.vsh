
uniform mat4 u_mvpMatrix;
uniform mat4 u_mvMatrix;

attribute vec3 a_position; 
attribute vec2 a_texCoord;
attribute vec3 a_bumpAxisX; 
attribute vec3 a_bumpAxisY; 

varying vec2 v_texCoord;
varying vec3 v_normal;
varying vec3 v_bumpAxisX;
varying vec3 v_bumpAxisY;


void main() {
    v_texCoord = a_texCoord;
    v_bumpAxisX = (u_mvMatrix * vec4(a_bumpAxisX, 0)).xyz;
    v_bumpAxisY = (u_mvMatrix * vec4(a_bumpAxisY, 0)).xyz;
    v_normal = (u_mvMatrix * vec4(a_position, 0)).xyz;
    gl_Position = u_mvpMatrix * vec4(a_position, 1);
}