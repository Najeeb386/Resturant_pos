-- ==========================================
-- SUPABASE SCHEMA UPDATE FOR SAAS SUPERADMIN
-- ==========================================
-- Run this script inside your Supabase Dashboard SQL Editor (https://supabase.com)
-- to create missing SaaS subscription plans and expenses tables.

-- 1. Add SaaS subscription columns to the restaurants table
ALTER TABLE public.restaurants 
ADD COLUMN IF NOT EXISTS plan_name TEXT DEFAULT 'Premium SaaS',
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Active';

-- 2. Create the subscription_plans table
CREATE TABLE IF NOT EXISTS public.subscription_plans (
    name TEXT PRIMARY KEY,
    price NUMERIC NOT NULL,
    billing TEXT NOT NULL,
    description TEXT
);

-- 3. Create the saas_expenses table
CREATE TABLE IF NOT EXISTS public.saas_expenses (
    id TEXT PRIMARY KEY,
    description TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    category TEXT NOT NULL,
    date TEXT NOT NULL
);

-- 4. Disable Row Level Security (RLS) to allow direct client CRUD operations (aligning with current setup)
ALTER TABLE public.subscription_plans DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.saas_expenses DISABLE ROW LEVEL SECURITY;
