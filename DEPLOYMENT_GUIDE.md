# Movie Vault — Deployment Guide

Follow these steps in order. Takes about 15 minutes total.

---

## How secrets work in this version

The app **never stores API keys in the HTML source**. Instead, when the app loads it fetches `/api/config` — a tiny Vercel serverless function that reads your keys from **Vercel environment variables** and sends them to the browser. This means:

- Your keys don't appear anywhere in the files you deploy
- Anyone who views your page source just sees a `fetch('/api/config')` call
- You set the keys once in the Vercel dashboard, never touch the code

---

## Project structure

After following this guide you'll have a folder that looks like this:

```
movie-vault/
├── index.html        ← the app
├── vercel.json       ← routing config
└── api/
    └── config.js     ← serverless function that serves your keys
```

All three files are provided to you. Do not edit them — just deploy the folder.

---

## STEP 1 — Get your free OMDB API Key (2 min)

1. Go to https://www.omdbapi.com/apikey.aspx
2. Select **Free** tier → enter your email → Submit
3. They email you a key like `a1b2c3d4`
4. Keep this handy — you'll paste it into Vercel later

---

## STEP 2 — Create your Supabase project (5 min)

1. Go to https://supabase.com and click **Start for free**
2. Sign up with GitHub or email
3. Click **New project**
4. Fill in:
   - **Name:** movie-vault (or anything)
   - **Database Password:** pick a strong password (save it somewhere)
   - **Region:** Singapore (closest to Pakistan)
5. Click **Create new project** — wait ~1 minute for it to set up

---

## STEP 3 — Create the database table (3 min)

1. In your Supabase project, click **SQL Editor** in the left sidebar
2. Click **New query**
3. Paste this SQL block and click **Run**:

```sql
-- Create the movies table
CREATE TABLE movies (
  id          UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  imdb_id     TEXT NOT NULL,
  title       TEXT NOT NULL,
  year        TEXT,
  poster      TEXT,
  rating      TEXT,
  genre       TEXT[] DEFAULT '{}',
  language    TEXT[] DEFAULT '{}',
  country     TEXT DEFAULT '',
  director    TEXT DEFAULT '',
  actors      TEXT DEFAULT '',
  plot        TEXT DEFAULT '',
  runtime     TEXT DEFAULT '',
  rated       TEXT DEFAULT '',
  user_tags   TEXT[] DEFAULT '{}',
  notes       TEXT DEFAULT '',
  watched     BOOLEAN DEFAULT false,
  added_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security: each user can only see and edit their own movies
ALTER TABLE movies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own movies"
  ON movies FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

4. You should see **"Success. No rows returned"** — that means it worked.

---

## STEP 4 — Get your Supabase keys (1 min)

1. In Supabase, click **Project Settings** (gear icon, bottom left)
2. Click **API** in the left menu
3. Copy these two values:
   - **Project URL** — looks like `https://abcdefgh.supabase.co`
   - **anon public** key — long string starting with `eyJ...`

---

## STEP 5 — Deploy to Vercel (5 min)

1. Go to https://vercel.com and sign up (free — use GitHub or email)
2. Click **Add New… → Project**
3. Choose **"Deploy from your computer"** and drag the entire `movie-vault/` **folder** into the deploy area
   > ⚠️ Drag the **folder**, not individual files. Vercel needs to see `index.html`, `vercel.json`, and `api/config.js` together.
4. Before clicking Deploy, click **Environment Variables** and add all three:

   | Name | Value |
   |------|-------|
   | `SUPABASE_URL` | `https://abcdefgh.supabase.co` (your actual URL) |
   | `SUPABASE_ANON_KEY` | `eyJhbGc...` (your actual anon key) |
   | `OMDB_API_KEY` | `a1b2c3d4` (your actual OMDB key) |

5. Click **Deploy**
6. Vercel gives you a URL like `https://movie-vault-abc123.vercel.app` 🎉

> **If you forgot to add env vars before deploying:** Go to your project in Vercel → Settings → Environment Variables → add them there → then go to Deployments → click the three dots on your latest deployment → **Redeploy**.

---

## STEP 6 — First use

1. Open your live URL
2. You'll see the Sign In / Create Account screen immediately — no setup required
3. Click **Create Account** → enter your email + password → sign up
4. Check your email → click the confirmation link Supabase sends
5. Sign in — your vault is ready

---

## Notes

- **Each user has their own vault.** Row Level Security in Supabase ensures no one can see anyone else's movies.
- **The Supabase anon key is safe to expose.** It's designed to be public — RLS is what protects your data, not key secrecy. This is standard Supabase architecture.
- **Free limits are generous:** Supabase free tier gives you 500MB storage and 50,000 monthly active users. A personal movie vault will never come close.
- **Forgot password?** You can add a forgot-password flow by request — Supabase handles it automatically.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| White screen / "Configuration Error" message | Check all 3 env vars are set in Vercel and redeploy |
| "Invalid API key" on sign in | Double-check `SUPABASE_ANON_KEY` in Vercel env vars |
| Movies not saving | Make sure you ran the SQL in Step 3 correctly |
| No movie results | Check `OMDB_API_KEY` is set correctly in Vercel |
| Confirmation email not arriving | Check spam folder |
| `/api/config` returns 500 | One or more env vars is missing or misspelled |
