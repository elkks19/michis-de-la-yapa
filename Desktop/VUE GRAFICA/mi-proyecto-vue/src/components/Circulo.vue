<template>
  <div ref="sceneContainer" class="scene"></div>
</template>

<script>
import * as THREE from 'three'

export default {
  name: 'Cono3D',
  mounted() {
    const scene = new THREE.Scene()
    const camera = new THREE.PerspectiveCamera(75, 1, 0.1, 1000)
    const renderer = new THREE.WebGLRenderer()
    renderer.setSize(400, 400)
    this.$refs.sceneContainer.appendChild(renderer.domElement)

    // Crear geometría de cono
    // Parámetros: radio de la base, altura, cantidad de segmentos
    const geometry = new THREE.ConeGeometry(2, 5, 32)
    const material = new THREE.MeshBasicMaterial({ color: 0x00ff00, wireframe: true })
    const cone = new THREE.Mesh(geometry, material)
    scene.add(cone)

    camera.position.z = 10

    // Animación
    const animate = () => {
      requestAnimationFrame(animate)
      cone.rotation.x += 0.01
      cone.rotation.y += 0.01
      renderer.render(scene, camera)
    }

    animate()
  }
}
</script>

<style scoped>
.scene {
  display: flex;
  justify-content: center;
  align-items: center;
  margin: auto;
}
</style>
