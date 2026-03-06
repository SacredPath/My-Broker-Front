# Database Deployment Verification Guide

## Overview
This guide helps you verify that all database tables, columns, roles, triggers, and functions are properly deployed for your trading platform.

## Quick Verification (Recommended First)

### Step 1: Run Quick Check
1. Open your Supabase Dashboard
2. Go to **SQL Editor**
3. Copy and paste the entire contents of `QUICK_DEPLOYMENT_CHECK.sql`
4. Click **Run** to execute all queries

### Step 2: Review Results
The quick check will show you:
- ✅ **DEPLOYED** - Object exists and is working
- ❌ **MISSING** - Object needs to be created
- ⚠️ **PARTIAL** - Some objects exist but not all
- 🔴 **CRITICAL** - Essential missing items that will break functionality

## Detailed Verification

### Step 3: Run Comprehensive Verification
For a complete analysis, run `comprehensive_db_verification.sql`:
1. In Supabase SQL Editor, open `comprehensive_db_verification.sql`
2. Execute the entire script
3. Review each section for detailed object information

### Step 4: Check Specific Issues
If you encounter specific errors, use these targeted scripts:

#### For audit_log_entries Error:
```sql
-- First run this to identify the source
-- Run find_audit_log_reference.sql

-- Then create the missing table
-- Run create_audit_log_table.sql
```

#### For Missing Tables:
- `create_user_positions.sql` - Creates user positions table
- `create_investment_tiers.sql` - Creates investment tiers table
- `create_notifications_system.sql` - Creates notification system

#### For Missing Functions/Triggers:
- Check individual SQL files in the project root
- Look for files starting with `create_` or `fix_`

## Expected Objects Summary

### Core Tables (17 expected):
- `profiles` - User profiles and settings
- `kyc_applications` - KYC verification data
- `kyc_status` - KYC status tracking
- `user_positions` - User investment positions
- `investment_tiers` - Investment tier definitions
- `positions` - Trading positions
- `wallet_balances` - User wallet balances
- `deposits` - Deposit records
- `withdrawals` - Withdrawal records
- `notifications` - System notifications
- `notification_settings` - User notification preferences
- `payout_methods` - Withdrawal methods
- `deposit_addresses` - Deposit addresses
- `trading_signals` - Trading signals
- `signal_purchases` - Signal purchase records
- `signal_access` - Signal access permissions
- `audit_log_entries` - Audit trail

### Critical Functions (9 expected):
- `handle_new_user` - User registration handler
- `handle_updated_at` - Timestamp updates
- `calculate_position_maturity` - Position maturity calculation
- `set_position_maturity` - Auto-set maturity trigger
- `tier_upgrade_rpc` - Tier upgrade logic
- `send_notification` - Notification system
- `process_deposit` - Deposit processing
- `process_withdrawal` - Withdrawal processing
- `create_user_position` - Position creation

### Critical Triggers (6 expected):
- `on_auth_user_created` - User creation trigger
- `on_auth_user_updated` - User update trigger
- `handle_user_positions_updated_at` - Position timestamp
- `trigger_set_position_maturity` - Auto maturity
- `handle_investment_tiers_updated_at` - Tier timestamp
- `notification_settings_updated_at` - Settings timestamp

### Security Requirements:
- Row Level Security (RLS) policies on all user data tables
- Proper role assignments (authenticated, service_role)
- Audit logging for sensitive operations

## Troubleshooting Common Issues

### Error: "relation 'public.audit_log_entries' does not exist"
**Solution:** Run `create_audit_log_table.sql`

### Error: "function handle_new_user() does not exist"
**Solution:** Check for `handle_new_user` function creation scripts

### Error: "Missing RLS policies"
**Solution:** Add RLS policies to sensitive tables using the policy creation scripts

### Performance Issues:
**Solution:** Check if indexes are created on frequently queried columns

## Verification Checklist

- [ ] All 17 core tables exist
- [ ] All 9 critical functions exist
- [ ] All 6 critical triggers exist
- [ ] RLS policies are enabled on sensitive tables
- [ ] Indexes are created for performance
- [ ] Foreign key relationships are properly defined
- [ ] Check constraints enforce data integrity
- [ ] Audit logging is functional

## Next Steps

1. **Run the quick check** first to identify major issues
2. **Create missing objects** using the appropriate SQL scripts
3. **Run the comprehensive verification** for detailed analysis
4. **Test functionality** through your application
5. **Monitor performance** and add missing indexes if needed

## Files Created for Verification:

- `QUICK_DEPLOYMENT_CHECK.sql` - Fast status check
- `comprehensive_db_verification.sql` - Detailed analysis
- `find_audit_log_reference.sql` - Troubleshooting script
- `create_audit_log_table.sql` - Fix for missing audit table
- `DEPLOYMENT_VERIFICATION_GUIDE.md` - This guide

## Support

If you encounter issues not covered in this guide:
1. Check the error messages in Supabase SQL Editor
2. Review the individual SQL creation scripts
3. Verify your Supabase project permissions
4. Check for any syntax errors in the SQL scripts
