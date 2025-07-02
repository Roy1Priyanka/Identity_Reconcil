# Supabase Setup Guide for Identity Reconciliation Service

This guide will help you set up Supabase as the database backend for the Identity Reconciliation Service.

## Prerequisites

- A Supabase account (free tier available at [supabase.com](https://supabase.com))
- Node.js 16+ installed on your system

## Step 1: Create a Supabase Project

1. **Sign up/Login** to [Supabase](https://supabase.com)
2. **Create a new project**:

   - Click "New Project"
   - Choose your organization
   - Give your project a name (e.g., "identity-reconciliation")
   - Set a strong database password
   - Choose your region (closest to your users)
   - Click "Create new project"

3. **Wait for setup** (usually takes 1-2 minutes)

## Step 2: Get Your Project Credentials

Once your project is ready:

1. **Go to Settings** → **API**
2. **Copy the following values**:

   - **Project URL** (e.g., `https://your-project-ref.supabase.co`)
   - **anon/public key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)
   - **service_role key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

3. **Get Database Connection String**:
   - Go to **Settings** → **Database**
   - Find "Connection string" → "Nodejs"
   - Copy the connection string (it looks like: `postgresql://postgres:[password]@db.your-project-ref.supabase.co:5432/postgres`)
   - Replace `[password]` with your actual database password

## Step 3: Set Up the Database Schema

1. **Open the SQL Editor** in your Supabase dashboard
2. **Copy and paste** the entire content from `database/supabase-setup.sql`
3. **Run the script** by clicking "Run"
4. **Verify success** - you should see "Success. No rows returned" message

## Step 4: Configure Environment Variables

1. **Copy** `.env.example` to `.env`:

   ```bash
   cp .env.example .env
   ```

2. **Update** `.env` with your Supabase credentials:

   ```bash
   # Server Configuration
   PORT=3000
   NODE_ENV=development

   # Supabase Configuration
   SUPABASE_URL=https://your-project-ref.supabase.co
   SUPABASE_ANON_KEY=your_actual_anon_key_here
   SUPABASE_SERVICE_ROLE_KEY=your_actual_service_role_key_here

   # Database Configuration
   DATABASE_URL=postgresql://postgres:your_password@db.your-project-ref.supabase.co:5432/postgres

   # Rate Limiting
   RATE_LIMIT_WINDOW_MS=900000
   RATE_LIMIT_MAX_REQUESTS=100

   # Security
   CORS_ORIGIN=*
   ```

## Step 5: Install Dependencies and Run

1. **Install dependencies**:

   ```bash
   npm install
   ```

2. **Start the service**:

   ```bash
   npm run dev
   ```

3. **Test the connection**:
   ```bash
   curl http://localhost:3000/api/health
   ```

## Step 6: Verify Database Setup

You can verify your setup by:

1. **Testing the API**:

   ```bash
   curl -X POST http://localhost:3000/api/identify \
     -H "Content-Type: application/json" \
     -d '{"email": "test@example.com", "phoneNumber": "+1234567890"}'
   ```

2. **Check in Supabase Dashboard**:
   - Go to **Table Editor**
   - You should see the `contacts` table
   - After running the test above, you should see one row of data

## Security Considerations

### Row Level Security (RLS)

The setup script enables RLS on the contacts table. By default, it allows all operations for the service role. For production:

1. **Review the RLS policies** in `database/supabase-setup.sql`
2. **Adjust policies** based on your authentication requirements
3. **Test your policies** thoroughly

### API Key Usage

- **Use `SUPABASE_SERVICE_ROLE_KEY`** for server-side operations (recommended)
- **Use `SUPABASE_ANON_KEY`** for client-side operations (if needed)
- **Never expose service role key** in client-side code

## Troubleshooting

### Common Issues

1. **Connection Error**:

   - Verify your `DATABASE_URL` is correct
   - Ensure your database password is correct
   - Check if your IP is whitelisted (Supabase allows all IPs by default)

2. **Authentication Error**:

   - Verify your `SUPABASE_URL` and keys are correct
   - Ensure you're using the service role key for server operations

3. **Table Not Found**:

   - Run the SQL setup script again
   - Check if the script executed successfully
   - Verify in Table Editor that the `contacts` table exists

4. **Permission Denied**:
   - Check your RLS policies
   - Ensure you're using the correct API key
   - Verify the service role has proper permissions

### Testing Connection

You can test your Supabase connection independently:

```javascript
const { createClient } = require("@supabase/supabase-js");

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function testConnection() {
  try {
    const { data, error } = await supabase
      .from("contacts")
      .select("count(*)")
      .single();

    if (error) throw error;
    console.log("Connection successful!", data);
  } catch (error) {
    console.error("Connection failed:", error);
  }
}

testConnection();
```

## Production Deployment

For production deployment:

1. **Use environment-specific projects** (separate dev/staging/prod)
2. **Enable additional security features** in Supabase
3. **Configure proper RLS policies**
4. **Set up monitoring and alerts**
5. **Use connection pooling** for high-traffic applications
6. **Regular database backups** (automatic in Supabase Pro)

## Database Migration

If you need to modify the schema later:

1. **Create migration scripts** in Supabase SQL Editor
2. **Test migrations** in development first
3. **Apply migrations** to production during maintenance windows
4. **Keep migration history** for rollback purposes

## Support

- **Supabase Documentation**: [supabase.com/docs](https://supabase.com/docs)
- **Community**: [GitHub Discussions](https://github.com/supabase/supabase/discussions)
- **Status Page**: [status.supabase.com](https://status.supabase.com)

---

Your Identity Reconciliation Service is now ready to use Supabase as the database backend! 🚀
