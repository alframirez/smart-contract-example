import { createRouter, createWebHistory } from 'vue-router'
import WalletPatment from '../views/WalletPayment.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: WalletPatment
    },
  ]
})

export default router
