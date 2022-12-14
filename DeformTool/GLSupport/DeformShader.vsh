//
//  Shader.vsh
//
//  Created by Sergey Nikitenko on 2/20/11.
//  Copyright (c) 2011 Sergey Nikitenk. All rights reserved.
//  Hire me at odesk! ( www.odesk.com/users/~~1bd7ccce67734b51 )
//

attribute vec4 position;
attribute vec2 texCoord;
attribute vec2 brushCoord;

varying vec2 varTexCoord;
varying vec2 varBrushCoord;
void main()
{
    varTexCoord = texCoord;
	varBrushCoord = brushCoord;
    gl_Position = position;
}
