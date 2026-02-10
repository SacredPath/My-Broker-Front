// Minimal RBAC implementation
export function getPermissionsForRole(role: string): string[] {
  const rolePermissions: Record<string, string[]> = {
    user: [],
    support: ["bo.read"],
    superadmin: ["bo.read", "bo.write"]
  };
  
  return rolePermissions[role] || [];
}

export function requireRole(role: string, allowedRoles: string[]): boolean {
  return allowedRoles.includes(role);
}
