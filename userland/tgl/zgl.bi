#include once "zmath.bi"
enum OPInfo
    OP_Color
    OP_TexCoord
    OP_EdgeFlag
    OP_Normal
    OP_Begin
    OP_Vertex
    OP_End
    OP_EnableDisable
    OP_MatrixMode
    OP_LoadMatrix
    OP_LoadIdentity
    OP_MultMatrix
    OP_PushMatrix
    OP_PopMatrix
    OP_Rotate
    OP_Translate
    OP_Scale
    OP_Viewport
    OP_Frustum
    OP_Material
    OP_ColorMaterial
    OP_Light
    OP_LightModel
    OP_Clear
    OP_ClearColor
    OP_ClearDepth
    OP_InitNames
    OP_PushName
    OP_PopName
    OP_LoadName
    OP_TexImage2D
    OP_BindTexture
    OP_TexEnv
    OP_TexParameter
    OP_PixelStore
    OP_ShadeModel
    OP_CullFace
    OP_FrontFace
    OP_PolygonMode
    OP_CallList
    OP_Hint
end enum


#define POLYGON_MAX_VERTEX 16

#define MAX_SPECULAR_BUFFERS 8

#define SPECULAR_BUFFER_SIZE 1024

#define SPECULAR_BUFFER_RESOLUTION 1024


#define MAX_MODELVIEW_STACK_DEPTH  32
#define MAX_PROJECTION_STACK_DEPTH 8
#define MAX_TEXTURE_STACK_DEPTH    8
#define MAX_NAME_STACK_DEPTH       64
#define MAX_TEXTURE_LEVELS         11
#define MAX_LIGHTS                 16

#define VERTEX_HASH_SIZE 1031

#define MAX_DISPLAY_LISTS 1024
#define OP_BUFFER_MAX_SIZE 512

#define TGL_OFFSET_FILL    &h1
#define TGL_OFFSET_LINE    &h2
#define TGL_OFFSET_POINT   &h4

type GLSpecBuf field = 1
    shininess_i as integer
    last_used as integer
    
    buf(0 to SPECULAR_BUFFER_SIZE) as single
    _next as GLSpecBuf ptr
end type

type GLLight field = 1
    ambient as V4
    diffuse as V4
    specular as V4
    position as V4
    spot_direction as V3
    spot_exponent as single
    spot_cutoff as single
    attenuation(0 to 2) as single
    cos_spot_cutoff as single
    norm_spot_direction as V3
    norm_position as V3
    enabled as integer
    
    _next as GLLight ptr
    _prev as GLLight ptr
end type

type GLMaterial field = 1
    emission    as V4
    ambient     as V4
    diffuse     as V4
    specular    as V4
    shininess   as single
    shininess_i as integer
    do_specular as integer
end type;

type GLViewport field = 1
    xmin as integer
    ymina s integer
    xsize as integer
    ysize as integer
    scale as V3
    trans as V3
    updated as integer
end type

type GLParam field = 1
    op as integer
    f as single
    i as integer
    ui as unsigned integer
    p as any ptr
end type

type GLParamBuffer field = 1
    ops(0 to OP_BUFFER_MAX_SIZE-1) as GLParam
    _next as GLParamBuffer ptr
end type

type GLList field = 1
    first_op_buffer as GLParamBuffer ptr
end type

type GLVertex field = 1
    edge_flag as integer
    normal  as V3
    coord   as V4
    tex_coord   as V4
    color   as V4
    
    ec as V4
    pc as V4
    clip_code as integer
    zp as ZBufferPoint prr
end type

type GLImage field = 1
    pixmap as any ptr
    xsize as integer
    ysize as integer
end type


#define TEXTURE_HASH_TABLE_SIZE 256

type GLTexture field = 1
    images(0 to MAX_TEXTURE_LEVELS-1) as 
    handle as integer
    
    _next as GLTexture ptr
    _prev  as GLTexture ptr
end type


/* shared state */

type  GLSharedState field = 1
    lists as GList ptr ptr
    texture_hash_table as GLTexture ptr
end type


type GLContext field = 1
    zb as ZBuffer ptr
    lights(0 to MAX_LIGHTS-1] as GLLight
    first_light as GLLight ptr
    
    ambient_light_model as V4
    local_light_model as integer
    lighting_enabled as integer
    list_model_two_side as integer

    dim materials(0 to 1) as GLMaterial
    color_material_enabled as integer
    current_color_material_mode as integer
    current_color_material_type as integer
    
    current_texture GLTexture ptr;
    texture_2D_enabled as integer
    
    shared_state as GLSharedState

    current_op_buffer as GLParamBUffer ptr
    current_op_buffer_index as integer
    exec_flag as integer
    compile_flag as integer
    print_flag as integer
    
    matrix_mode as integer
    matrix_stack(0 to 2) as M4
    matrix_stack_ptr(0 to 2) as M4 ptr
    matrix_stack_depth_max(0 to 2) as integer
    
    matrix_model_view_inv   as M4
    matrix_model_projection as M4

    matrix_model_projection_updated as integer
    matrix_model_projection_no_w_transform as integer
    
    apply_texture_matrix as integer
    
    viewport as GLViewport

  /* current state */
  int polygon_mode_back;
  int polygon_mode_front;

  int current_front_face;
  int current_shade_model;
  int current_cull_face;
  int cull_face_enabled;
  int normalize_enabled;
  gl_draw_triangle_func draw_triangle_front,draw_triangle_back;

  /* selection */
  int render_mode;
  unsigned int *select_buffer;
  int select_size;
  unsigned int *select_ptr,*select_hit;
  int select_overflow;
  int select_hits;

  /* names */
  unsigned int name_stack[MAX_NAME_STACK_DEPTH];
  int name_stack_size;

  /* clear */
  float clear_depth;
  V4 clear_color;

  /* current vertex state */
  V4 current_color;
  unsigned int longcurrent_color[3]; /* precomputed integer color */
  V4 current_normal;
  V4 current_tex_coord;
  int current_edge_flag;

  /* glBegin / glEnd */
  int in_begin;
  int begin_type;
  int vertex_n,vertex_cnt;
  int vertex_max;
  GLVertex *vertex;

  /* opengl 1.1 arrays  */
  float *vertex_array;
  int vertex_array_size;
  int vertex_array_stride;
  float *normal_array;
  int normal_array_stride;
  float *color_array;
  int color_array_size;
  int color_array_stride;
  float *texcoord_array;
  int texcoord_array_size;
  int texcoord_array_stride;
  int client_states;
  
  /* opengl 1.1 polygon offset */
  float offset_factor;
  float offset_units;
  int offset_states;
  
  /* specular buffer. could probably be shared between contexts, 
    but that wouldn't be 100% thread safe */
  GLSpecBuf *specbuf_first;
  int specbuf_used_counter;
  int specbuf_num_buffers;

  /* opaque structure for user's use */
  void *opaque;
  /* resize viewport function */
  int (*gl_resize_viewport)(struct GLContext *c,int *xsize,int *ysize);

  /* depth test */
  int depth_test;
} GLContext;



struct GLContext;

typedef void (*gl_draw_triangle_func)(struct GLContext *c,
                                      GLVertex *p0,GLVertex *p1,GLVertex *p2);

/* display context */

extern GLContext *gl_ctx;

void gl_add_op(GLParam *p);

/* clip.c */
void gl_transform_to_viewport(GLContext *c,GLVertex *v);
void gl_draw_triangle(GLContext *c,GLVertex *p0,GLVertex *p1,GLVertex *p2);
void gl_draw_line(GLContext *c,GLVertex *p0,GLVertex *p1);
void gl_draw_point(GLContext *c,GLVertex *p0);

void gl_draw_triangle_point(GLContext *c,
                            GLVertex *p0,GLVertex *p1,GLVertex *p2);
void gl_draw_triangle_line(GLContext *c,
                           GLVertex *p0,GLVertex *p1,GLVertex *p2);
void gl_draw_triangle_fill(GLContext *c,
                           GLVertex *p0,GLVertex *p1,GLVertex *p2);
void gl_draw_triangle_select(GLContext *c,
                             GLVertex *p0,GLVertex *p1,GLVertex *p2);

/* matrix.c */
void gl_print_matrix(const float *m);
/*
void glopLoadIdentity(GLContext *c,GLParam *p);
void glopTranslate(GLContext *c,GLParam *p);*/

/* light.c */
void gl_add_select(GLContext *c,unsigned int zmin,unsigned int zmax);
void gl_enable_disable_light(GLContext *c,int light,int v);
void gl_shade_vertex(GLContext *c,GLVertex *v);

void glInitTextures(GLContext *c);
void glEndTextures(GLContext *c);
GLTexture *alloc_texture(GLContext *c,int h);

/* image_util.c */
void gl_convertRGB_to_5R6G5B(unsigned short *pixmap,unsigned char *rgb,
                             int xsize,int ysize);
void gl_convertRGB_to_8A8R8G8B(unsigned int *pixmap, unsigned char *rgb,
                               int xsize, int ysize);
void gl_resizeImage(unsigned char *dest,int xsize_dest,int ysize_dest,
                    unsigned char *src,int xsize_src,int ysize_src);
void gl_resizeImageNoInterpolate(unsigned char *dest,int xsize_dest,int ysize_dest,
                                 unsigned char *src,int xsize_src,int ysize_src);

GLContext *gl_get_context(void);

void gl_fatal_error(char *format, ...);


/* specular buffer "api" */
GLSpecBuf *specbuf_get_buffer(GLContext *c, const int shininess_i, 
                              const float shininess);

#ifdef __BEOS__
void dprintf(const char *, ...);

#else /* !BEOS */

#ifdef DEBUG

#define dprintf(format, args...)  \
  fprintf(stderr,"In '%s': " format "\n",__FUNCTION__, ##args);

#else

#define dprintf(format, args...)

#endif
#endif /* !BEOS */

/* glopXXX functions */

#define ADD_OP(a,b,c) void glop ## a (GLContext *,GLParam *);
#include "opinfo.h"

/* this clip epsilon is needed to avoid some rounding errors after
   several clipping stages */

#define CLIP_EPSILON (1E-5)

static inline int gl_clipcode(float x,float y,float z,float w1)
{
  float w;

  w=w1 * (1.0 + CLIP_EPSILON);
  return (x<-w) |
    ((x>w)<<1) |
    ((y<-w)<<2) |
    ((y>w)<<3) |
    ((z<-w)<<4) | 
    ((z>w)<<5) ;
}

#endif /* _tgl_zgl_h_ */