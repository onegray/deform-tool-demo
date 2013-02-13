//
//  Shader.vsh
//
//  Created by Sergey Nikitenko on 2/20/11.
//  Copyright (c) 2011 Sergey Nikitenk. All rights reserved.
//  Hire me at odesk! ( www.odesk.com/users/~~1bd7ccce67734b51 )
//

uniform vec2 tsz; // tex size
uniform vec2 bsz; // brush size
uniform vec2 bp0; // brush pos (rect.origin)

attribute vec2 position;
attribute vec2 vectors;

varying vec2 varTexCoord;

void main()
{
	varTexCoord = (position.xy - bp0) / bsz;

	highp vec2 pos = position + vectors*tsz;
	pos = 2.0*pos/tsz-1.0;
    gl_Position = vec4(pos, 1.0, 1.0);
}
