import { adminClient } from "./auth.ts";

interface AuditEntry {
  actor_user_id: string;
  actor_role: string;
  action: string;
  target_user_id?: string;
  before?: any;
  after?: any;
  reason?: string;
}

export async function writeAudit(entry: AuditEntry): Promise<void> {
  const supabase = adminClient();
  
  const { error } = await supabase
    .from('audit_log')
    .insert({
      actor_user_id: entry.actor_user_id,
      actor_role: entry.actor_role,
      action: entry.action,
      target_user_id: entry.target_user_id,
      before: entry.before,
      after: entry.after,
      reason: entry.reason,
      created_at: new Date().toISOString()
    });

  if (error) {
    console.error('Failed to write audit log:', error);
    // Don't throw - audit failures shouldn't break the main operation
  }
}
