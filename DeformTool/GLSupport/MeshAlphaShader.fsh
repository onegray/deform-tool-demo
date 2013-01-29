//
//  Shader.fsh
//
//  Created by Sergey Nikitenko on 2/20/11.
//  Copyright (c) 2011 Sergey Nikitenk. All rights reserved.
//  Hire me at odesk! ( www.odesk.com/users/~~1bd7ccce67734b51 )
//

varying lowp vec2 varTexCoord;
uniform sampler2D texture;
uniform sampler2D alpha;

void main()
{
	if(varTexCoord.x < 0.0 || varTexCoord.x > 1.0 || varTexCoord.y < 0.0 || varTexCoord.y > 1.0)
	{
		gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
	}
	else
	{
		lowp vec4 a = texture2D(alpha, varTexCoord);
		lowp vec4 c = texture2D(texture, varTexCoord);
		gl_FragColor = c*a;
	}
}








