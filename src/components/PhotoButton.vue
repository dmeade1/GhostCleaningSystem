<template>
  <button
    @click="capturePhoto"
    class="w-10 h-10 rounded-lg bg-slate-700 hover:bg-ocean-600 transition-all duration-200 flex items-center justify-center active:scale-95"
    :class="hasPhoto ? 'bg-ocean-500' : ''"
  >
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
    </svg>
  </button>

  <!-- Hidden file input -->
  <input
    ref="fileInput"
    type="file"
    accept="image/*"
    capture="environment"
    class="hidden"
    @change="handleFileSelect"
  />
</template>

<script setup>
import { ref } from 'vue'
import { useAppStore } from '../stores/app'
import { supabase } from '../lib/supabase'

const props = defineProps({
  taskId: {
    type: String,
    required: true
  }
})

const store = useAppStore()
const fileInput = ref(null)
const hasPhoto = ref(false)

function capturePhoto() {
  fileInput.value?.click()
}

async function handleFileSelect(event) {
  const file = event.target.files?.[0]
  if (!file) return

  try {
    // Upload to Supabase Storage
    const fileName = `${store.currentJob.id}/${props.taskId}/${Date.now()}.jpg`
    const { data, error } = await supabase.storage
      .from('task-photos')
      .upload(fileName, file)

    if (error) throw error

    // Get public URL
    const { data: urlData } = supabase.storage
      .from('task-photos')
      .getPublicUrl(fileName)

    // Update task completion with photo URL
    await supabase
      .from('task_completions')
      .update({ photo_url: urlData.publicUrl })
      .eq('job_id', store.currentJob.id)
      .eq('task_id', props.taskId)

    hasPhoto.value = true
  } catch (error) {
    console.error('Error uploading photo:', error)
    alert('Failed to upload photo. It will be saved locally and synced later.')
  }
}
</script>
