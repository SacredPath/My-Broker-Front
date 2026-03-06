/**
 * Back Office Notifications Management Controller
 * Handles sending notifications to users via REST API
 */

class BackOfficeNotifications {
  constructor() {
    this.currentUser = null;
    this.userPermissions = null;
    this.users = [];
    this.recentNotifications = [];
    this.init();
  }

  async init() {
    console.log('Back Office notifications page initializing...');
    
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.setupPage());
    } else {
      this.setupPage();
    }
  }

  async setupPage() {
    try {
      // Check RBAC permissions first
      await this.checkRBAC();
      
      // Load user data
      await this.loadUserData();
      
      // Setup UI
      this.renderUserInfo();
      this.setupNavigation();
      this.setupEventListeners();
      
      // Load data
      await this.loadUsers();
      await this.loadRecentNotifications();
      
      console.log('Back Office notifications page setup complete');
    } catch (error) {
      console.error('Error setting up Back Office notifications page:', error);
      if (error.message === 'Access denied') {
        this.redirectToLogin();
      } else if (window.Notify) {
        window.Notify.error('Failed to load notifications page');
      }
    }
  }

  async checkRBAC() {
    try {
      const user = await window.AuthService.getCurrentUser();
      if (!user) {
        throw new Error('Access denied');
      }

      // Get user profile with permissions
      const profile = await window.AuthService.getCurrentUserWithProfile();
      if (!profile || !profile.profile) {
        throw new Error('Access denied');
      }

      this.currentUser = user;
      this.userPermissions = profile.profile;

      // Check if user has admin permissions
      const allowedRoles = ['superadmin', 'admin', 'support'];
      if (!allowedRoles.includes(this.userPermissions.role)) {
        throw new Error('Access denied');
      }

      console.log('RBAC check passed:', this.userPermissions.role);
    } catch (error) {
      console.error('RBAC check failed:', error);
      throw error;
    }
  }

  async loadUserData() {
    try {
      // Current user data already loaded in checkRBAC
      console.log('User data loaded successfully');
    } catch (error) {
      console.error('Failed to load user data:', error);
      throw error;
    }
  }

  renderUserInfo() {
    if (!this.currentUser) return;

    const userAvatar = document.getElementById('user-avatar');
    const userName = document.getElementById('user-name');
    const userRole = document.getElementById('user-role');

    if (userAvatar) {
      userAvatar.textContent = this.userPermissions.display_name?.charAt(0).toUpperCase() || 'A';
    }

    if (userName) {
      userName.textContent = this.userPermissions.display_name || this.currentUser.email || 'Admin';
    }

    if (userRole) {
      userName.textContent = this.userPermissions.role || 'Admin';
    }
  }

  setupNavigation() {
    // Navigation handled by app-shell
  }

  setupEventListeners() {
    // Recipient type change
    const recipientType = document.getElementById('recipient-type');
    if (recipientType) {
      recipientType.addEventListener('change', (e) => {
        this.handleRecipientTypeChange(e.target.value);
      });
    }

    // Form validation
    const titleInput = document.getElementById('notification-title');
    const messageInput = document.getElementById('notification-message');
    
    if (titleInput) {
      titleInput.addEventListener('input', () => this.validateForm());
    }
    
    if (messageInput) {
      messageInput.addEventListener('input', () => this.validateForm());
    }
  }

  handleRecipientTypeChange(type) {
    const userSelectGroup = document.getElementById('user-select-group');
    const userSelect = document.getElementById('user-select');

    switch (type) {
      case 'single':
        userSelectGroup.style.display = 'block';
        userSelect.multiple = false;
        break;
      case 'multiple':
        userSelectGroup.style.display = 'block';
        userSelect.multiple = true;
        break;
      case 'all':
        userSelectGroup.style.display = 'none';
        break;
    }
  }

  async loadUsers() {
    try {
      console.log('Loading users for notification sending...');
      
      const { data, error } = await window.API.fetchEdge('bo_users_list', {
        method: 'GET'
      });

      if (error || !data.ok) {
        throw new Error(data?.error || 'Failed to load users');
      }

      this.users = data.data || [];
      this.populateUserSelect();
      
      console.log('Users loaded successfully:', this.users.length);
    } catch (error) {
      console.error('Failed to load users:', error);
      if (window.Notify) {
        window.Notify.error('Failed to load users');
      }
    }
  }

  populateUserSelect() {
    const userSelect = document.getElementById('user-select');
    if (!userSelect) return;

    userSelect.innerHTML = '';

    this.users.forEach(user => {
      const option = document.createElement('option');
      option.value = user.user_id;
      option.textContent = `${user.email} (${user.full_name || 'N/A'})`;
      userSelect.appendChild(option);
    });
  }

  async loadRecentNotifications() {
    try {
      console.log('Loading recent notifications...');
      
      // For now, we'll load from the notifications table filtered by current admin
      const adminId = this.currentUser.id;
      const notifications = await window.API.getNotifications(adminId, { limit: 20 });
      
      this.recentNotifications = notifications;
      this.renderNotificationsTable();
      
      console.log('Recent notifications loaded:', notifications.length);
    } catch (error) {
      console.error('Failed to load recent notifications:', error);
      // Don't show error to user, just log it
    }
  }

  renderNotificationsTable() {
    const tbody = document.getElementById('notifications-tbody');
    if (!tbody) return;

    tbody.innerHTML = '';

    if (this.recentNotifications.length === 0) {
      tbody.innerHTML = `
        <tr>
          <td colspan="6" style="text-align: center; padding: 2rem; color: var(--backoffice-text-muted);">
            No notifications sent yet
          </td>
        </tr>
      `;
      return;
    }

    this.recentNotifications.forEach(notification => {
      const row = document.createElement('tr');
      
      const createdDate = new Date(notification.created_at).toLocaleString();
      const typeBadge = this.getTypeBadge(notification.type);
      const recipientsText = this.getRecipientsText(notification);
      
      row.innerHTML = `
        <td>${createdDate}</td>
        <td>${notification.title}</td>
        <td>${typeBadge}</td>
        <td>${recipientsText}</td>
        <td>${notification.is_read ? 'Read' : 'Unread'}</td>
        <td>
          <button class="btn btn-ghost btn-sm" onclick="window.backofficeNotifications.viewNotification('${notification.id}')">
            View
          </button>
        </td>
      `;
      
      tbody.appendChild(row);
    });
  }

  getTypeBadge(type) {
    const badges = {
      info: '<span style="color: var(--backoffice-info);">Information</span>',
      success: '<span style="color: var(--backoffice-success);">Success</span>',
      warning: '<span style="color: var(--backoffice-warning);">Warning</span>',
      error: '<span style="color: var(--backoffice-error);">Error</span>',
      system: '<span style="color: var(--backoffice-primary);">System</span>'
    };
    return badges[type] || badges.info;
  }

  getRecipientsText(notification) {
    // This would need to be enhanced to show actual recipients
    // For now, show a generic text
    return 'Users';
  }

  validateForm() {
    const title = document.getElementById('notification-title').value.trim();
    const message = document.getElementById('notification-message').value.trim();
    const recipientType = document.getElementById('recipient-type').value;
    
    let isValid = true;

    if (!title) {
      isValid = false;
    }

    if (!message) {
      isValid = false;
    }

    if (recipientType === 'single' || recipientType === 'multiple') {
      const userSelect = document.getElementById('user-select');
      if (!userSelect.value) {
        isValid = false;
      }
    }

    // Enable/disable send button
    const sendBtn = document.querySelector('.btn-primary');
    if (sendBtn) {
      sendBtn.disabled = !isValid;
    }

    return isValid;
  }

  async sendNotification() {
    try {
      if (!this.validateForm()) {
        if (window.Notify) {
          window.Notify.error('Please fill in all required fields');
        }
        return;
      }

      const recipientType = document.getElementById('recipient-type').value;
      const title = document.getElementById('notification-title').value.trim();
      const message = document.getElementById('notification-message').value.trim();
      const type = document.getElementById('notification-type').value;

      const notificationData = {
        title,
        message,
        type,
        metadata: {
          sent_via: 'backoffice',
          sent_at: new Date().toISOString()
        }
      };

      let result;

      switch (recipientType) {
        case 'single':
          const userId = document.getElementById('user-select').value;
          result = await window.API.sendNotificationToUser(this.currentUser.id, userId, notificationData);
          break;
        
        case 'multiple':
          const selectedOptions = Array.from(document.getElementById('user-select').selectedOptions);
          const userIds = selectedOptions.map(option => option.value);
          result = await window.API.sendNotificationToMultipleUsers(this.currentUser.id, userIds, notificationData);
          break;
        
        case 'all':
          result = await window.API.sendNotificationToAllUsers(this.currentUser.id, notificationData);
          break;
      }

      if (result.ok) {
        if (window.Notify) {
          window.Notify.success(result.message || 'Notification sent successfully!');
        }
        
        // Clear form
        this.clearForm();
        
        // Refresh recent notifications
        await this.loadRecentNotifications();
      } else {
        throw new Error(result.error || 'Failed to send notification');
      }
    } catch (error) {
      console.error('Failed to send notification:', error);
      if (window.Notify) {
        window.Notify.error('Failed to send notification: ' + error.message);
      }
    }
  }

  clearForm() {
    document.getElementById('notification-title').value = '';
    document.getElementById('notification-message').value = '';
    document.getElementById('notification-type').value = 'info';
    document.getElementById('recipient-type').value = 'single';
    document.getElementById('user-select').selectedIndex = 0;
    
    this.handleRecipientTypeChange('single');
    this.validateForm();
  }

  async refreshNotifications() {
    try {
      await this.loadRecentNotifications();
      if (window.Notify) {
        window.Notify.success('Notifications refreshed successfully!');
      }
    } catch (error) {
      console.error('Failed to refresh notifications:', error);
      if (window.Notify) {
        window.Notify.error('Failed to refresh notifications');
      }
    }
  }

  viewNotification(notificationId) {
    // Implementation for viewing notification details
    console.log('View notification:', notificationId);
    // This could open a modal with notification details
  }

  redirectToLogin() {
    window.location.href = '/login.html';
  }

  async logout() {
    try {
      await window.AuthService.signOut();
      window.location.href = '/login.html';
    } catch (error) {
      console.error('Logout failed:', error);
      if (window.Notify) {
        window.Notify.error('Failed to logout');
      }
    }
  }
}

// Initialize when DOM is ready
window.backofficeNotifications = new BackOfficeNotifications();
