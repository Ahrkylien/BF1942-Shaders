; (c) Copyright 2000 - Digital Illusions CE AB, All Rights Reserved
;
;
; @file SpriteFog.vs (oridginally Sprite.nvv)
;
; @author	Marco Hjerpe & Robert Györvari & Torbjörn Söderman & Henk
;

//-------------------- DEFINES --------------------------------------------------------

#define VERTEX_POSITION			v0

#define DIFFUSE					v5
								
#define SPRITE_WH				v7

#define SPRITE_SIN_COS			v8

#define TEX_COORDS				v9

#define R_EYE_DISTANCE			r9

#define VIEW_MATRIX_1				c[0]
#define VIEW_MATRIX_2				c[1]
#define VIEW_MATRIX_3				c[2]
#define VIEW_MATRIX_4				c[3]

#define PROJ_MATRIX_1				c[4]
#define PROJ_MATRIX_2				c[5]
#define PROJ_MATRIX_3				c[6]
#define PROJ_MATRIX_4				c[7]
														
#define CONST								c[8]

#define C_CAMPOS						c[9]

#define FOGDATA							c[10]								

vs.1.1

//--- Get delta position (vertex position (world coord)) - (camera pos (world coord))

add r6, VERTEX_POSITION, -C_CAMPOS

//--- Transform by world-view transform. (in this case only View matrix with out transformation) and transposed
//----------- OPTIMIZED STEP 1 ------------------------------------------------

dp3 r0.x, r6, VIEW_MATRIX_1	//X component of all angles don't need the position part (W) here because it is 0,0,0,1 therefor the dp3
dp3 r0.y, r6, VIEW_MATRIX_2 //Y component of all angles
dp3 r0.z, r6, VIEW_MATRIX_3 //Z component of all angles
mov r0.w, CONST.y						//set 1 to w

//--- init some parameters

mov r5.xy, SPRITE_SIN_COS.xy// X=> SIN , Y=> COS
mov r5.z, -SPRITE_SIN_COS.x // -SIN

//-----------Rotate & translate X & Y back to translated sprite origo!---------
//-----------OPTIMIZED STEP 4 -------------------------------------------------

mad r2.xy, SPRITE_WH.yy, r5.zy, r0.xy
mad r0.xy, SPRITE_WH.xx, r5.yx, r2.xy

//
mov oT0, TEX_COORDS

//--- Proj transform. And output pos.

dp4 oPos.x, r0,	PROJ_MATRIX_1
dp4 oPos.y, r0,	PROJ_MATRIX_2
dp4 oPos.z, r0, PROJ_MATRIX_3
dp4 oPos.w, r0, PROJ_MATRIX_4

//--- Output to colors

mov oD0, DIFFUSE

//--- Fog calculation added by torbjorns

// Get distance from camera to eye 
dp3 R_EYE_DISTANCE, r0, r0
rsq R_EYE_DISTANCE, R_EYE_DISTANCE
rcp R_EYE_DISTANCE, R_EYE_DISTANCE

// (fogend -  d ) / (fogend - fogstart)
add r6.x, FOGDATA.y, - R_EYE_DISTANCE.y
mul oFog.x, r6.x, FOGDATA.z

//-----------------------ASM SOURCE END -----------------------------------------------
// 20 instr






//-----------------OPTIMIZE DIARY FOR BETTER UNDERSTANDING-----------------------------
//
//
//
//
//--------- TRANSLATION FORMULA ROTATE POINT TO CAM SPACE------------------------------
//
//	dp4 r0.x, r6, VIEW_MATRIX_1	//X component of all angles
//	dp4 r0.y, r6, VIEW_MATRIX_2 //Y component of all angles
//	dp4 r0.z, r6, VIEW_MATRIX_3 //Z component of all angles
//	dp4 r0.w, r6, VIEW_MATRIX_4 //W component of all agnles
//
// (4 instr)
//-------------------------------------------------------------------------------------

//---------------------------------- PREVIOUS Z ROTATION FORMULA ----------------------
//	(height*s)
//  mul r2.x, SPRITE_HEIGHT, r5.z
//	(width*c) 
//  mul r3.x, SPRITE_WIDTH, r5.y
//	add r1.x, r2,x, r3,x
//
//  (height*c)
//  mul r2.y, SPRITE_HEIGHT, r5.y
//  (width*s)
//  mul r3.y, SPRITE_WIDTH, r5.x
//  add r1.y, r2.y, r3.y
//--- Translate rotated sprite edge to world coord (relative camera space)
//
//	add r4, r0, r1
//
// (7 instr)
//-------------------------------------------------------------------------------------


//---------------------------------- OPTIMIZED STEP 2----------------------------------
// Code from previous math step b4 optimizing, for easier understanding Z ROTATION
//(height)*s = Y*(-Sin)
// RES = Y   * -SIN
//  mul r2.x, SPRITE_HEIGHT, r5.z
// newX = width*c - height*s  
//  mad r1.x, SPRITE_WIDTH, r5.y, r2.x
//
// (height)*c = YCos
// RES = Y   * COS
//  mul r2.y, SPRITE_HEIGHT, r5.y
// newY = width*s + height*c 
//  mad r1.y, SPRITE_WIDTH, r5.x, r2.y
//--- Translate rotated sprite edge to world coord (relative camera space)
//
//	add r4, r0, r1
//
// (5 instr)
//-------------------------------------------------------------------------------------

//---------------------------------- OPTIMIZED STEP 3----------------------------------
//--- Each axis is calculated entirely separated!  optimized from formula Z ROTATION
//
//	mov r1, CONST.x							// init z and w entry with zeros (this will be the wh of sprite no z or w is needed)
//	mul r2.xy, SPRITE_WH.yy, r5.zy
//	mad r1.xy, SPRITE_WH.xx, r5.yx, r2.xy
//
//--- Translate rotated sprite edge to world coord (relative camera space)
//
//	add r4, r0, r1
// 
// (4 instr)
//-------------------------------------------------------------------------------------







//--- NOTE ----------------------------------------------------------------------------
// Future optimization is to use parallel pipes.. use other registers for each line in between heavy calculations
//
// ex:
//
//	mul r0.x, r1.x
//	mul r2.x, r0.x
//
//	should be
//
//	mul r0.x, r1.x
//	Other cmd here to remove stall between these cmd's wich uses other registers to write to!
//	mul r2.x, r0.x
//
//
//-- END ------------------------------------------------------------------------------

