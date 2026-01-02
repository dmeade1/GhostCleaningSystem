<template>
  <button
    @click="showModal = true"
    class="w-10 h-10 rounded-lg bg-slate-700 hover:bg-red-600 transition-all duration-200 flex items-center justify-center active:scale-95"
  >
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 21v-4m0 0V5a2 2 0 012-2h6.5l1 1H21l-3 6 3 6h-8.5l-1-1H5a2 2 0 00-2 2zm9-13.5V9" />
    </svg>
  </button>

  <!-- Modal -->
  <div
    v-if="showModal"
    class="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4"
    @click.self="showModal = false"
  >
    <div class="card max-w-md w-full">
      <h3 class="text-xl font-bold text-white mb-4">Report Issue</h3>
      
      <div class="space-y-4">
        <div>
          <label class="block text-sm font-medium text-slate-300 mb-2">Priority</label>
          <select v-model="priority" class="input">
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
            <option value="urgent">Urgent</option>
          </select>
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-300 mb-2">Title</label>
          <input v-model="title" type="text" class="input" placeholder="Brief description" />
        </div>

        <div>
          <label class="block text-sm font-medium text-slate-300 mb-2">Details</label>
          <textarea v-model="description" class="input" rows="4" placeholder="Describe the issue..."></textarea>
        </div>

        <div class="flex gap-3">
          <button @click="showModal = false" class="flex-1 btn btn-secondary">
            Cancel
          </button>
          <button @click="submitIssue" class="flex-1 btn btn-danger">
            Report Issue
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useAppStore } from '../stores/app'

const props = defineProps({
  taskId: {
    type: String,
    required: true
  }
})

const store = useAppStore()
const showModal = ref(false)
const priority = ref('medium')
const title = ref('')
const description = ref('')

async function submitIssue() {
  if (!title.value.trim()) {
    alert('Please enter a title')
    return
  }

  await store.reportIssue({
    task_id: props.taskId,
    priority: priority.value,
    title: title.value,
    description: description.value,
    status: 'open'
  })

  // Reset form
  title.value = ''
  description.value = ''
  priority.value = 'medium'
  showModal.value = false
}
</script>
