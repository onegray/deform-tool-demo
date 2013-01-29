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
	gl_FragColor = texture2D(texture, varTexCoord);

	/*
	lowp vec2 v = varTexCoord - vec2(0.5, 0.5);
	lowp float r2 = length(v);

	if(r2>0.25) {
		gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
	} else {
		gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
	}
	*/
	
	//gl_FragColor = vec4(0.0, 1.0, 0.0, 1.0);
}







