//
//  Shader.vsh
//
//  Created by Sergey Nikitenko on 2/20/11.
//  Copyright (c) 2011 Sergey Nikitenk. All rights reserved.
//  Hire me at odesk! ( www.odesk.com/users/~~1bd7ccce67734b51 )
//

uniform mat4 modelViewProjectionMatrix;
attribute vec4 position;

void main()
{
    gl_Position = modelViewProjectionMatrix * position;
}
