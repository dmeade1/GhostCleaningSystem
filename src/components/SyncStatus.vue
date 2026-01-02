<template>
  <div class="flex items-center gap-2">
    <div 
      class="w-2 h-2 rounded-full transition-all duration-300"
      :class="store.isOnline ? 'bg-green-500 animate-pulse' : 'bg-yellow-500'"
    ></div>
    <span class="text-sm text-slate-400">
      {{ store.isOnline ? 'Online' : 'Offline' }}
    </span>
    
    <button
      v-if="store.pendingSyncCount > 0"
      @click="store.syncOfflineQueue()"
      :disabled="!store.isOnline || store.isSyncing"
      class="ml-2 px-3 py-1 bg-yellow-500/20 text-yellow-300 rounded-lg text-xs font-medium hover:bg-yellow-500/30 transition-colors disabled:opacity-50"
    >
      <span v-if="store.isSyncing">Syncing...</span>
      <span v-else>Sync {{ store.pendingSyncCount }}</span>
    </button>
  </div>
</template>

<script setup>
import { useAppStore } from '../stores/app'

const store = useAppStore()
</script>
