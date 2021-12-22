; (c) Copyright 2000 - Digital Illusions CE AB, All Rights Reserved
;
;
; @file SpriteUVRot.vs (oridginally Sprite.nvv)
;
; @author	Marco Hjerpe, Henk
;

//-------------------- DEFINES --------------------------------------------------------

#define VERTEX_POSITION			v0

#define DIFFUSE					v5
								
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
										
; 0.0, 1.0, 0.0, 0.5				
#define CONST						c[8] 

#define C_CAMPOS						c[9]								

#define PART_RESULT					r5

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

//--- Proj transform. And output pos.
dp4 oPos.x, r0,	PROJ_MATRIX_1
dp4 oPos.y, r0,	PROJ_MATRIX_2
dp4 oPos.z, r0, PROJ_MATRIX_3
dp4 oPos.w, r0, PROJ_MATRIX_4

// output color
mov oD0, DIFFUSE

//--- Create texture coordinates from width and height 

// Compute PART_RESULT
mul r2.xy, SPRITE_SIN_COS.xy, CONST.w
add r3.x, -r2.y, r2.x 
add r4.x, -r2.x, -r2.y
add PART_RESULT.x, r3.x, CONST.w
add PART_RESULT.y, r4.x, CONST.w

// Generate tex coords for sprite quad
sge r1, SPRITE_WH, CONST.x

// Rotate tex coords.
mul r2.xyzw, SPRITE_SIN_COS.xyxy, r1.xyyx

add r3.x, r2.x, r2.y
add r4.x, r2.w, -r2.z

add oT0.x, r4.x, PART_RESULT.x
add oT0.y, r3.x, PART_RESULT.y


; THIS SHADER IS UNOPTIMIZED!!!!!!!