// api/config.js — Vercel serverless function
// Reads secrets from environment variables and returns them to the frontend.
// Keys never appear in the client bundle — they live in Vercel env vars.

export default function handler(req, res) {
  // ── Security headers ───────────────────────────────────────────────────
  // Never expose this endpoint to other origins.
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, private');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'no-referrer');

  // Only allow GET
  if (req.method !== 'GET') {
    res.setHeader('Allow', 'GET');
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Block requests that don't come from the same origin (basic CSRF guard).
  // On Vercel the host header is always the canonical deployment domain.
  const origin = req.headers['origin'];
  const host   = req.headers['host'];
  if (origin && host && !origin.endsWith(host)) {
    return res.status(403).json({ error: 'Forbidden' });
  }

  // ── Read secrets from environment (set in Vercel dashboard) ───────────
  const url  = process.env.SUPABASE_URL;
  const key  = process.env.SUPABASE_ANON_KEY;
  const omdb = process.env.OMDB_API_KEY;

  if (!url || !key || !omdb) {
    // Generic error — do NOT reveal which variable is missing
    return res.status(500).json({ error: 'Server configuration error' });
  }

  return res.status(200).json({ url, key, omdb });
}
