-- ============================================================
-- MediPredict AI — Initial Database Schema
-- ============================================================

-- 1. Create the profiles table in the public schema
CREATE TABLE IF NOT EXISTS public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT NOT NULL DEFAULT '',
  medical_history_summary TEXT DEFAULT '',
  blood_group TEXT DEFAULT '',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Create the health_logs table
CREATE TABLE IF NOT EXISTS public.health_logs (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  symptom_tags   JSONB NOT NULL DEFAULT '[]',
  severity_score INT CHECK (severity_score BETWEEN 1 AND 10),
  ai_notes       TEXT DEFAULT '',
  timestamp      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Create the medical_reports table
CREATE TABLE IF NOT EXISTS public.medical_reports (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  file_url         TEXT NOT NULL,
  extracted_text   TEXT DEFAULT '',
  ai_analysis_json JSONB DEFAULT '{}',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Enable RLS
ALTER TABLE public.profiles        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.health_logs     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medical_reports ENABLE ROW LEVEL SECURITY;

-- 5. Clean up existing policies (idempotency)
DO $$ 
BEGIN
    DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
    DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
    DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
    
    DROP POLICY IF EXISTS "Users can view own health logs" ON public.health_logs;
    DROP POLICY IF EXISTS "Users can insert own health logs" ON public.health_logs;
    DROP POLICY IF EXISTS "Users can update own health logs" ON public.health_logs;
    DROP POLICY IF EXISTS "Users can delete own health logs" ON public.health_logs;
    
    DROP POLICY IF EXISTS "Users can view own reports" ON public.medical_reports;
    DROP POLICY IF EXISTS "Users can insert own reports" ON public.medical_reports;
    DROP POLICY IF EXISTS "Users can update own reports" ON public.medical_reports;
    DROP POLICY IF EXISTS "Users can delete own reports" ON public.medical_reports;
END $$;

-- 6. Create Policies
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can view own health logs" ON public.health_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own health logs" ON public.health_logs FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own health logs" ON public.health_logs FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own health logs" ON public.health_logs FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own reports" ON public.medical_reports FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own reports" ON public.medical_reports FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reports" ON public.medical_reports FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own reports" ON public.medical_reports FOR DELETE USING (auth.uid() = user_id);

-- 7. Trigger to auto-create profile on signup
-- We use public.profiles explicitly inside the function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', ''));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
