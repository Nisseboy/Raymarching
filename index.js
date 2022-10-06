import * as THREE from './three/build/three.module.js';

let fragmentShader = await fetch("shaders/fragment.glsl").then(a=>a.text());
let vertexShader = await fetch("shaders/vertex.glsl").then(a=>a.text());

let width = window.innerWidth;
let height = window.innerHeight;

const scene = new THREE.Scene();
const camera = new THREE.OrthographicCamera(width / - 2, width / 2, height / 2, height / - 2, 0.1, 1000);

const renderer = new THREE.WebGLRenderer();
renderer.setSize( width, height );
document.body.appendChild( renderer.domElement );

const geometry = new THREE.BoxGeometry( width, height, 1 );
const material = new THREE.ShaderMaterial( {

	uniforms: {
		time: {value: 1.0},
		resolution: { value: new THREE.Vector2(width, height) },
		camRot: { value: new THREE.Vector3(0, 0, 1) },
		camPos: { value: new THREE.Vector3(0, 0, 0) },

		objects: {value: []},
		objectCount: {value: 0}
	},

	fragmentShader: fragmentShader,
	vertexShader: vertexShader

} );
const cube = new THREE.Mesh( geometry, material );
scene.add( cube );

camera.position.z = 5;




let pressedKeys = {};
let mouse = {x: 0.5, y: 0.5};

addObject(0, {x: 80, y: 0, z: 0}, {x: 5, y:0,z:0});
addObject(0, {x: 0, y: 0, z: 80}, {x: 5, y:0,z:0});
addObject(0, {x: 60, y: 0, z: 60}, {x: 5, y:0,z:0});
addObject(0, {x: -80, y: 0, z: 0}, {x: 5, y:0,z:0});
addObject(0, {x: 0, y: 0, z: -80}, {x: 5, y:0,z:0});
addObject(0, {x: -60, y: 0, z: -60}, {x: 5, y:0,z:0});
addObject(0, {x: -60, y: 0, z: 60}, {x: 5, y:0,z:0});
addObject(0, {x: 60, y: 0, z: -60}, {x: 5, y:0,z:0});

function animate() {
	requestAnimationFrame( animate );
	renderer.render( scene, camera );

	let uniforms = material.uniforms;
	uniforms.time.value++;

	let movement = {x: 0, y: 0, z: 0}
	if (pressedKeys.w) {
		movement.z++;
	}
	if (pressedKeys.a) {
		movement.x--;
	}
	if (pressedKeys.s) {
		movement.z--;
	}
	if (pressedKeys.d) {
		movement.x++;
	}
	let camRot = {
		x: ((1 - mouse.x) - 0.5) * 10,
		y: (mouse.y - 0.5) * 10
	};
	uniforms.camRot.value.x = camRot.x;
	uniforms.camRot.value.y = camRot.y;

	let rotatedMovement = {
		x: 0,
		y: 0,
		z: 0
	};
	uniforms.camPos.value.x += rotatedMovement.x;
	uniforms.camPos.value.y += rotatedMovement.y;
	uniforms.camPos.value.z += rotatedMovement.z;
}
animate();

function addObject(type, pos, dim) {
	let obj = {
		type: type,
		pos: new THREE.Vector3(pos.x, pos.y, pos.z),
		dim: new THREE.Vector3(dim.x, dim.y, dim.z)
	};

	let uniforms = material.uniforms;

	uniforms.objects.value.push(obj);
	uniforms.objectCount.value++;

	return obj;
}

document.body.addEventListener("mousemove", e => {
	mouse = {x: e.clientX / width, y: e.clientY / height};
});
document.body.addEventListener("keydown", e => {
	pressedKeys[e.key] = true;
});
document.body.addEventListener("keyup", e => {
	pressedKeys[e.key] = false;
});