import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '../lib/supabase'

export const useAppStore = defineStore('app', () => {
    // State
    const user = ref(null)
    const currentJob = ref(null)
    const offlineQueue = ref([])
    const isOnline = ref(navigator.onLine)
    const isSyncing = ref(false)

    // Computed
    const isAuthenticated = computed(() => !!user.value)
    const pendingSyncCount = computed(() => offlineQueue.value.length)

    // Actions
    async function loginWithPin(pin) {
        try {
            const { data, error } = await supabase
                .from('users')
                .select('*')
                .eq('pin', pin)
                .single()

            if (error) throw error

            user.value = data
            localStorage.setItem('ghost_user', JSON.stringify(data))
            return { success: true }
        } catch (error) {
            console.error('Login error:', error)
            return { success: false, error: error.message }
        }
    }

    function logout() {
        user.value = null
        currentJob.value = null
        localStorage.removeItem('ghost_user')
        localStorage.removeItem('ghost_current_job')
    }

    function loadUserFromStorage() {
        const stored = localStorage.getItem('ghost_user')
        if (stored) {
            user.value = JSON.parse(stored)
        }
    }

    async function fetchTodaysJobs() {
        if (!user.value) return []

        try {
            const today = new Date().toISOString().split('T')[0]

            const { data, error } = await supabase
                .from('jobs')
                .select(`
          *,
          yacht:yachts(*)
        `)
                .eq('assigned_to', user.value.id)
                .eq('scheduled_date', today)
                .order('created_at', { ascending: true })

            if (error) throw error
            return data || []
        } catch (error) {
            console.error('Error fetching jobs:', error)
            return []
        }
    }

    async function setCurrentJob(job) {
        currentJob.value = job
        localStorage.setItem('ghost_current_job', JSON.stringify(job))
    }

    function loadCurrentJobFromStorage() {
        const stored = localStorage.getItem('ghost_current_job')
        if (stored) {
            currentJob.value = JSON.parse(stored)
        }
    }

    async function completeTask(taskId, photoUrl = null, notes = null) {
        if (!currentJob.value) return { success: false, error: 'No active job' }

        const completion = {
            job_id: currentJob.value.id,
            task_id: taskId,
            completed_by: user.value.id,
            completed_at: new Date().toISOString(),
            photo_url: photoUrl,
            notes: notes,
            synced: isOnline.value
        }

        if (isOnline.value) {
            try {
                const { error } = await supabase
                    .from('task_completions')
                    .upsert(completion)

                if (error) throw error
                return { success: true }
            } catch (error) {
                console.error('Error completing task:', error)
                // Add to offline queue if online save fails
                addToOfflineQueue('complete_task', completion)
                return { success: true, offline: true }
            }
        } else {
            // Add to offline queue
            addToOfflineQueue('complete_task', completion)
            return { success: true, offline: true }
        }
    }

    async function reportIssue(issueData) {
        const issue = {
            ...issueData,
            job_id: currentJob.value?.id,
            reported_by: user.value.id,
            created_at: new Date().toISOString(),
            synced: isOnline.value
        }

        if (isOnline.value) {
            try {
                const { error } = await supabase
                    .from('issues')
                    .insert(issue)

                if (error) throw error
                return { success: true }
            } catch (error) {
                console.error('Error reporting issue:', error)
                addToOfflineQueue('report_issue', issue)
                return { success: true, offline: true }
            }
        } else {
            addToOfflineQueue('report_issue', issue)
            return { success: true, offline: true }
        }
    }

    function addToOfflineQueue(actionType, payload) {
        const queueItem = {
            id: crypto.randomUUID(),
            actionType,
            payload,
            timestamp: new Date().toISOString()
        }
        offlineQueue.value.push(queueItem)
        saveOfflineQueue()
    }

    function saveOfflineQueue() {
        localStorage.setItem('ghost_offline_queue', JSON.stringify(offlineQueue.value))
    }

    function loadOfflineQueue() {
        const stored = localStorage.getItem('ghost_offline_queue')
        if (stored) {
            offlineQueue.value = JSON.parse(stored)
        }
    }

    async function syncOfflineQueue() {
        if (!isOnline.value || offlineQueue.value.length === 0) return

        isSyncing.value = true

        for (const item of offlineQueue.value) {
            try {
                if (item.actionType === 'complete_task') {
                    await supabase.from('task_completions').upsert(item.payload)
                } else if (item.actionType === 'report_issue') {
                    await supabase.from('issues').insert(item.payload)
                }

                // Remove from queue on success
                offlineQueue.value = offlineQueue.value.filter(q => q.id !== item.id)
            } catch (error) {
                console.error('Sync error for item:', item, error)
            }
        }

        saveOfflineQueue()
        isSyncing.value = false
    }

    function updateOnlineStatus() {
        isOnline.value = navigator.onLine
        if (isOnline.value) {
            syncOfflineQueue()
        }
    }

    // Initialize
    loadUserFromStorage()
    loadCurrentJobFromStorage()
    loadOfflineQueue()

    // Listen for online/offline events
    window.addEventListener('online', updateOnlineStatus)
    window.addEventListener('offline', updateOnlineStatus)

    return {
        // State
        user,
        currentJob,
        offlineQueue,
        isOnline,
        isSyncing,
        // Computed
        isAuthenticated,
        pendingSyncCount,
        // Actions
        loginWithPin,
        logout,
        fetchTodaysJobs,
        setCurrentJob,
        completeTask,
        reportIssue,
        syncOfflineQueue,
        updateOnlineStatus
    }
})
