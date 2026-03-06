export function corsHeaders(origin?: string) {
  const allowedOrigins = [
    "http://localhost:8080",
    "http://localhost:3000", 
    "https://localhost:8080",
    "https://localhost:3000"
  ];
  
  const isDev = allowedOrigins.includes(origin || "") || 
                (origin && (origin.includes("localhost") || origin.includes("127.0.0.1")));
  
  return {
    "Access-Control-Allow-Origin": isDev ? origin || "*" : "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "GET, POST, PUT, PATCH, DELETE, OPTIONS",
    "Access-Control-Max-Age": "86400",
  };
}

export function preflight(req: Request): Response | null {
  if (req.method === "OPTIONS") {
    const origin = req.headers.get("origin") || undefined;
    return new Response(null, { 
      status: 204, 
      headers: corsHeaders(origin) 
    });
  }
  return null;
}

export function json(data: unknown, status = 200, origin?: string) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders(origin),                 // ✅ ALWAYS present
      "content-type": "application/json",
    },
  });
}

export function err(code: string, status = 400, detail?: string, origin?: string) {
  return json({
    ok: false,
    error: code,
    ...(detail && { detail })
  }, status, origin);
}
