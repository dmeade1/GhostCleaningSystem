<template>
  <div class="min-h-screen flex items-center justify-center p-4 bg-gradient-to-br from-slate-900 via-slate-800 to-ocean-900">
    <div class="w-full max-w-md">
      <!-- Logo/Header -->
      <div class="text-center mb-8">
        <div class="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-br from-ocean-500 to-blue-600 rounded-2xl mb-4 shadow-2xl shadow-ocean-500/30">
          <svg class="w-12 h-12 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <h1 class="text-3xl font-bold text-gradient mb-2">Ghost Cleaning</h1>
        <p class="text-slate-400">Enter your PIN to continue</p>
      </div>

      <!-- PIN Display -->
      <div class="card mb-6">
        <div class="flex justify-center gap-3 mb-6">
          <div 
            v-for="i in 4" 
            :key="i"
            class="w-14 h-14 rounded-lg border-2 flex items-center justify-center text-2xl font-bold transition-all duration-200"
            :class="pin.length >= i ? 'border-ocean-500 bg-ocean-500/20 text-ocean-300' : 'border-slate-600 bg-slate-700/50 text-slate-500'"
          >
            {{ pin.length >= i ? '●' : '' }}
          </div>
        </div>

        <!-- Error Message -->
        <div v-if="error" class="mb-4 p-3 bg-red-500/20 border border-red-500/30 rounded-lg text-red-300 text-sm text-center">
          {{ error }}
        </div>

        <!-- PIN Pad -->
        <div class="grid grid-cols-3 gap-3">
          <button
            v-for="num in [1, 2, 3, 4, 5, 6, 7, 8, 9]"
            :key="num"
            @click="addDigit(num)"
            class="h-16 bg-slate-700 hover:bg-slate-600 rounded-lg text-2xl font-semibold transition-all duration-200 active:scale-95 hover:shadow-lg hover:shadow-ocean-500/20"
            :disabled="loading"
          >
            {{ num }}
          </button>
          
          <button
            @click="clearPin"
            class="h-16 bg-slate-700 hover:bg-red-600 rounded-lg text-sm font-medium transition-all duration-200 active:scale-95"
            :disabled="loading"
          >
            Clear
          </button>
          
          <button
            @click="addDigit(0)"
            class="h-16 bg-slate-700 hover:bg-slate-600 rounded-lg text-2xl font-semibold transition-all duration-200 active:scale-95 hover:shadow-lg hover:shadow-ocean-500/20"
            :disabled="loading"
          >
            0
          </button>
          
          <button
            @click="deleteDigit"
            class="h-16 bg-slate-700 hover:bg-slate-600 rounded-lg transition-all duration-200 active:scale-95"
            :disabled="loading"
          >
            <svg class="w-6 h-6 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2M3 12l6.414 6.414a2 2 0 001.414.586H19a2 2 0 002-2V7a2 2 0 00-2-2h-8.172a2 2 0 00-1.414.586L3 12z" />
            </svg>
          </button>
        </div>

        <!-- Login Button -->
        <button
          @click="handleLogin"
          :disabled="pin.length !== 4 || loading"
          class="w-full mt-6 btn btn-primary disabled:opacity-50 disabled:cursor-not-allowed"
        >
          <span v-if="loading">Logging in...</span>
          <span v-else>Login</span>
        </button>
      </div>

      <!-- Offline Indicator -->
      <div v-if="!store.isOnline" class="text-center text-yellow-400 text-sm flex items-center justify-center gap-2">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        Offline Mode
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAppStore } from '../stores/app'

const router = useRouter()
const store = useAppStore()

const pin = ref('')
const error = ref('')
const loading = ref(false)

function addDigit(digit) {
  if (pin.value.length < 4) {
    pin.value += digit.toString()
    error.value = ''
    
    // Auto-submit when 4 digits entered
    if (pin.value.length === 4) {
      setTimeout(() => handleLogin(), 300)
    }
  }
}

function deleteDigit() {
  pin.value = pin.value.slice(0, -1)
  error.value = ''
}

function clearPin() {
  pin.value = ''
  error.value = ''
}

async function handleLogin() {
  if (pin.value.length !== 4) return
  
  loading.value = true
  error.value = ''
  
  const result = await store.loginWithPin(pin.value)
  
  if (result.success) {
    router.push('/jobs')
  } else {
    error.value = 'Invalid PIN. Please try again.'
    pin.value = ''
  }
  
  loading.value = false
}
</script>
