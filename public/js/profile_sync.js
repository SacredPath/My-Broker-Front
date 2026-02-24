/**
 * Universal Profile Sync System
 * Ensures profiles are always correctly populated from registration data
 * Runs on every page load to maintain data consistency
 */

class ProfileSync {
    constructor() {
        this.currentUser = null;
        this.registrationData = null;
        this.init();
    }

    async init() {
        console.log('[ProfileSync] Initializing profile sync system...');
        
        // Wait for auth to be ready
        if (window.AuthStateManager) {
            window.AuthStateManager.addEventListener(async (authState) => {
                if (authState.user && authState.user.id) {
                    this.currentUser = authState.user;
                    console.log('[ProfileSync] User detected:', this.currentUser.email);
                    
                    // Always check and sync profile, not just when registration data exists
                    await this.syncProfile();
                }
            });
            
            // Also check immediately if user is already logged in
            if (window.AuthService) {
                const currentUser = await window.AuthService.getCurrentUser();
                if (currentUser && currentUser.id) {
                    this.currentUser = currentUser;
                    console.log('[ProfileSync] Immediate user detected:', this.currentUser.email);
                    await this.syncProfile();
                }
            }
        }
    }

    async syncProfile() {
        try {
            console.log('[ProfileSync] Starting profile sync for user:', this.currentUser.email);
            
            // Get current profile
            const profileResult = await window.AuthService.getUserProfile(this.currentUser.id);
            
            if (!profileResult.success || !profileResult.data) {
                console.log('[ProfileSync] No profile found, creating from registration data...');
                await this.createProfileFromRegistrationData();
            } else {
                console.log('[ProfileSync] Profile exists, checking completeness...');
                await this.updateProfileFromRegistrationData(profileResult.data);
                
                // Also ensure profile has all required fields
                await this.ensureProfileCompleteness(profileResult.data);
            }
            
        } catch (error) {
            console.error('[ProfileSync] Profile sync failed:', error);
        }
    }

    async ensureProfileCompleteness(existingProfile) {
        try {
            // Check if profile has all required fields
            const needsUpdate = 
                !existingProfile.first_name || 
                !existingProfile.last_name || 
                !existingProfile.user_id;

            if (needsUpdate) {
                console.log('[ProfileSync] Updating incomplete profile with defaults...');
                
                const updateData = {
                    first_name: existingProfile.first_name || 'Unknown',
                    last_name: existingProfile.last_name || 'User',
                    user_id: existingProfile.user_id || existingProfile.id,
                    updated_at: new Date().toISOString()
                };

                const result = await window.AuthService.updateUserProfile(this.currentUser.id, updateData);
                
                if (result.success) {
                    console.log('[ProfileSync] Profile completeness ensured');
                } else {
                    console.error('[ProfileSync] Failed to ensure profile completeness:', result.error);
                }
            } else {
                console.log('[ProfileSync] Profile is complete');
            }

        } catch (error) {
            console.error('[ProfileSync] Error ensuring profile completeness:', error);
        }
    }

    async createProfileFromRegistrationData() {
        try {
            // Get registration data from localStorage or create default
            const registrationData = this.getRegistrationData();
            
            if (!registrationData) {
                console.warn('[ProfileSync] No registration data available');
                return;
            }

            console.log('[ProfileSync] Creating profile with data:', registrationData);

            // Create comprehensive profile
            const profileData = {
                id: this.currentUser.id,
                user_id: this.currentUser.id, // Both columns required
                email: this.currentUser.email,
                first_name: registrationData.firstName || registrationData.first_name || '',
                last_name: registrationData.lastName || registrationData.last_name || '',
                phone: registrationData.phone || '',
                address_line1: registrationData.address?.address_line1 || '',
                address_line2: registrationData.address?.address_line2 || '',
                city: registrationData.address?.city || '',
                state: registrationData.address?.state || '',
                country: registrationData.country || '',
                postal_code: registrationData.address?.postal_code || '',
                occupation: registrationData.compliance?.occupation || '',
                dob: registrationData.compliance?.dob || '',
                new_to_investing: registrationData.compliance?.new_to_investing || '',
                pep: registrationData.compliance?.pep || '',
                pep_details: registrationData.compliance?.pep_details || '',
                referral_code: registrationData.referralCode || '',
                kyc_status: 'pending',
                tier_level: 1,
                balance: 0.00,
                is_active: true,
                email_verified: false,
                created_at: new Date().toISOString(),
                updated_at: new Date().toISOString()
            };

            const result = await window.AuthService.createUserProfile(this.currentUser.id, profileData);
            
            if (result.success) {
                console.log('[ProfileSync] Profile created successfully');
                this.clearRegistrationData();
            } else {
                console.error('[ProfileSync] Profile creation failed:', result.error);
            }

        } catch (error) {
            console.error('[ProfileSync] Error creating profile:', error);
        }
    }

    async updateProfileFromRegistrationData(existingProfile) {
        try {
            const registrationData = this.getRegistrationData();
            
            if (!registrationData) {
                console.log('[ProfileSync] No registration data to update from');
                return;
            }

            // Check if profile needs updating
            const needsUpdate = 
                !existingProfile.first_name && registrationData.firstName ||
                !existingProfile.last_name && registrationData.lastName ||
                !existingProfile.phone && registrationData.phone ||
                !existingProfile.address_line1 && registrationData.address?.address_line1;

            if (needsUpdate) {
                console.log('[ProfileSync] Updating incomplete profile...');
                
                const updateData = {
                    first_name: registrationData.firstName || existingProfile.first_name,
                    last_name: registrationData.lastName || existingProfile.last_name,
                    phone: registrationData.phone || existingProfile.phone,
                    address_line1: registrationData.address?.address_line1 || existingProfile.address_line1,
                    address_line2: registrationData.address?.address_line2 || existingProfile.address_line2,
                    city: registrationData.address?.city || existingProfile.city,
                    state: registrationData.address?.state || existingProfile.state,
                    country: registrationData.country || existingProfile.country,
                    postal_code: registrationData.address?.postal_code || existingProfile.postal_code,
                    occupation: registrationData.compliance?.occupation || existingProfile.occupation,
                    dob: registrationData.compliance?.dob || existingProfile.dob,
                    new_to_investing: registrationData.compliance?.new_to_investing || existingProfile.new_to_investing,
                    pep: registrationData.compliance?.pep || existingProfile.pep,
                    pep_details: registrationData.compliance?.pep_details || existingProfile.pep_details,
                    referral_code: registrationData.referralCode || existingProfile.referral_code,
                    updated_at: new Date().toISOString()
                };

                const result = await window.AuthService.updateUserProfile(this.currentUser.id, updateData);
                
                if (result.success) {
                    console.log('[ProfileSync] Profile updated successfully');
                    this.clearRegistrationData();
                } else {
                    console.error('[ProfileSync] Profile update failed:', result.error);
                }
            } else {
                console.log('[ProfileSync] Profile is complete, no update needed');
            }

        } catch (error) {
            console.error('[ProfileSync] Error updating profile:', error);
        }
    }

    getRegistrationData() {
        try {
            // Try to get registration data from localStorage
            const stored = localStorage.getItem('registrationData');
            if (stored) {
                return JSON.parse(stored);
            }
            
            // Try to get from sessionStorage
            const sessionStored = sessionStorage.getItem('registrationData');
            if (sessionStored) {
                return JSON.parse(sessionStored);
            }
            
            return null;
        } catch (error) {
            console.error('[ProfileSync] Error getting registration data:', error);
            return null;
        }
    }

    clearRegistrationData() {
        try {
            localStorage.removeItem('registrationData');
            sessionStorage.removeItem('registrationData');
            console.log('[ProfileSync] Registration data cleared');
        } catch (error) {
            console.error('[ProfileSync] Error clearing registration data:', error);
        }
    }
}

// Initialize profile sync on every page load
const profileSync = new ProfileSync();

// Export for global access
window.ProfileSync = profileSync;
