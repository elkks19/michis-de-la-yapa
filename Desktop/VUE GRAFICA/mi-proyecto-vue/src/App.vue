<template>
  <div id="app">
    <h1 style="color: white; text-align: center;">Esfera 3D en Vue</h1>
    <Esfera3D />
    <h1 style="color: white; text-align: center; margin-top: 40px;">Cilindro 3D en Vue</h1>
    <Cilindro3D />
  </div>
</template>

<script>
import Esfera3D from './components/Circulo.vue'
import Cilindro3D from './components/Cilindro.vue'

export default {
  name: 'App',
  components: {
    Esfera3D,
    Cilindro3D
  }
}
</script>
