; (c) Copyright 2000 - Digital Illusions CE AB, All Rights Reserved
;
;
; @file SpriteLighting.vs (oridginally Sprite.nvv)
;
; @author	Marco Hjerpe & Robert Györvari, Henk
;

//-------------------- DEFINES --------------------------------------------------------

#define VERTEX_POSITION			v0

#define DIFFUSE					v4
								
#define SPRITE_WH				v7

#define SPRITE_SIN_COS			v8

#define VIEW_MATRIX_1				c[0]
#define VIEW_MATRIX_2				c[1]
#define VIEW_MATRIX_3				c[2]
#define VIEW_MATRIX_4				c[3]

#define PROJ_MATRIX_1				c[4]
#define PROJ_MATRIX_2				c[5]
#define PROJ_MATRIX_3				c[6]
#define PROJ_MATRIX_4				c[7]
														
#define CONST						c[8]

#define C_CAMPOS					c[9]								

// Lighting constants.
#define C_SHADOW_SPHERE_POINT					c[17]
#define C_LIGHT_COLOR							c[18]
#define C_SHADOW_COLOR							c[19]
#define C_INV_BOUNDING_BOX_SCALE				c[20].xyz
#define C_BOUNDINGBOX_SCALED_INV_GRADIENT_MAG	c[20].w

#define SAMPLE_VECTOR_MAGNITUDE					r5
#define EYE_SPACE_SHADOW_SPHERE_POINT			r6
#define SHADOW_FACTOR							r7
#define EYE_SPACE_GRADIANT						r8

#define TEX_COORDS								r10

vs.1.1

//--- Proj transform. And output pos.

mov oPos, VERTEX_POSITION