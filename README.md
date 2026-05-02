<div align="center">

<!-- Hero SVG Banner -->
<svg width="900" height="200" viewBox="0 0 900 200" fill="none" xmlns="http://www.w3.org/2000/svg">
  <rect width="900" height="200" fill="#080810"/>
  <!-- Film strip holes left -->
  <rect x="0" y="0" width="48" height="200" fill="#0c0c1a"/>
  <rect x="8" y="12" width="32" height="22" rx="4" fill="#1a1a2e"/>
  <rect x="8" y="46" width="32" height="22" rx="4" fill="#1a1a2e"/>
  <rect x="8" y="80" width="32" height="22" rx="4" fill="#1a1a2e"/>
  <rect x="8" y="114" width="32" height="22" rx="4" fill="#1a1a2e"/>
  <rect x="8" y="148" width="32" height="22" rx="4" fill="#1a1a2e"/>
  <!-- Film strip holes right -->
  <rect x="852" y="0" width="48" height="200" fill="#0c0c1a"/>
  <rect x="860" y="12" width="32" height="22" rx="4" fill="#1a1a2e"/>
  <rect x="860" y="46" width="32" height="22" rx="4" fill="#1a1a2e"/>
  <rect x="860" y="80" width="32" height="22" rx="4" fill="#1a1a2e"/>
  <rect x="860" y="114" width="32" height="22" rx="4" fill="#1a1a2e"/>
  <rect x="860" y="148" width="32" height="22" rx="4" fill="#1a1a2e"/>
  <!-- Glow -->
  <ellipse cx="450" cy="100" rx="320" ry="80" fill="#f0c040" fill-opacity="0.04"/>
  <!-- Title -->
  <text x="450" y="88" font-family="Georgia, serif" font-size="64" font-weight="700" letter-spacing="12" fill="#f0c040" text-anchor="middle">MOVIE</text>
  <text x="450" y="152" font-family="Georgia, serif" font-size="64" font-weight="700" letter-spacing="12" fill="#e4e4f0" text-anchor="middle">VAULT</text>
  <!-- Accent line -->
  <line x1="200" y1="105" x2="332" y2="105" stroke="#f0c040" stroke-width="1.5" stroke-opacity="0.4"/>
  <line x1="568" y1="105" x2="700" y2="105" stroke="#f0c040" stroke-width="1.5" stroke-opacity="0.4"/>
</svg>

<br/>

**Your personal, private film collection — built with taste.**

<br/>

![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)

</div>

---

## What is this?

Movie Vault is a **personal film collection app** — search any movie from IMDb's full database, save it to your vault, tag it, write notes, and mark it watched. Your collection syncs across every device you own, and only you can see it.

No algorithms. No recommendations. No social features. Just your movies, organised exactly how you want them.

---

## Features

<table>
<tr>
<td width="50%">

### 🎬 &nbsp;Search IMDb
Full OMDB-powered search with live results as you type. Posters, ratings, cast, director, plot, box office — everything loads instantly.

</td>
<td width="50%">

### 🏷️ &nbsp;Tag anything
Create your own tagging system. `rewatch`, `dad's pick`, `festival`, `guilty pleasure` — whatever makes sense to you.

</td>
</tr>
<tr>
<td width="50%">

### 📝 &nbsp;Personal notes
Write where you watched it, who you watched it with, your thoughts. Private, per-movie notes synced to the cloud.

</td>
<td width="50%">

### 🔍 &nbsp;Filter & sort
Filter by genre, language, your own tags, or watched status. Sort by title, year, IMDb rating, or date added.

</td>
</tr>
<tr>
<td width="50%">

### ⊞ &nbsp;Grid & list views
Switch between a cinematic poster grid and a compact list view — whichever fits how you're browsing.

</td>
<td width="50%">

### 🔒 &nbsp;Fully private
Row Level Security via Supabase. Your vault is completely invisible to other users — enforced at the database level.

</td>
</tr>
</table>

---

## Tech stack

```
Frontend        Vanilla HTML/CSS/JS — zero framework overhead
Auth + DB       Supabase (PostgreSQL + Auth)
Movie data      OMDB API (IMDb data)
Deployment      Vercel (serverless functions + static hosting)
Security        API keys stored as Vercel env vars, served via /api/config
```

No build step. No bundler. No dependencies to maintain. Open `index.html` and it's the whole app.

---

## Architecture

```
┌─────────────────────────────────────────────┐
│                  Browser                    │
│                                             │
│   index.html  ──fetch──▶  /api/config       │
│       │                   (Vercel fn)        │
│       │                       │             │
│       │              reads env vars         │
│       │              SUPABASE_URL           │
│       │              SUPABASE_ANON_KEY      │
│       │              OMDB_API_KEY           │
│       │                       │             │
│       ◀───────── config JSON ─┘             │
│       │                                     │
│       ├──▶  Supabase  (auth + movies db)    │
│       └──▶  OMDB API  (search + details)    │
└─────────────────────────────────────────────┘
```

Keys are never in the source code. The HTML just calls `/api/config` — a serverless function reads from Vercel's environment and responds. Anyone who views your repo source sees nothing sensitive.

---

## Database schema

```sql
CREATE TABLE movies (
  id          UUID PRIMARY KEY,
  user_id     UUID REFERENCES auth.users(id),  -- enforces ownership
  imdb_id     TEXT NOT NULL,
  title       TEXT NOT NULL,
  year        TEXT,
  poster      TEXT,
  rating      TEXT,
  genre       TEXT[],
  language    TEXT[],
  country     TEXT,
  director    TEXT,
  actors      TEXT,
  plot        TEXT,
  runtime     TEXT,
  rated       TEXT,
  user_tags   TEXT[] DEFAULT '{}',
  notes       TEXT  DEFAULT '',
  watched     BOOLEAN DEFAULT false,
  added_at    TIMESTAMPTZ DEFAULT NOW()
);
```

Row Level Security ensures every query is automatically scoped to the authenticated user — no application-level filtering needed.

---

## Deploy your own

Full instructions in [`DEPLOYMENT_GUIDE.md`](./DEPLOYMENT_GUIDE.md). The short version:

1. Create a free [Supabase](https://supabase.com) project and run the SQL from the guide
2. Get a free [OMDB API key](https://www.omdbapi.com/apikey.aspx)
3. Push this repo to GitHub
4. Import into [Vercel](https://vercel.com), add 3 environment variables, deploy

```
SUPABASE_URL        https://your-project.supabase.co
SUPABASE_ANON_KEY   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
OMDB_API_KEY        your_omdb_key
```

Done. Live in under 15 minutes.

---

## Project structure

```
movie-vault/
├── index.html          # The entire frontend — one file
├── vercel.json         # Routing config
├── api/
│   └── config.js       # Serverless function — serves keys from env vars
└── DEPLOYMENT_GUIDE.md # Step-by-step setup instructions
```

---

<div align="center">

Built with vanilla JS, no frameworks, no nonsense.

</div>
