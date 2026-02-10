/**
 * Environment Configuration
 * This file should be replaced during build process with actual environment variables
 * For development, you can update these values manually
 */

// Merge with existing window.__ENV if it exists, otherwise initialize
if (typeof window.__ENV === 'undefined') {
  window.__ENV = {};
}

// Default to cloud Supabase configuration
var DEFAULT_SUPABASE_URL = 'https://ubycoeyutauzjgxbozcm.supabase.co';
var DEFAULT_SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVieWNvZXl1dGF1empneGJvemNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk0MDYyOTIsImV4cCI6MjA4NDk4MjI5Mn0.NUqdlArOGnCUEXuQYummEgsJKHoTk3fUvBarKIagHMM';

// Set default values if not already defined
if (!window.__ENV.SUPABASE_URL) {
  window.__ENV.SUPABASE_URL = DEFAULT_SUPABASE_URL;
}

if (!window.__ENV.SUPABASE_ANON_KEY) {
  window.__ENV.SUPABASE_ANON_KEY = DEFAULT_SUPABASE_ANON_KEY;
}

if (!window.__ENV.NODE_ENV) {
  window.__ENV.NODE_ENV = 'development';
}

if (!window.__ENV.API_TIMEOUT) {
  window.__ENV.API_TIMEOUT = '10000';
}

if (!window.__ENV.API_RETRIES) {
  window.__ENV.API_RETRIES = '1';
}

// Add SUPABASE_LOCAL flag (default false)
if (typeof window.__ENV.SUPABASE_LOCAL === 'undefined') {
  window.__ENV.SUPABASE_LOCAL = false;
}

// Local override logic (explicit opt-in only)
if (window.__ENV.SUPABASE_LOCAL === true) {
  // Only use local Supabase when explicitly opted in AND running on localhost
  const isLocalhost = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
  
  if (isLocalhost) {
    window.__ENV.SUPABASE_URL = 'http://localhost:54321';
    console.debug('[env] Using local Supabase (explicit opt-in)');
  } else {
    console.debug('[env] Local opt-in detected but not on localhost, using cloud');
    window.__ENV.SUPABASE_URL = DEFAULT_SUPABASE_URL;
  }
}

// Guard against placeholder keys
if (!window.__ENV.SUPABASE_ANON_KEY || 
    window.__ENV.SUPABASE_ANON_KEY.includes('your-local-anon-key') ||
    window.__ENV.SUPABASE_ANON_KEY.includes('REPLACE_WITH_CORRECT_ANON_KEY')) {
  throw new Error('Invalid SUPABASE_ANON_KEY configuration. Please update with a valid Supabase anon key.');
}

// Debug: show which Supabase host is being used (without exposing the key)
console.debug('[env] Supabase host:', new URL(window.__ENV.SUPABASE_URL).hostname);

// For production, this file should be generated during build with:
// SUPABASE_URL=https://your-project.supabase.co
// SUPABASE_ANON_KEY=your-production-anon-key
