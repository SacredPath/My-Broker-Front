// Fix frequent reload issue caused by periodic auth checks
// Multiple pages are running intervals that check authentication and cause redirects

// PROBLEM: Pages run independent auth checks every 10-30 seconds
// SOLUTION: Remove redundant periodic checks and rely on centralized auth state manager

// 1. INDEX PAGE - Remove 10-second auth check (lines 285-288 in index.js)
// DELETE this code:
setInterval(() => {
  this.updateAuthButton();
}, 10000);

// REPLACE with event-driven approach:
// Listen for auth state changes instead of polling
AuthStateManager.addListener((event, session) => {
  this.updateAuthButton();
}, { id: 'indexPageAuthListener' });

// 2. DASHBOARD PAGE - Remove 30-second data refresh if causing issues (lines 402-406 in dashboard.js)
// DELETE or modify this:
setInterval(() => {
  this.loadDashboardData();
}, 30000);

// REPLACE with longer interval or event-driven:
setInterval(() => {
  this.loadDashboardData();
}, 60000); // 1 minute instead of 30 seconds

// 3. APP-SHELL - Check if authentication check is too aggressive (lines 231-249 in app-shell.js)
// The checkAuthentication() method might be called too frequently

// SOLUTION SUMMARY:
// - Remove periodic auth polling
// - Use event-driven auth state updates
// - Increase data refresh intervals
// - Let AuthStateManager handle auth state centrally
