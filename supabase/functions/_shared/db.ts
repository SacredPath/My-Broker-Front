/**
 * Database Helpers
 */

export async function queryWithThrow<T>(
  query: Promise<{ data: T | null; error: any }>
): Promise<T> {
  const { data, error } = await query;
  if (error) {
    throw error;
  }
  if (!data) {
    throw new Error('Query returned no data');
  }
  return data;
}

export async function queryMaybe<T>(
  query: Promise<{ data: T | null; error: any }>
): Promise<T | null> {
  const { data, error } = await query;
  if (error) {
    throw error;
  }
  return data;
}
