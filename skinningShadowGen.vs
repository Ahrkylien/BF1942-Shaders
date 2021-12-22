; (c) Copyright 2000 - Digital Illusions CE AB, All Rights Reserved
;
;
; @file skinningShadowGen.vs
;
; @author	Marco Hjerpe, Mats Dal, Henk
;

//-------------------- DEFINES --------------------------------------------------------

#define VERTEX_OFFSET0	v7
#define VERTEX_OFFSET1  v8
#define VERTEX_OFFSET2	v9
#define VERTEX_OFFSET3 	v10

#define WEIGHTS						v1
#define VERTEX_NORMAL					v3
#define INDICES						v5
#define TEX_COORDS					v0

#define WORLD_VIEW_PROJ_MATRIX_1			c[0]
#define WORLD_VIEW_PROJ_MATRIX_2			c[1]
#define WORLD_VIEW_PROJ_MATRIX_3			c[2]
#define WORLD_VIEW_PROJ_MATRIX_4			c[3]

#define CONST						c[4] 

#define BONE_START_1					9
#define BONE_START_2					10
#define BONE_START_3					11

vs.1.1

mad r3, INDICES.zyxw, CONST.xxxw, CONST.wwwy


mov a0.x, r3.x
// Transform offset 0 by bone0.
dp4 r1.x, VERTEX_OFFSET0, c[a0.x+BONE_START_1]
dp4 r1.y, VERTEX_OFFSET0, c[a0.x+BONE_START_2]
dp4 r1.z, VERTEX_OFFSET0, c[a0.x+BONE_START_3]
// Weigh vertex.
mul r2.xyz, r1.xyz, WEIGHTS.x


mov a0.x, r3.y
// Transform offset 1 by bone1.
dp4 r1.x, VERTEX_OFFSET1, c[a0.x+BONE_START_1]
dp4 r1.y, VERTEX_OFFSET1, c[a0.x+BONE_START_2]
dp4 r1.z, VERTEX_OFFSET1, c[a0.x+BONE_START_3]
// Weigh vertex.
mad r3.xyz, r1.xyz, WEIGHTS.y, r2.xyz

dp4 oPos.x, r3, WORLD_VIEW_PROJ_MATRIX_1
dp4 oPos.y, r3, WORLD_VIEW_PROJ_MATRIX_2 
dp4 oPos.z, r3, WORLD_VIEW_PROJ_MATRIX_3 
dp4 oPos.w, r3, WORLD_VIEW_PROJ_MATRIX_4

dp4 oD0, r3, WORLD_VIEW_PROJ_MATRIX_3
