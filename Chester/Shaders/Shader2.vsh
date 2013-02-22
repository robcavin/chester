//
//  Shader.vsh
//  Chester
//
//  Created by Rob on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

attribute vec4 position2;
attribute vec2 texcoord0;

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform vec2 textureOffset;

varying vec2 vo_TexCoord0;

void main()
{
    vec3 eyeNormal = vec3(0.0,0.0,1.0);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0);
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    colorVarying = diffuseColor * nDotVP;
    
    gl_Position = modelViewProjectionMatrix * position2;

    vo_TexCoord0 = texcoord0 + textureOffset;
}