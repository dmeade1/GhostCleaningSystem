<template>
  <div class="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-ocean-900 p-4 pb-20">
    <div class="container mx-auto max-w-2xl">
      <!-- Header -->
      <div class="mb-6 pt-4">
        <button @click="goBack" class="text-ocean-400 hover:text-ocean-300 mb-4 flex items-center gap-2">
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
          Back to Jobs
        </button>
        
        <div class="flex items-center justify-between mb-2">
          <h2 class="text-2xl font-bold text-white">{{ currentJob?.yacht?.name }}</h2>
          <span v-if="store.user?.team_type" :class="teamBadgeClass" class="px-3 py-1 rounded-full text-xs font-semibold uppercase">
            {{ store.user.team_type }}
          </span>
        </div>
        <p class="text-slate-400">{{ currentJob?.yacht?.model }}</p>
      </div>

      <!-- Loading State -->
      <div v-if="loading" class="flex items-center justify-center py-20">
        <div class="text-center">
          <div class="w-16 h-16 border-4 border-ocean-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
          <p class="text-slate-400">Loading checklist...</p>
        </div>
      </div>

      <!-- Zones and Tasks -->
      <div v-else class="space-y-6">
        <div v-for="zone in zones" :key="zone.id" class="card">
          <div class="flex items-center justify-between mb-4 pb-4 border-b border-slate-700">
            <h3 class="text-lg font-bold text-white">{{ zone.name }}</h3>
            <span class="text-sm text-slate-400">
              {{ getZoneProgress(zone.id) }} / {{ zone.tasks?.length || 0 }}
            </span>
          </div>

          <!-- Tasks List -->
          <div class="space-y-3">
            <TaskItem
              v-for="task in zone.tasks"
              :key="task.id"
              :task="task"
              :completed="isTaskCompleted(task.id)"
              @toggle="toggleTask(task)"
            />
          </div>
        </div>

        <!-- Complete Job Button -->
        <button
          v-if="allTasksCompleted"
          @click="completeJob"
          class="w-full btn btn-primary"
        >
          Complete Job
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAppStore } from '../stores/app'
import { supabase } from '../lib/supabase'
import TaskItem from '../components/TaskItem.vue'

const router = useRouter()
const route = useRoute()
const store = useAppStore()

const loading = ref(true)
const zones = ref([])
const completedTasks = ref(new Set())

const currentJob = computed(() => store.currentJob)

const teamBadgeClass = computed(() => {
  const teamType = store.user?.team_type
  if (teamType === 'interior') return 'bg-purple-500/20 text-purple-300 border border-purple-500/50'
  if (teamType === 'exterior') return 'bg-blue-500/20 text-blue-300 border border-blue-500/50'
  return 'bg-slate-500/20 text-slate-300 border border-slate-500/50'
})

const allTasksCompleted = computed(() => {
  const totalTasks = zones.value.reduce((sum, zone) => sum + (zone.tasks?.length || 0), 0)
  return totalTasks > 0 && completedTasks.value.size === totalTasks
})

onMounted(async () => {
  await loadChecklist()
})

async function loadChecklist() {
  loading.value = true
  
  try {
    // Fetch zones and tasks for the yacht
    const { data: zonesData, error: zonesError } = await supabase
      .from('zones')
      .select(`
        *,
        tasks(*)
      `)
      .eq('yacht_id', currentJob.value.yacht.id)
      .order('order_index', { ascending: true })

    if (zonesError) throw zonesError

    // Filter zones by team type
    const userTeamType = store.user?.team_type || 'both'
    let filteredZones = zonesData
    
    if (userTeamType !== 'both') {
      filteredZones = zonesData.filter(zone => 
        zone.zone_type === userTeamType || zone.zone_type === 'both'
      )
    }

    // Sort tasks within each zone
    filteredZones.forEach(zone => {
      if (zone.tasks) {
        zone.tasks.sort((a, b) => a.order_index - b.order_index)
      }
    })

    zones.value = filteredZones

    // Load completed tasks
    const { data: completionsData, error: completionsError } = await supabase
      .from('task_completions')
      .select('task_id')
      .eq('job_id', currentJob.value.id)

    if (completionsError) throw completionsError

    completedTasks.value = new Set(completionsData.map(c => c.task_id))
  } catch (error) {
    console.error('Error loading checklist:', error)
  }
  
  loading.value = false
}

function isTaskCompleted(taskId) {
  return completedTasks.value.has(taskId)
}

function getZoneProgress(zoneId) {
  const zone = zones.value.find(z => z.id === zoneId)
  if (!zone?.tasks) return 0
  return zone.tasks.filter(t => completedTasks.value.has(t.id)).length
}

async function toggleTask(task) {
  if (completedTasks.value.has(task.id)) {
    // Uncomplete task
    completedTasks.value.delete(task.id)
    
    // Delete from database
    await supabase
      .from('task_completions')
      .delete()
      .eq('job_id', currentJob.value.id)
      .eq('task_id', task.id)
  } else {
    // Complete task
    completedTasks.value.add(task.id)
    
    // Save to database
    await store.completeTask(task.id)
  }
}

async function completeJob() {
  try {
    await supabase
      .from('jobs')
      .update({ 
        status: 'completed',
        completed_at: new Date().toISOString()
      })
      .eq('id', currentJob.value.id)

    router.push('/jobs')
  } catch (error) {
    console.error('Error completing job:', error)
  }
}

function goBack() {
  router.push('/jobs')
}
</script>
