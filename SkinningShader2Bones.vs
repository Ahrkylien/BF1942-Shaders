; (c) Copyright 2000 - Digital Illusions CE AB, All Rights Reserved
;
;
; @file SkinningShader2Bones.vs
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
#define C_FOGDATA 					c[5]
#define LOCAL_SPACE_LIGHT_DIR				c[6]
#define C_LIGHT_COLOR					c[7]
#define C_SHADOW_COLOR					c[8]

#define BONE_START_1					9
#define BONE_START_2					10
#define BONE_START_3					11

vs.1.1

mul r3, INDICES.zyxw,CONST.xxxx

mov a0.x, r3.x
// Transform offset 0 by bone0.
dp4 r1.x, VERTEX_OFFSET0, c[a0.x+BONE_START_1]
dp4 r1.y, VERTEX_OFFSET0, c[a0.x+BONE_START_2]
dp4 r1.z, VERTEX_OFFSET0, c[a0.x+BONE_START_3]
m3x3 r5.xyz, VERTEX_NORMAL, c[a0.x+BONE_START_1]
// Weigh vertex.
mul r2.xyz, r1.xyz, WEIGHTS.x
mul r4.xyz, r5.xyz, WEIGHTS.x

mov a0.x, r3.y
// Transform offset 1 by bone1.
dp4 r1.x, VERTEX_OFFSET1, c[a0.x+BONE_START_1]
dp4 r1.y, VERTEX_OFFSET1, c[a0.x+BONE_START_2]
dp4 r1.z, VERTEX_OFFSET1, c[a0.x+BONE_START_3]
m3x3 r5.xyz, VERTEX_NORMAL, c[a0.x+BONE_START_1]
// Weigh vertex.
mad r2.xyz, r1.xyz, WEIGHTS.y, r2.xyz
mad r4.xyz, r5.xyz, WEIGHTS.y, r4.xyz

mov r2.w, CONST.y 
dp4 oPos.x, r2, WORLD_VIEW_PROJ_MATRIX_1
dp4 oPos.y, r2, WORLD_VIEW_PROJ_MATRIX_2 
dp4 oPos.z, r2, WORLD_VIEW_PROJ_MATRIX_3 
dp4 oPos.w, r2, WORLD_VIEW_PROJ_MATRIX_4

;dp4 oPos.x, VERTEX_OFFSET0, WORLD_VIEW_PROJ_MATRIX_1
;dp4 oPos.y, VERTEX_OFFSET0, WORLD_VIEW_PROJ_MATRIX_2 
;dp4 oPos.z, VERTEX_OFFSET0, WORLD_VIEW_PROJ_MATRIX_3 
;dp4 oPos.w, VERTEX_OFFSET0, WORLD_VIEW_PROJ_MATRIX_4

// Compute fog.
dp4 r1.x, r2, WORLD_VIEW_PROJ_MATRIX_4
mad oFog.x, C_FOGDATA.y, r1.x, C_FOGDATA.x	// ((-1/Range)*d)+End/Range = (End-d)/Range

// Animate texture coordinates. Tracks on tanks etc.
mad oT0, TEX_COORDS, CONST.y, CONST.zwww	// TEX_COORDS + [Offset,0,0,0]

// Lighting.
// normalize normals
mov r4.x, r4.x
mov r4.z, r4.z
dp3 r4.w, r4, r4;
rsq r4.w, r4.w
mul r4, r4, r4.w;

dp3 r1.x, r4.xyz, -LOCAL_SPACE_LIGHT_DIR.xyz
max r3.x, r1.x, CONST.w

// Compute color.
mov r2, C_SHADOW_COLOR
mad oD0, C_LIGHT_COLOR, r3.x, r2 	// oD0.w implicitly set to C_SHADOW_COLOR.w = 1
