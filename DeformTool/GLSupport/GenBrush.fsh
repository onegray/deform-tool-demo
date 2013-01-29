//
//  Shader.fsh
//
//  Created by Sergey Nikitenko on 2/20/11.
//  Copyright (c) 2011 Sergey Nikitenk. All rights reserved.
//  Hire me at odesk! ( www.odesk.com/users/~~1bd7ccce67734b51 )
//

varying lowp vec2 varPosition;

void main()
{
	highp float r = length(varPosition);
	highp float v = 0.0;
	if(r<1.0) {
		v = pow((cos(r * 3.1415)+1.0) * 0.5, 0.7);
	}
	gl_FragColor = vec4(v,v,v,v);
}








