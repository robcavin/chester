//
//  Shader.fsh
//  Chester
//
//  Created by Rob on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
