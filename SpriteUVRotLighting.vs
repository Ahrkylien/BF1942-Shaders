; (c) Copyright 2000 - Digital Illusions CE AB, All Rights Reserved
;
;
; @file SpriteUVRotLighting.vs (oridginally SpriteUVRot.vsh)
;
; @author	Marco Hjerpe, Henk
;

//-------------------- DEFINES --------------------------------------------------------

#define VERTEX_POSITION			v0

#define DIFFUSE					v5
								
#define SPRITE_WH				v7

#define SPRITE_SIN_COS			v8

#define TEX_COORDS				v9

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
#define C_INV_BOUNDING_BOX_SCALE_AND_MAG		c[20]

#define C_LIGHTMAP_OFFSET_AND_INVSIZE			c[21]

#define SAMPLE_VECTOR_MAGNITUDE					r5
#define EYE_SPACE_SHADOW_SPHERE_POINT			r6
#define SHADOW_FACTOR							r7
#define EYE_SPACE_GRADIANT						r8


#define PART_RESULT								r9

vs.1.1

//--- Get delta position (vertex position (world coord)) - (camera pos (world coord))

add r6, VERTEX_POSITION, -C_CAMPOS

//--- Transform by world-view transform. (in this case only View matrix with out transformation) and transposed
//----------- OPTIMIZED STEP 1 ------------------------------------------------

dp3 r0.x, r6, VIEW_MATRIX_1	//X component of all angles don't need the position part (W) here because it is 0,0,0,1 therefor the dp3
dp3 r0.y, r6, VIEW_MATRIX_2 //Y component of all angles
dp3 r0.z, r6, VIEW_MATRIX_3 //Z component of all angles
mov r0.w, CONST.y						//set 1 to w

//--- Add width, height
add r0.xy, r0.xy, SPRITE_WH.xy

// lighting

// Transform sphere point into eye space.
mov r1, C_SHADOW_SPHERE_POINT

add r1, r1, -C_CAMPOS
dp3 EYE_SPACE_SHADOW_SPHERE_POINT.x, r1, VIEW_MATRIX_1
dp3 EYE_SPACE_SHADOW_SPHERE_POINT.y, r1, VIEW_MATRIX_2
dp3 EYE_SPACE_SHADOW_SPHERE_POINT.z, r1, VIEW_MATRIX_3
mov r1.w, CONST.y						//set 1 to w

// Compute Vec, shadow-sphere point -> vertex.
mul r1, r0, C_INV_BOUNDING_BOX_SCALE_AND_MAG.xyz
mul r3, EYE_SPACE_SHADOW_SPHERE_POINT, C_INV_BOUNDING_BOX_SCALE_AND_MAG.xyz
add r2, r1, -r3
dp3 r3.x, r2, r2
rsq r4.x, r3.x
rcp SAMPLE_VECTOR_MAGNITUDE.x, r4.x

// Compute shadow factor
mul SHADOW_FACTOR.x, SAMPLE_VECTOR_MAGNITUDE.x, C_INV_BOUNDING_BOX_SCALE_AND_MAG.w

// Clamp
min SHADOW_FACTOR.x, SHADOW_FACTOR.x, CONST.y

// Compute color.
add r1.x, CONST.y, -SHADOW_FACTOR.x
mul r2, C_SHADOW_COLOR, r1.x
mad r3.xyz, C_LIGHT_COLOR, SHADOW_FACTOR.x, r2
mov r3.w, CONST.y
;mul oD0, DIFFUSE, r3
mov oD0, DIFFUSE

//--- Proj transform. And output pos.
dp4 oPos.x, r0,	PROJ_MATRIX_1
dp4 oPos.y, r0,	PROJ_MATRIX_2
dp4 oPos.z, r0, PROJ_MATRIX_3
dp4 oPos.w, r0, PROJ_MATRIX_4

//--- Create texture coordinates from width and height 

// Compute PART_RESULT
mul r2.xy, SPRITE_SIN_COS.xy, CONST.w
add r3.x, -r2.y, r2.x 
add r4.x, -r2.x, -r2.y
add PART_RESULT.x, r3.x, CONST.w
add PART_RESULT.y, r4.x, CONST.w

// 
mov r1, TEX_COORDS

// Rotate tex coords.
mul r2.xyzw, SPRITE_SIN_COS.xyxy, r1.xyyx

add r3.x, r2.x, r2.y
add r4.x, r2.w, -r2.z

add oT0.x, r4.x, PART_RESULT.x
add oT0.y, r3.x, PART_RESULT.y
mov oT0.z, TEX_COORDS.z

// Calc proj lightmap tex coords.
add r1.xy, VERTEX_POSITION.xz, -C_LIGHTMAP_OFFSET_AND_INVSIZE.xy
mul oT1.xy, r1.xy, C_LIGHTMAP_OFFSET_AND_INVSIZE.zw

// UNOPTIMIZED !!!!
