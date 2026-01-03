import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://slwneeoiobahvjovritw.supabase.co'
const supabaseKey = 'sb_publishable_Qlc5zMQApKBYTmQbW3m_Sw_HmkEWgBE'

const supabase = createClient(supabaseUrl, supabaseKey)

async function seedJobs() {
    console.log('🌱 Starting to seed jobs...\n')

    // Get all yachts and users first
    const { data: yachts, error: yachtsError } = await supabase
        .from('yachts')
        .select('id, name')

    const { data: users, error: usersError } = await supabase
        .from('users')
        .select('id, name')

    if (yachtsError || usersError) {
        console.error('Error fetching data:', yachtsError || usersError)
        return
    }

    console.log(`Found ${yachts.length} yachts and ${users.length} users\n`)

    // Helper to find IDs
    const getYachtId = (name) => yachts.find(y => y.name === name)?.id
    const getUserId = (name) => users.find(u => u.name === name)?.id

    // Helper to create date strings
    const daysAgo = (days) => {
        const date = new Date()
        date.setDate(date.getDate() - days)
        return date.toISOString().split('T')[0]
    }

    const daysFromNow = (days) => {
        const date = new Date()
        date.setDate(date.getDate() + days)
        return date.toISOString().split('T')[0]
    }

    const addHours = (dateStr, hours) => {
        const date = new Date(dateStr)
        date.setHours(date.getHours() + hours)
        return date.toISOString()
    }

    // Create job data
    const jobs = [
        // Past jobs (completed)
        {
            yacht_id: getYachtId('Sea Breeze'),
            assigned_to: getUserId('Sarah Interior'),
            scheduled_date: daysAgo(5),
            status: 'completed',
            started_at: addHours(daysAgo(5), 8),
            completed_at: addHours(daysAgo(5), 12)
        },
        {
            yacht_id: getYachtId('Ocean Pearl'),
            assigned_to: getUserId('Mike Exterior'),
            scheduled_date: daysAgo(4),
            status: 'completed',
            started_at: addHours(daysAgo(4), 9),
            completed_at: addHours(daysAgo(4), 13)
        },
        {
            yacht_id: getYachtId('Wave Rider'),
            assigned_to: getUserId('John Doe'),
            scheduled_date: daysAgo(3),
            status: 'completed',
            started_at: addHours(daysAgo(3), 8),
            completed_at: addHours(daysAgo(3), 11.5)
        },
        {
            yacht_id: getYachtId('Sea Breeze'),
            assigned_to: getUserId('John Doe'),
            scheduled_date: daysAgo(2),
            status: 'reviewed',
            started_at: addHours(daysAgo(2), 8),
            completed_at: addHours(daysAgo(2), 12),
            reviewed_by: getUserId('Jane Smith'),
            reviewed_at: addHours(daysAgo(2), 14)
        },
        // Yesterday
        {
            yacht_id: getYachtId('Ocean Pearl'),
            assigned_to: getUserId('Sarah Interior'),
            scheduled_date: daysAgo(1),
            status: 'completed',
            started_at: addHours(daysAgo(1), 8),
            completed_at: addHours(daysAgo(1), 13)
        },
        {
            yacht_id: getYachtId('Wave Rider'),
            assigned_to: getUserId('Mike Exterior'),
            scheduled_date: daysAgo(1),
            status: 'in_progress',
            started_at: addHours(daysAgo(1), 9)
        },
        // Today
        {
            yacht_id: getYachtId('Ocean Pearl'),
            assigned_to: getUserId('John Doe'),
            scheduled_date: daysAgo(0),
            status: 'in_progress',
            started_at: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
            notes: 'Deep clean requested by owner'
        },
        {
            yacht_id: getYachtId('Wave Rider'),
            assigned_to: getUserId('Sarah Interior'),
            scheduled_date: daysAgo(0),
            status: 'pending'
        },
        {
            yacht_id: getYachtId('Sea Breeze'),
            assigned_to: getUserId('Mike Exterior'),
            scheduled_date: daysAgo(0),
            status: 'pending'
        },
        // Tomorrow
        {
            yacht_id: getYachtId('Sea Breeze'),
            assigned_to: getUserId('John Doe'),
            scheduled_date: daysFromNow(1),
            status: 'pending'
        },
        {
            yacht_id: getYachtId('Ocean Pearl'),
            assigned_to: getUserId('Sarah Interior'),
            scheduled_date: daysFromNow(1),
            status: 'pending'
        },
        {
            yacht_id: getYachtId('Wave Rider'),
            assigned_to: getUserId('Mike Exterior'),
            scheduled_date: daysFromNow(1),
            status: 'pending',
            notes: 'Focus on exterior deck areas'
        },
        // Next week
        {
            yacht_id: getYachtId('Sea Breeze'),
            assigned_to: getUserId('Sarah Interior'),
            scheduled_date: daysFromNow(3),
            status: 'pending'
        },
        {
            yacht_id: getYachtId('Ocean Pearl'),
            assigned_to: getUserId('Mike Exterior'),
            scheduled_date: daysFromNow(4),
            status: 'pending'
        },
        {
            yacht_id: getYachtId('Wave Rider'),
            assigned_to: getUserId('John Doe'),
            scheduled_date: daysFromNow(5),
            status: 'pending'
        },
        {
            yacht_id: getYachtId('Sea Breeze'),
            assigned_to: getUserId('Jane Smith'),
            scheduled_date: daysFromNow(7),
            status: 'pending',
            notes: 'VIP charter - extra attention to detail required'
        }
    ]

    // Insert jobs
    console.log(`Inserting ${jobs.length} jobs...\n`)

    const { data, error } = await supabase
        .from('jobs')
        .insert(jobs)
        .select()

    if (error) {
        console.error('❌ Error inserting jobs:', error)
        return
    }

    console.log(`✅ Successfully created ${data.length} jobs!\n`)

    // Show summary
    const statusCounts = data.reduce((acc, job) => {
        acc[job.status] = (acc[job.status] || 0) + 1
        return acc
    }, {})

    console.log('📊 Job Status Summary:')
    Object.entries(statusCounts).forEach(([status, count]) => {
        console.log(`   ${status}: ${count}`)
    })

    console.log('\n✨ Seeding complete!')
}

seedJobs().catch(console.error)
