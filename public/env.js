// Environment variables for REST API implementation
// Add this to your env.js file or update existing one

window.__ENV = {
  // Supabase configuration
  SUPABASE_URL: 'https://rfszagckgghcygkomybc.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJmc3phZ2NrZ2doY3lna29teWJjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE0NjAxNTQsImV4cCI6MjA4NzAzNjE1NH0.nrjT5YD3Bi-TSmONzRhPir3H4YNIFddDhR8xYOQnwPI',
  SUPABASE_SERVICE_ROLE_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVieWNvZXl1dGF1empneGJvemNtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2OTQwNjI5MiwiZXhwIjoyMDg0OTgyMjkyfQ.16X2ssw9RgDw4QhF4x1KvilcbMUpqn00gBP0Ed7MCHc',
  
  // API Configuration
  API_BASE_URL: 'https://rfszagckgghcygkomybc.supabase.co',
  API_TIMEOUT: 10000,
  API_RETRIES: 3,
  
  // Feature flags
  USE_REST_API: true,
  USE_EDGE_FUNCTIONS: false,
  
  // Development settings
  DEBUG_MODE: true,
  LOG_LEVEL: 'info'
};
