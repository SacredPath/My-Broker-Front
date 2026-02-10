import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

export function createServerClient(authHeader: string) {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    global: {
      headers: {
        Authorization: authHeader
      }
    },
    auth: {
      persistSession: false
    }
  });
}

export function createServiceClient() {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: {
      persistSession: false
    }
  });
}

// Money rounding helpers
export function roundUSD(value: number | string): number {
  const num = typeof value === 'string' ? parseFloat(value) : value;
  return Math.round(num * 100) / 100;
}

export function roundUSDT(value: number | string): string {
  const num = typeof value === 'string' ? parseFloat(value) : value;
  return (Math.round(num * 1000000) / 1000000).toFixed(6);
}

export function validateAmount(amount: string, currency: 'USD' | 'USDT'): { error: string | null } {
  if (!amount || amount.trim() === '') {
    return 'Amount is required';
  }
  
  const num = parseFloat(amount);
  if (isNaN(num) || num <= 0) {
    return 'Amount must be greater than 0';
  }
  
  if (currency === 'USD' && num > 999999999.99) {
    return 'USD amount cannot exceed 999,999.99';
  }
  
  if (currency === 'USDT' && num > 999999.999999) {
    return 'USDT amount cannot exceed 999,999.999999';
  }
  
  return null;
}

// Request validation helpers
export function validateRequiredFields(body: any, required: string[]): { error: string | null } {
  const missing = required.filter(field => !(field in body) || body[field] === undefined || body[field] === '');
  if (missing.length > 0) {
    return `Missing required fields: ${missing.join(', ')}`;
  }
  return null;
}

export function validateEnum(value: string, allowed: string[], fieldName: string): { error: string | null } {
  if (!allowed.includes(value)) {
    return `${fieldName} must be one of: ${allowed.join(', ')}`;
  }
  return null;
}
