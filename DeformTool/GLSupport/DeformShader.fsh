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
	highp float power = texture2D(brushTexture, varBrushCoord).r;

	highp vec4 deformColor = texture2D(meshTexture, varTexCoord) / 1.0;
	highp vec2 deformVector = deformColor.rb ;//- deformColor.ga;
	deformVector = deformVector + force*power*1.0;
	
	deformVector = deformVector*1.0;
	gl_FragColor = vec4( deformVector.x, -deformVector.x, deformVector.y, -deformVector.y);
	
}








