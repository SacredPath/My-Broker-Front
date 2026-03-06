// Fix frequent reload issue in AuthGuard
// The handleSignIn function is causing unwanted redirects

// PROBLEM: handleSignIn() redirects too aggressively, causing page reloads
// SOLUTION: Add better logic to prevent unnecessary redirects

// Find handleSignIn function in authGuard.js (around lines 236-246) and replace with:

handleSignIn() {
  console.log('AuthGuard: User signed in');
  
  // Check if there's an intended destination
  const intendedDestination = sessionStorage.getItem('intendedDestination');
  if (intendedDestination && intendedDestination !== window.location.pathname) {
    console.log('AuthGuard: Redirecting to intended destination:', intendedDestination);
    sessionStorage.removeItem('intendedDestination');
    
    // Only redirect if it's actually a different page
    // This prevents reload loops when already on correct page
    window.location.href = intendedDestination;
  }
  
  // Always clear intended destination to prevent stale redirects
  sessionStorage.removeItem('intendedDestination');
}
