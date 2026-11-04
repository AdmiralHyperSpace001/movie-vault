-- ═══════════════════════════════════════════════════════════════
--  Movie Vault — Supabase Security Setup
--  Run this in: Supabase Dashboard → SQL Editor → New Query
-- ═══════════════════════════════════════════════════════════════

-- ── 1. Create the movies table (skip if already exists) ────────
CREATE TABLE IF NOT EXISTS public.movies (
  id         uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id    uuid REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  imdb_id    text NOT NULL,
  title      text NOT NULL,
  year       text,
  poster     text,
  rating     text,
  genre      text[]  DEFAULT '{}',
  language   text[]  DEFAULT '{}',
  country    text,
  director   text,
  actors     text,
  plot       text,
  runtime    text,
  rated      text,
  user_tags  text[]  DEFAULT '{}',
  notes      text    DEFAULT '',
  watched    boolean DEFAULT false,
  added_at   timestamptz DEFAULT now(),
  UNIQUE(user_id, imdb_id)
);

-- ── 2. Enable Row Level Security ───────────────────────────────
ALTER TABLE public.movies ENABLE ROW LEVEL SECURITY;

-- ── 3. Drop old policies if they exist (safe to re-run) ────────
DROP POLICY IF EXISTS "Users can view their own movies"   ON public.movies;
DROP POLICY IF EXISTS "Users can insert their own movies" ON public.movies;
DROP POLICY IF EXISTS "Users can update their own movies" ON public.movies;
DROP POLICY IF EXISTS "Users can delete their own movies" ON public.movies;

-- ── 4. Create strict per-user RLS policies ─────────────────────
-- SELECT: users only see their own rows
CREATE POLICY "Users can view their own movies"
  ON public.movies FOR SELECT
  USING (auth.uid() = user_id);

-- INSERT: users can only insert rows where user_id = their own id
CREATE POLICY "Users can insert their own movies"
  ON public.movies FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- UPDATE: users can only update their own rows
CREATE POLICY "Users can update their own movies"
  ON public.movies FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- DELETE: users can only delete their own rows
CREATE POLICY "Users can delete their own movies"
  ON public.movies FOR DELETE
  USING (auth.uid() = user_id);

-- ── 5. Grant table access (required after Oct 30, 2026 Supabase change) ─
-- Only grant to 'authenticated' — anon users cannot see any data
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.movies TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- ── 6. Revoke public/anon access (security hardening) ──────────
REVOKE ALL ON TABLE public.movies FROM anon;
REVOKE ALL ON TABLE public.movies FROM public;

-- ── 7. Add an index for fast per-user queries ───────────────────
CREATE INDEX IF NOT EXISTS idx_movies_user_id  ON public.movies(user_id);
CREATE INDEX IF NOT EXISTS idx_movies_added_at ON public.movies(user_id, added_at DESC);
CREATE INDEX IF NOT EXISTS idx_movies_imdb_id  ON public.movies(user_id, imdb_id);

-- ══════════════════════════════════════════════════════════════
--  Done! Your movies table is now:
--  ✓ Row Level Security enforced (users only see their own data)
--  ✓ Explicitly GRANTed for authenticated users (Supabase 2026 policy)
--  ✓ Anon access revoked
--  ✓ Indexed for performance
-- ══════════════════════════════════════════════════════════════

