//
//  LayerMesh.m
//  DeformTool
//
//  Created by onegray on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LayerMesh.h"
#import "TextureMesh.h"

@interface LayerMesh()
{
	TextureMesh* textureMesh;
	

	MeshLayout layout;
	int tileSize;
	GLfloat* vertices;
	GLfloat* vectors;
	int vertNum;
	
	GLushort* indices;
	int indexCount;
	
}
@end


@implementation LayerMesh
@synthesize vertices, vectors, vertNum;
@synthesize indices, indexCount;
@synthesize layout, tileSize, textureContentSize;


-(id) initWithTextureSize:(PixelSize)ts
{
	self = [super init];
	if(self) {
		NSAssert( ts.widthPixels % MAX_TEXTURE_TILE_SIZE == 0, @"");
		NSAssert( ts.heighPixels % MAX_TEXTURE_TILE_SIZE == 0, @"");
		
		tileSize = 4;
		textureContentSize = ts;
		layout = MeshLayoutMake(0, 0, ts.widthPixels/tileSize, ts.heighPixels/tileSize);
		textureMesh = [[TextureMesh alloc] initWithTextureRect:CGRectMake(0, 0, 1, 1) meshLayout:layout];
	
		/*
		layout = MeshLayoutMake(-2, -2, layout.width+4, layout.height+4);
		[textureMesh extendMeshLayout:layout];
		*/
		 
		/*
		[textureMesh resampleMesh:2];
		tileSize = tileSize/2;
		layout = textureMesh.layout;
		*/
		
		[self rebuildVertexMesh];
	}
	return self;
}


-(void) rebuildVertexMesh
{
	if(vertices)
		free(vertices);
	if(indices)
		free(indices);
	if(vectors)
		free(vectors);

	vertNum = (layout.width+1)*(layout.height+1);
	
	vectors = (GLfloat*)malloc(vertNum*2*sizeof(GLfloat));
	memset(vectors, 0, vertNum*2*sizeof(GLfloat));
	
	vertices = (GLfloat*)malloc(vertNum*2*sizeof(GLfloat));
	GLfloat* vertPtr = vertices;
	
	for(int i=0; i<=layout.height; i++)
	{
		for(int j=0; j<=layout.width; j++)
		{
			*vertPtr++ = (layout.x+j)*tileSize;
			*vertPtr++ = (layout.y+i)*tileSize;
		}
	}
	
	indexCount = layout.height*(layout.width+1)*2;
	indices = malloc(indexCount*sizeof(GLushort));
	GLushort* pi = indices;
	
	for(int i=0; i<layout.height; i++)
	{
		for(int j=0; j<=layout.width; j++)
		{
			*pi++ = i*(layout.width+1) + j;
			*pi++ = (i+1)*(layout.width+1) +j;
		}
		
		i++;
		if(i==layout.height)
			break;
		
		for(int j=layout.width; j>=0; j--)
		{
			*pi++ = (i+1)*(layout.width+1) + j;
			*pi++ = i*(layout.width+1) + j;
		}
	}	
	
	NSAssert(indexCount==(pi-indices), @"Invalid indNum");
}




-(void) buildMeshForLayout:(MeshLayout)viewLayout 
{	
	if(!MeshLayoutContainsLayout(textureMesh.layout, viewLayout)) {
		MeshLayout unionLayout = MeshLayoutUnion(textureMesh.layout, viewLayout);
		[textureMesh extendMeshLayout:unionLayout];
	}

	//int ts = textureMesh.tileSize;
	//CGRect viewRect = CGRectMake(viewLayout.x*ts, viewLayout.y*ts, viewLayout.width*ts, viewLayout.height*ts);
	
	
	
}


-(GLfloat*) texCoords
{
	return textureMesh.coordinates;
}

-(int) texCoordNum
{
	return textureMesh.coordNum;
}


@end





























