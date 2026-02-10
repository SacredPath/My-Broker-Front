import { corsHeaders } from './cors.ts';

export function requestId(): string {
  return crypto.randomUUID();
}

export function ok(req: Request, data: any, status = 200): Response {
  return new Response(JSON.stringify({
    ok: true,
    data,
    requestId: requestId()
  }), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders(req)
    }
  });
}

export function fail(req: Request, httpStatus: number, code: string, error: string, details?: any): Response {
  return new Response(JSON.stringify({
    ok: false,
    error,
    code,
    requestId: requestId(),
    ...(details && { details })
  }), {
    status: httpStatus,
    headers: {
      "Content-Type": "application/json",
      ...corsHeaders(req)
    }
  });
}
