<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-ocean-900 p-4 pb-20">
    <div class="container mx-auto max-w-2xl">
      <!-- Page Header -->
      <div class="mb-6 pt-4">
        <div class="flex items-center justify-between mb-2">
          <h2 class="text-2xl font-bold text-white">Today's Jobs</h2>
          <span v-if="store.user?.team_type" :class="teamBadgeClass" class="px-3 py-1 rounded-full text-xs font-semibold uppercase">
            {{ store.user.team_type }}
          </span>
        </div>
        <p class="text-slate-400">{{ formattedDate }}</p>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex items-center justify-center py-20">
        <div class="text-center">
          <div class="w-16 h-16 border-4 border-ocean-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p class="text-slate-400">Loading jobs...</p>
        </div>
      </div>

      <!-- Empty State -->
      <div v-else-if="jobs.length === 0" class="card text-center py-12">
        <svg class="w-20 h-20 mx-auto mb-4 text-slate-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
        </svg>
        <h3 class="text-xl font-semibold text-slate-300 mb-2">No Jobs Today</h3>
        <p class="text-slate-400">You don't have any assigned jobs for today.</p>
      </div>

      <!-- Jobs List -->
      <div v-else class="space-y-4">
        <div
          v-for="job in jobs"
          :key="job.id"
          @click="selectJob(job)"
          class="card hover:border-ocean-500 cursor-pointer transition-all duration-200 hover:shadow-2xl hover:shadow-ocean-500/20 active:scale-98"
        >
          <div class="flex items-start justify-between mb-4">
            <div class="flex-1">
              <h3 class="text-xl font-bold text-white mb-1">{{ job.yacht?.name }}</h3>
              <p class="text-slate-400 text-sm">{{ job.yacht?.model }} • {{ job.yacht?.length_feet }}ft</p>
              <p class="text-slate-500 text-sm mt-1">{{ job.yacht?.location }}</p>
            </div>
            <span 
              class="badge"
              :class="{
                'badge-pending': job.status === 'pending',
                'badge-in-progress': job.status === 'in_progress',
                'badge-completed': job.status === 'completed',
                'badge-reviewed': job.status === 'reviewed'
              }"
            >
              {{ formatStatus(job.status) }}
            </span>
          </div>

          <!-- Progress Bar -->
          <div v-if="job.progress !== undefined" class="mb-4">
            <div class="flex justify-between text-sm mb-2">
              <span class="text-slate-400">Progress</span>
              <span class="text-ocean-400 font-medium">{{ job.progress }}%</span>
            </div>
            <div class="h-2 bg-slate-700 rounded-full overflow-hidden">
              <div 
                class="h-full bg-gradient-to-r from-ocean-500 to-blue-500 transition-all duration-500"
                :style="{ width: job.progress + '%' }"
              ></div>
            </div>
          </div>

          <!-- Action Button -->
          <div class="flex items-center justify-between pt-4 border-t border-slate-700">
            <div class="text-sm text-slate-400">
              <span v-if="job.started_at">Started {{ formatTime(job.started_at) }}</span>
              <span v-else>Not started</span>
            </div>
            <svg class="w-5 h-5 text-ocean-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/app'

const router = useRouter()
const store = useAppStore()

const jobs = ref([])
const loading = ref(true)

const formattedDate = computed(() => {
  const today = new Date()
  return today.toLocaleDateString('en-US', { 
    weekday: 'long', 
    year: 'numeric', 
    month: 'long', 
    day: 'numeric' 
  })
})

const teamBadgeClass = computed(() => {
  const teamType = store.user?.team_type
  if (teamType === 'interior') return 'bg-purple-500/20 text-purple-300 border border-purple-500/50'
  if (teamType === 'exterior') return 'bg-blue-500/20 text-blue-300 border border-blue-500/50'
  return 'bg-slate-500/20 text-slate-300 border border-slate-500/50'
})

onMounted(async () => {
  await loadJobs()
})

async function loadJobs() {
  loading.value = true
  jobs.value = await store.fetchTodaysJobs()
  loading.value = false
}

function selectJob(job) {
  store.setCurrentJob(job)
  router.push(`/checklist/${job.id}`)
}

function formatStatus(status) {
  return status.split('_').map(word => 
    word.charAt(0).toUpperCase() + word.slice(1)
  ).join(' ')
}

function formatTime(timestamp) {
  const date = new Date(timestamp)
  return date.toLocaleTimeString('en-US', { 
    hour: 'numeric', 
    minute: '2-digit' 
  })
}
</script>
