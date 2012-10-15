//
//  Shader.fsh
//
//  Created by Sergey Nikitenko on 2/20/11.
//  Copyright (c) 2011 Sergey Nikitenk. All rights reserved.
//  Hire me at odesk! ( www.odesk.com/users/~~1bd7ccce67734b51 )
//

varying highp vec2 varTexCoord;
varying highp vec2 varBrushCoord;

uniform sampler2D meshTexture;
uniform sampler2D brushTexture;

uniform highp vec2 force;
uniform highp vec2 center;

void main()
{
	highp float deform_value = texture2D(brushTexture, varBrushCoord).r;
	highp vec2 nv = deform_value*force;

	highp vec2 v = texture2D(meshTexture, varTexCoord+nv).rg;
	v = v + nv;
	
	gl_FragColor = vec4(v.x, v.y, 0.0, 0.0);
	
}








