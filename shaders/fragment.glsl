precision highp float;

struct Object {
  int type; //0: sphere
  vec3 pos;
  vec3 dim;
};
struct RayResult {
  float dist;
  vec3 normal;
  int i;
};

uniform float time;
uniform vec2 resolution;
varying vec2 vUv;

uniform vec3 camRot;
uniform vec3 camPos;

uniform int objectCount;
uniform Object objects[8];

int stepLimit = 20;
float nearLimit = 0.001;


float sdSphere(vec3 pos, int i) {
  return length(pos - objects[i].pos) - objects[i].dim.x;
}

float sd(vec3 pos, int i) {
  float sphere = sdSphere(pos, i);

  return sphere;
}

vec3 sdNormal(vec3 pos, int i)
{
    const float eps = 0.0001;
    const vec2 h = vec2(eps,0);
    return normalize( vec3(sd(pos+h.xyy, i) - sd(pos-h.xyy, i),
                           sd(pos+h.yxy, i) - sd(pos-h.yxy, i),
                           sd(pos+h.yyx, i) - sd(pos-h.yyx, i) ) );
}

RayResult sdf(vec3 pos) {
  float closestD = 10000000.0;
  int closest;
  for (int i = 0; i < objectCount; i++) {
    float d = sd(pos, i);
    if (d < closestD) {
      closestD = d;
      closest = i;
    }
  }

  vec3 normal = vec3(0.0);

  if (closestD < nearLimit) {
    normal = sdNormal(pos, closest);
  }

  return RayResult(closestD, normal, closest);
}


void main() {
  vec2 uv = (vUv - vec2(0.5))*(resolution / resolution.y).xy / 2.0;
  vec3 dir = normalize(vec3(uv, -1.0));
  
  vec4 q;
  vec3 v1 = vec3(0, 0, 1);
  vec3 v2 = camRot;
  vec3 a = cross(v1, v2);
  q.xyz = a;
  q.w = sqrt((pow(length(v1), 2.0)) * (pow(length(v2), 2.0))) + dot(v1, v2);
  vec4 rotation = normalize(q);

  vec3 temp = cross(rotation.xyz, dir) + rotation.w * dir;
  dir = dir + 2.0*cross(rotation.xyz, temp);

  vec4 col = vec4(0, 1, 1, 1);
  vec3 pos = camPos;
  for (int i = 0; i < 256; i++) {
    RayResult info = sdf(pos);
    float dist = info.dist;

    if (dist < nearLimit) {
      vec3 normal = info.normal;
      float light = dot(normal, normalize(vec3(1.0, 1.0, 1.0)));
      col = vec4(1.0, 1.0, 1.0, 1.0) * vec4(light, light, light, 1.0);
    
      break;
    }

    if (i > stepLimit) {
      break;
    }
    pos = pos + dir * dist;
  }

  gl_FragColor = col;
}