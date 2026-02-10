// Created skeleton pattern - 2026-01-28
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { 
      status: 204, 
      headers: corsHeaders 
    });
  }

  try {
    // Environment variables
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")?.trim();
    const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")?.trim();
    
    if (!SUPABASE_URL || !SERVICE_ROLE) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          error: "SERVER_ERROR", 
          detail: "Missing environment variables" 
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        }
      );
    }

    // Authentication
    const authHeader = req.headers.get("authorization") ?? req.headers.get("Authorization") ?? "";
    if (!authHeader.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          error: "UNAUTHENTICATED" 
        }),
        { 
          status: 401, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        }
      );
    }

    // Create Supabase client with forwarded auth
    const supabase = createClient(SUPABASE_URL, SERVICE_ROLE, {
      global: { 
        headers: { 
          Authorization: authHeader 
        } 
      }
    });

    // Authenticate user
    const { data: { user }, error: userErr } = await supabase.auth.getUser();
    if (userErr || !user) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          error: "UNAUTHENTICATED" 
        }),
        { 
          status: 401, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        }
      );
    }

    // Load profile
    const { data: profile, error: profileErr } = await supabase
      .from("profiles")
      .select("role,is_frozen,is_growth_paused,email_verified,kyc_status")
      .eq("user_id", user.id)
      .single();

    if (profileErr) {
      return new Response(
        JSON.stringify({ 
          ok: false, 
          error: "SERVER_ERROR", 
          detail: "Failed to load profile" 
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        }
      );
    }

    // Response
    return new Response(
      JSON.stringify({ 
        ok: true, 
        fn: "signal_invoice_generate", 
        user_id: user.id, 
        profile 
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, "Content-Type": "application/json" } 
      }
    );

  } catch (error) {
    return new Response(
      JSON.stringify({ 
        ok: false, 
        error: "SERVER_ERROR", 
        detail: error.message 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, "Content-Type": "application/json" } 
      }
    );
  }
});
