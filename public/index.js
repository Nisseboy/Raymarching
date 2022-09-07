import * as THREE from '../node_modules/three/build/three.module.js';

let fragmentShader = await fetch("/shaders/fragment.glsl").then(a=>a.text());
let vertexShader = await fetch("/shaders/vertex.glsl").then(a=>a.text());

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
		mouse: { value: new THREE.Vector2(0, 0) }
	},

	fragmentShader: fragmentShader,
	vertexShader: vertexShader

} );
const cube = new THREE.Mesh( geometry, material );
scene.add( cube );

camera.position.z = 5;

function animate() {
	requestAnimationFrame( animate );
	renderer.render( scene, camera );

	let uniforms = material.uniforms;
	uniforms.time.value++;
}
animate();

document.body.addEventListener("mousemove", e => {
	material.uniforms.mouse.value = new THREE.Vector2(e.clientX, e.clientY);
});