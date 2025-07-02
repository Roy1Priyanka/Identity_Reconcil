# Identity_Reconciliation_Backend
Hi! I built this backend project to solve a real-world problem of identifying and linking users who may have registered using different combinations of email and phone number.
This service helps recognize users as the same person even if they’ve signed up multiple times using different contact details.

What This Project Does
Users sometimes register with only email, only phone, or both—but with different details. This backend checks if the user already exists using email or phone, and links them under one primary contact, while others become secondary.

Tech Stack
Node.js + Express for backend
Supabase (PostgreSQL) as database
SQL triggers + Row Level Security for data consistency and security

How I Built It
1. Supabase Setup
Created a project and ran my Sql.sql script
Made a contacts table with indexes
Enabled RLS and added secure access policies

2. Environment Setup
Used .env file to store Supabase URL, keys, DB string, and some server configs

3. API Development
Built one main API:

bash
POST /api/identify
It checks if the contact already exists (by email or phone). If found, it links them. If not, it creates a new one.

How to Run This Project
- Clone this repo
- Set up a Supabase project
- Run the SQL setup
- Fill in your .env file
- Run the server locally:

bash
- npm install
- npm run dev

Future Improvements
- Add proper authentication for end users
- Build a frontend dashboard to view linked users
- Add logging & monitoring for production
