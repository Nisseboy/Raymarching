precision highp float;

uniform float time;
uniform vec2 resolution;
varying vec2 vUv;

uniform vec3 camRot;
uniform vec3 camPos;
uniform vec2 mouse;


int stepLimit = 20;
float nearLimit = 0.001;

float sdSphere(vec3 pos) {
  return length(pos - vec3(0.0, 0.0, -15.0)) - 5.0;
}

float sdfDist(vec3 pos) {
  float sphere = sdSphere(pos);

  return sphere;
}

vec3 getNormal(vec3 pos)
{
    const float eps = 0.0001;
    const vec2 h = vec2(eps,0);
    return normalize( vec3(sdfDist(pos+h.xyy) - sdfDist(pos-h.xyy),
                           sdfDist(pos+h.yxy) - sdfDist(pos-h.yxy),
                           sdfDist(pos+h.yyx) - sdfDist(pos-h.yyx) ) );
}

void main() {
  vec2 uv = (vUv - vec2(0.5, 0.5)) * resolution.xy + vec2(0.5);

  vec3 dir = normalize(vec3((vUv - vec2(0.5))*(resolution / resolution.y).xy, -1.0));
  
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
    float dist = sdfDist(pos);

    if (dist < nearLimit) {
      vec3 normal = getNormal(pos);
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