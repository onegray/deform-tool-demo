//
//  Shader.fsh
//
//  Created by Sergey Nikitenko on 2/20/11.
//  Copyright (c) 2011 Sergey Nikitenk. All rights reserved.
//  Hire me at odesk! ( www.odesk.com/users/~~1bd7ccce67734b51 )
//

varying lowp vec2 varTexCoord;
uniform sampler2D texture;
uniform sampler2D deformTexture;

void main()
{
	lowp vec4 deformColor = texture2D(deformTexture, varTexCoord);
	lowp vec2 deformVector = deformColor.rb - deformColor.ga;
	gl_FragColor = texture2D(texture, varTexCoord+deformVector);
}







