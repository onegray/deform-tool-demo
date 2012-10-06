//
//  Shader.fsh
//
//  Created by Sergey Nikitenko on 2/20/11.
//  Copyright (c) 2011 Sergey Nikitenk. All rights reserved.
//  Hire me at odesk! ( www.odesk.com/users/~~1bd7ccce67734b51 )
//

varying lowp vec2 varTexCoord;
uniform sampler2D texture;

void main()
{
	if(varTexCoord.x > 0.5) 
	{
		lowp float dx = 0.0;
		lowp float dy = -0.1;
		
		gl_FragColor = vec4(dx, -dx, dy, -dy);
	}
	else
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	}
}








