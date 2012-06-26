
precision mediump float;

uniform sampler2D s_texture; // All sprites in batch use the same texture

varying mediump vec2 v_texCoord; 
varying lowp vec4 v_multiplyColor;

void main() { 
    //gl_FragColor = texture2D(s_texture, v_texCoord) * v_multiplyColor;
    
    // Multiply with multiply color, and then with alpha, to simulate that the alpha was premultiplied.
    gl_FragColor = texture2D(s_texture, v_texCoord) * v_multiplyColor * vec4(v_multiplyColor.a);
    
}

// More on premultiplied alpha:
// http://blog.rarepebble.com/111/premultiplied-alpha-in-opengl/
// http://home.comcast.net/~tom_forsyth/blog.wiki.html#%5B%5BPremultiplied%20alpha%5D%5D