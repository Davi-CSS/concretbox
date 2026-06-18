import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Historico from '../views/Historico.vue'

const routes = [
  { path: '/',          component: Home,      name: 'home' },
  { path: '/historico', component: Historico, name: 'historico' },
]

export default createRouter({
  history: createWebHistory(),
  routes,
})
