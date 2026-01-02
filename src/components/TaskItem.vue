<template>
  <div class="flex items-center gap-3">
    <label class="flex items-center gap-3 cursor-pointer group">
      <div class="relative">
        <input
          type="checkbox"
          :checked="completed"
          @change="$emit('toggle')"
          class="sr-only peer"
        />
        <div class="w-6 h-6 border-2 rounded-lg transition-all duration-200 peer-checked:bg-ocean-500 peer-checked:border-ocean-500 border-slate-600 group-hover:border-ocean-400 flex items-center justify-center">
          <svg v-if="completed" class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
          </svg>
        </div>
      </div>
      
      <div class="flex-1">
        <p 
          class="text-white transition-all duration-200"
          :class="completed ? 'line-through text-slate-500' : ''"
        >
          {{ task.title }}
        </p>
        <p v-if="task.description" class="text-sm text-slate-400 mt-1">
          {{ task.description }}
        </p>
      </div>
    </label>

    <div class="flex gap-2">
      <PhotoButton v-if="task.requires_photo" :task-id="task.id" />
      <FlagButton :task-id="task.id" />
    </div>
  </div>
</template>

<script setup>
import PhotoButton from './PhotoButton.vue'
import FlagButton from './FlagButton.vue'

defineProps({
  task: {
    type: Object,
    required: true
  },
  completed: {
    type: Boolean,
    default: false
  }
})

defineEmits(['toggle'])
</script>
