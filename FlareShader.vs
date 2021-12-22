; (c) Copyright 2000 - Digital Illusions CE AB, All Rights Reserved
;
;
; @file FlareShader.vs
;
; @author	Marco Hjerpe
;

//-------------------- DEFINES --------------------------------------------------------
//#pragma screenspace

#define VERTEX_POSITION	v0
#define DIFFUSE					v5
#define WIDTH_HEIGHT		v7
#define SIN_COS					v8
#define TEX_COORDS			v9

vs.1.1

mov r5.xy, WIDTH_HEIGHT.xy
mul r7.xy, r5.xy, SIN_COS.y
mul r8.xy, r5.xy, SIN_COS.x
add r9.x, r7.x, r8.y
add r9.y, r7.y, -r8.x

add oPos.xy, VERTEX_POSITION.xy, r9.xy           
mov oPos.z, VERTEX_POSITION.z
 
// Tex coords.
mov oT0.xy, TEX_COORDS.xy

// Fog.
//slt oFog.x, r5.x, r5.x
// Color.
mov oD0, DIFFUSE
;sge oD0.w, r5.x, r5.x