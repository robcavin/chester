//
//  Shader.fsh
//  Chester
//
//  Created by Rob on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;  // inputs from vertex shader
varying lowp vec2 vo_TexCoord0;   // inputs from vertex shader

uniform sampler2D Texture;

void main()
{
    gl_FragColor = texture2D(Texture, vo_TexCoord0); //colorVarying * texture2D(Texture, vo_TexCoord0);
}
