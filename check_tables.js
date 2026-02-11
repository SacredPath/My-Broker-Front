// Database Table Checker
// Use this in browser console to check what tables exist and their structure

async function checkDatabaseTables() {
    console.log('🔍 Checking database tables...');
    
    try {
        // Test signal_purchases table
        console.log('\n--- Testing signal_purchases table ---');
        const signalTest = await window.API.supabase
            .from('signal_purchases')
            .select('*')
            .limit(1);
            
        if (signalTest.error) {
            console.error('❌ signal_purchases error:', signalTest.error);
        } else {
            console.log('✅ signal_purchases exists, sample data:', signalTest.data);
        }
        
        // Test transactions table  
        console.log('\n--- Testing transactions table ---');
        const transactionTest = await window.API.supabase
            .from('transactions')
            .select('*')
            .limit(1);
            
        if (transactionTest.error) {
            console.error('❌ transactions error:', transactionTest.error);
        } else {
            console.log('✅ transactions exists, sample data:', transactionTest.data);
        }
        
        // List all possible signal-related tables
        console.log('\n--- Testing alternative table names ---');
        const possibleTables = [
            'signal_purchases',
            'signal_purchase', 
            'signals',
            'trading_signals',
            'user_signals',
            'signal_subscriptions',
            'purchases',
            'user_purchases'
        ];
        
        for (const tableName of possibleTables) {
            try {
                const test = await window.API.supabase
                    .from(tableName)
                    .select('count')
                    .limit(1);
                    
                if (!test.error) {
                    console.log(`✅ Found table: ${tableName}`);
                }
            } catch (e) {
                console.log(`❌ Table not found: ${tableName}`);
            }
        }
        
    } catch (error) {
        console.error('Database check failed:', error);
    }
}

// Run the check
checkDatabaseTables();
