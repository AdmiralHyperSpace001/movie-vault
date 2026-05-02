// api/config.js — Vercel serverless function
// Reads secrets from environment variables and returns them to the frontend.
// The frontend never has these baked into its source — it fetches them at runtime.

export default function handler(req, res) {
  const url  = process.env.SUPABASE_URL;
  const key  = process.env.SUPABASE_ANON_KEY;
  const omdb = process.env.OMDB_API_KEY;

  if (!url || !key || !omdb) {
    return res.status(500).json({
      error: 'One or more environment variables are missing. Check your Vercel project settings.'
    });
  }

  // Allow only same-origin requests (your own deployed app)
  res.setHeader('Cache-Control', 'no-store');
  res.status(200).json({ url, key, omdb });
}
