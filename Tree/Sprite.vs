#define V_POS	v0
#define V_TEXCOORD v7
#define V_WIDTH_HEIGHT v8

#define C_WORLD_VIEW_MATRIX_1	c[0]
#define C_WORLD_VIEW_MATRIX_2	c[1]
#define C_WORLD_VIEW_MATRIX_3	c[2]
#define C_WORLD_VIEW_MATRIX_4	c[3]

#define C_PROJ_MATRIX_1	c[4]
#define C_PROJ_MATRIX_2	c[5]
#define C_PROJ_MATRIX_3	c[6]
#define C_PROJ_MATRIX_4 c[7]

#define C_SPRITE_SCALE			c[8]
#define C_SHADOW_SPHERE_POINT	c[9]
#define C_BOUNDINGBOX_SCALED_INV_GRADIENT_MAG		c[10]
#define C_LIGHT_COLOR			c[11]
#define C_SHADOW_COLOR			c[12]
#define C_INV_BOUNDING_BOX_SCALE c[13]
#define C_NUMBERS c[14]

#define SAMPLE_VECTOR_MAGNITUDE		  r5
#define EYE_SPACE_SHADOW_SPHERE_POINT r6
#define SHADOW_FACTOR				  r7
#define EYE_SPACE_GRADIANT			  r8
													
vs.1.1

// --- Transform by world-view transform ---
dp4 r0.x, V_POS, C_WORLD_VIEW_MATRIX_1
dp4 r0.y, V_POS, C_WORLD_VIEW_MATRIX_2
dp4 r0.z, V_POS, C_WORLD_VIEW_MATRIX_3
dp4 r0.w, V_POS, C_WORLD_VIEW_MATRIX_4 

mul r1.xy, V_WIDTH_HEIGHT.xy, C_SPRITE_SCALE
add r0.xy, r0.xy, r1.xy

// Transform sphere point into eye space.
mov r1, C_SHADOW_SPHERE_POINT
dp4 EYE_SPACE_SHADOW_SPHERE_POINT.x, r1, C_WORLD_VIEW_MATRIX_1
dp4 EYE_SPACE_SHADOW_SPHERE_POINT.y, r1, C_WORLD_VIEW_MATRIX_2
dp4 EYE_SPACE_SHADOW_SPHERE_POINT.z, r1, C_WORLD_VIEW_MATRIX_3
dp4 EYE_SPACE_SHADOW_SPHERE_POINT.w, r1, C_WORLD_VIEW_MATRIX_4

// Compute Vec, shadow-sphere point -> vertex.
mul r1, r0, C_INV_BOUNDING_BOX_SCALE
mul r3, EYE_SPACE_SHADOW_SPHERE_POINT, C_INV_BOUNDING_BOX_SCALE
//sub r2, r1, r3
add r2, r1, -r3
dp3 r3.x, r2, r2
rsq r4.x, r3.x
rcp SAMPLE_VECTOR_MAGNITUDE.x, r4.x

// Compute shadow factor
mul SHADOW_FACTOR.x, SAMPLE_VECTOR_MAGNITUDE.x, C_BOUNDINGBOX_SCALED_INV_GRADIENT_MAG.x

// Clamp
min SHADOW_FACTOR.x, SHADOW_FACTOR.x, c[30].x

// Compute color.
//sub r1.x, c[30].x, SHADOW_FACTOR.x
//add r1.x, c[30].x, -SHADOW_FACTOR.x
//mul r2, C_SHADOW_COLOR, r1.x
//mad oD0, C_LIGHT_COLOR, SHADOW_FACTOR.x, r2
//mov oD0.w, c[30].x
mov oD0, C_LIGHT_COLOR

// --- Proj transform. And output pos ---

dp4 oPos.x, r0,	C_PROJ_MATRIX_1
dp4 oPos.y, r0,	C_PROJ_MATRIX_2
dp4 oPos.z, r0, C_PROJ_MATRIX_3
dp4 oPos.w, r0, C_PROJ_MATRIX_4

mov oT0, V_TEXCOORD
