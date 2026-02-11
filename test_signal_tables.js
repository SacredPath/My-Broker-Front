// Test Signal Tables - Find the correct table for home page
async function testSignalTables() {
    const userId = 'e2ae0986-8b81-4df7-871f-8330ee9f8a85'; // Replace with actual user ID
    
    console.log('🔍 Testing signal tables to find the correct one...');
    
    const tables = [
        { name: 'signal_purchases', desc: 'Signal purchases table' },
        { name: 'signal_access', desc: 'Signal access table' },
        { name: 'trading_signals', desc: 'Trading signals table' },
        { name: 'signals', desc: 'Signals table' }
    ];
    
    for (const table of tables) {
        try {
            console.log(`\n--- Testing ${table.name} (${table.desc}) ---`);
            
            // Test basic query
            const { data, error } = await window.API.supabase
                .from(table.name)
                .select('*')
                .eq('user_id', userId)
                .limit(3);
                
            if (error) {
                console.error(`❌ ${table.name} error:`, error);
            } else {
                console.log(`✅ ${table.name} works! Found ${data?.length || 0} records`);
                console.log('Sample data:', data);
                
                // If this table works, test the specific query from home-new.js
                if (table.name === 'signal_purchases') {
                    console.log('\n--- Testing specific home-new.js query ---');
                    const specificQuery = await window.API.supabase
                        .from(table.name)
                        .select('amount, currency, created_at, signal_id')
                        .eq('user_id', userId)
                        .eq('status', 'completed')
                        .order('created_at', { ascending: false })
                        .limit(5);
                        
                    if (specificQuery.error) {
                        console.error('❌ Specific query failed:', specificQuery.error);
                    } else {
                        console.log('✅ Specific query works!');
                    }
                }
            }
        } catch (e) {
            console.error(`❌ ${table.name} exception:`, e);
        }
    }
}

// Run the test
testSignalTables();
