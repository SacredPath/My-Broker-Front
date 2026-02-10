import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Helper function to check RBAC permissions (reused logic)
async function checkRBAC(supabase: any, jwt: string) {
  try {
    const { data: { user }, error: authError } = await supabase.auth.getUser(jwt)
    if (authError || !user) {
      return { error: { code: "UNAUTHENTICATED", message: "Invalid or expired token" } }
    }

    let roleData
    try {
      const { data, error } = await supabase
        .from('backoffice_roles')
        .select('role')
        .eq('user_id', user.id)
        .single()

      if (error) {
        if (error.code === 'PGRST116') {
          // No rows found - user has no backoffice role, default to "user"
          roleData = { role: 'user' }
        } else {
          // Likely schema error - check if table exists
          try {
            const { data: tableCheck } = await supabase
              .rpc('to_regclass', { class_name: 'public.backoffice_roles' })
            
            if (!tableCheck) {
              return { error: { code: "SCHEMA_MISMATCH", message: "Table backoffice_roles does not exist" } }
            }

            // Table exists but columns might be missing
            const { data: columnCheck, error: columnError } = await supabase
              .from('backoffice_roles')
              .select('user_id, role')
              .limit(1)
            
            if (columnError) {
              return { error: { code: "SCHEMA_MISMATCH", message: "Table backoffice_roles missing required columns" } }
            }

            // If we get here, table exists but user has no role
            roleData = { role: 'user' }
          } catch (schemaError) {
            return { error: { code: "SCHEMA_MISMATCH", message: "Database schema error" } }
          }
        }
      } else {
        roleData = data
      }
    } catch (error) {
      return { error: { code: "SCHEMA_MISMATCH", message: "Database schema error" } }
    }

    let permissions = {}
    try {
      const { data: permData } = await supabase
        .from('role_permissions')
        .select('permissions')
        .eq('role', roleData.role)
        .single()
      
      if (permData) {
        permissions = permData.permissions || {}
      }
    } catch {
      // If permissions table doesn't exist or query fails, default to empty object
      permissions = {}
    }

    return { user, role: roleData.role, permissions }
  } catch (error) {
    return { error: { code: "UNAUTHENTICATED", message: "Token validation failed" } }
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders, status: 204 })
  }

  try {
    const url = new URL(req.url)
    
    // Selfcheck route - no external calls
    if (url.searchParams.get('selfcheck') === '1') {
      const required = ['SUPABASE_URL', 'SERVICE_ROLE_KEY']
      const supabaseUrl = Deno.env.get("SUPABASE_URL")?.trim()
      const serviceRoleKey = Deno.env.get("SERVICE_ROLE_KEY")?.trim()
      const present = [supabaseUrl && 'SUPABASE_URL', serviceRoleKey && 'SERVICE_ROLE_KEY'].filter(Boolean)
      const missing = required.filter(key => !Deno.env.get(key)?.trim())
      
      // Check table existence and schema
      let tablesExist = false
      let tableStatus = {}
      
      if (supabaseUrl && serviceRoleKey) {
        try {
          const supabase = createClient(supabaseUrl, serviceRoleKey)
          
          // Check backoffice_roles table
          try {
            const { data: backofficeCheck } = await supabase
              .rpc('to_regclass', { class_name: 'public.backoffice_roles' })
            
            if (backofficeCheck) {
              // Check required columns exist
              const { data: columns, error: columnError } = await supabase
                .from('information_schema.columns')
                .select('column_name')
                .eq('table_schema', 'public')
                .eq('table_name', 'backoffice_roles')
                .in('column_name', ['user_id', 'role'])
              
              if (columnError) {
                tableStatus.backoffice_roles = 'DB_SCHEMA_MISSING'
              } else {
                const foundColumns = columns?.map(c => c.column_name) || []
                const requiredColumns = ['user_id', 'role']
                const missingColumns = requiredColumns.filter(col => !foundColumns.includes(col))
                
                if (missingColumns.length > 0) {
                  tableStatus.backoffice_roles = 'DB_SCHEMA_MISSING'
                } else {
                  tableStatus.backoffice_roles = 'OK'
                }
              }
            } else {
              tableStatus.backoffice_roles = 'TABLE_MISSING'
            }
          } catch (error) {
            tableStatus.backoffice_roles = 'TABLE_MISSING'
          }
          
          // Check role_permissions table (optional)
          try {
            const { data: permissionsCheck } = await supabase
              .rpc('to_regclass', { class_name: 'public.role_permissions' })
            
            tableStatus.role_permissions = permissionsCheck ? 'OK' : 'TABLE_MISSING'
          } catch (error) {
            tableStatus.role_permissions = 'TABLE_MISSING'
          }
          
          tablesExist = Object.values(tableStatus).some(status => status === 'OK')
        } catch {
          tablesExist = false
          tableStatus = { error: 'CONNECTION_FAILED' }
        }
      }
      
      return new Response(
        JSON.stringify({ 
          ok: true, 
          code: "OK", 
          message: "Selfcheck", 
          data: { 
            required, 
            present, 
            missing, 
            tablesExist, 
            tableStatus,
            deployed: true,
            deployment: {
              function: 'admin_verify_email',
              version: '2.0',
              timestamp: new Date().toISOString()
            }
          } 
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200
        }
      )
    }

    // Extract and validate Authorization header
    const auth = req.headers.get("authorization") || req.headers.get("Authorization")
    if (!auth || !auth.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          code: "UNAUTHENTICATED", 
          message: "Missing Bearer token",
          data: { hint: "Provide Authorization: Bearer <token>" }
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 401
        }
      )
    }

    const jwt = auth.substring(7) // Remove "Bearer " prefix

    // Check environment variables
    const supabaseUrl = Deno.env.get("SUPABASE_URL")?.trim()
    const serviceRoleKey = Deno.env.get("SERVICE_ROLE_KEY")?.trim()
    
    if (!supabaseUrl || !serviceRoleKey) {
      const missing = []
      if (!supabaseUrl) missing.push('SUPABASE_URL')
      if (!serviceRoleKey) missing.push('SERVICE_ROLE_KEY')
      
      return new Response(
        JSON.stringify({ 
          ok: false, 
          code: "ENV_MISSING", 
          message: "Missing environment variables", 
          data: { missing } 
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 500
        }
      )
    }

    // Create Supabase client
    const supabase = createClient(supabaseUrl, serviceRoleKey)

    // Parse JSON safely
    let body
    try {
      body = await req.json()
    } catch (error) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          code: "BAD_REQUEST", 
          message: "Invalid JSON in request body",
          data: { hint: "Check your JSON syntax" }
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400
        }
      )
    }

    // Validate required fields
    if (!body.user_id && !body.email) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          code: "BAD_REQUEST", 
          message: "Missing required field",
          data: { hint: "Provide either user_id (uuid) or email" }
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400
        }
      )
    }

    // Check RBAC permissions
    const rbacResult = await checkRBAC(supabase, jwt)
    if (rbacResult.error) {
      const statusCode = rbacResult.error.code === "FORBIDDEN" ? 403 : 401
      return new Response(
        JSON.stringify({ 
          ok: false, 
          code: rbacResult.error.code, 
          message: rbacResult.error.message,
          data: rbacResult.error.code === "SCHEMA_MISMATCH" ? { hint: "run SQL schema for backoffice_roles" } : {}
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: statusCode
        }
      )
    }

    // Check specific permissions
    const hasPermission = rbacResult.role === 'superadmin' || 
                         (rbacResult.permissions && rbacResult.permissions.verify_email === true)
    
    if (!hasPermission) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          code: "FORBIDDEN", 
          message: "Insufficient permissions",
          data: { 
            required: { role: "superadmin", permission: "verify_email" },
            current: { role: rbacResult.role, permission: rbacResult.permissions?.verify_email }
          }
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 403
        }
      )
    }

    // Perform admin email verification
    let result
    try {
      if (body.user_id) {
        // Use user_id to update
        const { data, error } = await supabase.auth.admin.updateUserById(
          body.user_id,
          { email_confirm: true }
        )
        if (error) throw error
        result = data
      } else if (body.email) {
        // Use email to find user first, then update
        const { data: users, error: searchError } = await supabase.auth.admin.listUsers()
        if (searchError) throw searchError
        
        const targetUser = users.users.find(u => u.email === body.email)
        if (!targetUser) {
          return new Response(
            JSON.stringify({ 
              ok: false, 
              code: "NOT_FOUND", 
              message: "User not found",
              data: { email: body.email }
            }),
            {
              headers: { ...corsHeaders, 'Content-Type': 'application/json' },
              status: 404
            }
          )
        }

        const { data, error } = await supabase.auth.admin.updateUserById(
          targetUser.id,
          { email_confirm: true }
        )
        if (error) throw error
        result = data
      }

      return new Response(
        JSON.stringify({ 
          ok: true, 
          code: "OK", 
          message: "Email verification completed successfully", 
          data: { verified: true, user: result }
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200
        }
      )
    } catch (error) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          code: "OPERATION_FAILED", 
          message: "Failed to verify email",
          data: { hint: "Check user identifier and permissions" }
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400
        }
      )
    }
  } catch (error) {
    console.error('Admin email verification error:', error)
    
    return new Response(
      JSON.stringify({
        ok: false,
        code: "INTERNAL_ERROR",
        message: "Internal error occurred",
        data: { hint: "check edge logs" }
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500
      }
    )
  }
})
