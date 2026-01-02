import { createRouter, createWebHistory } from 'vue-router'
import { useAppStore } from './stores/app'
import LoginView from './views/LoginView.vue'
import JobsView from './views/JobsView.vue'
import ChecklistView from './views/ChecklistView.vue'
import ReviewView from './views/ReviewView.vue'

const routes = [
    {
        path: '/',
        redirect: '/login'
    },
    {
        path: '/login',
        name: 'login',
        component: LoginView,
        meta: { requiresAuth: false }
    },
    {
        path: '/jobs',
        name: 'jobs',
        component: JobsView,
        meta: { requiresAuth: true }
    },
    {
        path: '/checklist/:jobId',
        name: 'checklist',
        component: ChecklistView,
        meta: { requiresAuth: true }
    },
    {
        path: '/review/:jobId',
        name: 'review',
        component: ReviewView,
        meta: { requiresAuth: true, requiresSupervisor: true }
    }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

// Navigation guard
router.beforeEach((to, from, next) => {
    const store = useAppStore()

    if (to.meta.requiresAuth && !store.isAuthenticated) {
        next('/login')
    } else if (to.meta.requiresSupervisor && store.user?.role !== 'supervisor' && store.user?.role !== 'admin') {
        next('/jobs')
    } else if (to.name === 'login' && store.isAuthenticated) {
        next('/jobs')
    } else {
        next()
    }
})

export default router
