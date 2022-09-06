precision highp float;

uniform float time;
uniform vec2 resolution;
varying vec2 vUv;


int stepLimit = 20;
float nearLimit = 0.001;

float getDist(vec3 pos) {
  float dist = length(pos - vec3(0.0, 0.0, -15.0)) - 5.0;
  return dist;
}

void main() {
  vec2 uv = (vUv - vec2(0.5, 0.5)) * resolution.xy + vec2(0.5);

  vec3 camPos = vec3(0.0, 0.0, 0.0);
  vec3 camRot = normalize(vec3((vUv - vec2(0.5))*(resolution / resolution.y).xy, -1.0));

  vec4 col = vec4(0, 1, 1, 1);
  vec3 pos = camPos;
  for (int i = 0; i < 256; i++) {
    float dist = getDist(pos);
    pos = pos + camRot * dist;

    if (dist < nearLimit) {
      col = vec4(1, 1, 0, 1);
      break;
    }

    if (i > stepLimit) {
      break;
    }
  }

  gl_FragColor = col;
}