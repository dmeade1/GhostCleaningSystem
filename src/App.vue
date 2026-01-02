<template>
  <div class="min-h-screen flex flex-col">
    <!-- Header -->
    <header v-if="store.isAuthenticated" class="bg-slate-800 border-b border-slate-700 sticky top-0 z-50">
      <div class="container mx-auto px-4 py-4 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 bg-gradient-to-br from-ocean-500 to-blue-600 rounded-lg flex items-center justify-center">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
          </div>
          <div>
            <h1 class="text-lg font-bold text-gradient">Ghost Cleaning</h1>
            <p class="text-xs text-slate-400">{{ store.user?.name }}</p>
          </div>
        </div>
        
        <div class="flex items-center gap-3">
          <SyncStatus />
          <button @click="handleLogout" class="text-slate-400 hover:text-white transition-colors">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
          </button>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1">
      <router-view />
    </main>
  </div>
</template>

<script setup>
import { useAppStore } from './stores/app'
import { useRouter } from 'vue-router'
import SyncStatus from './components/SyncStatus.vue'

const store = useAppStore()
const router = useRouter()

function handleLogout() {
  store.logout()
  router.push('/login')
}
</script>
