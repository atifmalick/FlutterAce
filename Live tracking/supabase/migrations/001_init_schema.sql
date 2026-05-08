-- ============================================================================
-- CIRCLEGUARD - SUPABASE DATABASE SCHEMA
-- Phase 1: Infrastructure
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- TABLE: profiles
-- Description: User profiles with location tracking
-- ============================================================================
CREATE TABLE public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  avatar_url TEXT,
  last_lat DOUBLE PRECISION,
  last_lng DOUBLE PRECISION,
  is_online BOOLEAN DEFAULT FALSE,
  battery_level SMALLINT DEFAULT 100,
  last_seen TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_profiles_is_online ON public.profiles(is_online);
CREATE INDEX idx_profiles_last_seen ON public.profiles(last_seen DESC);
CREATE INDEX idx_profiles_location ON public.profiles (last_lat, last_lng);

-- Enable Realtime on profiles table
ALTER TABLE public.profiles REPLICA IDENTITY FULL;

-- ============================================================================
-- TABLE: circles
-- Description: User groups (families, friend groups)
-- ============================================================================
CREATE TABLE public.circles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  invite_code TEXT UNIQUE NOT NULL,
  admin_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  description TEXT,
  color HEX,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_circles_admin_id ON public.circles(admin_id);
CREATE INDEX idx_circles_invite_code ON public.circles(invite_code);
CREATE INDEX idx_circles_is_active ON public.circles(is_active);

-- ============================================================================
-- TABLE: circle_members
-- Description: Membership mapping between users and circles
-- ============================================================================
CREATE TABLE public.circle_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  circle_id UUID REFERENCES public.circles(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  role TEXT DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(circle_id, user_id)
);

CREATE INDEX idx_circle_members_circle_id ON public.circle_members(circle_id);
CREATE INDEX idx_circle_members_user_id ON public.circle_members(user_id);

-- ============================================================================
-- TABLE: geofences
-- Description: Safe zones created by admins
-- ============================================================================
CREATE TABLE public.geofences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  circle_id UUID REFERENCES public.circles(id) ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  radius_meters INTEGER NOT NULL CHECK (radius_meters > 0),
  created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  color TEXT DEFAULT '#43A047',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_geofences_circle_id ON public.geofences(circle_id);
CREATE INDEX idx_geofences_location ON public.geofences (latitude, longitude);

-- ============================================================================
-- TABLE: geofence_events
-- Description: Log of when users enter/exit geofences
-- ============================================================================
CREATE TABLE public.geofence_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  geofence_id UUID REFERENCES public.geofences(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  event_type TEXT NOT NULL CHECK (event_type IN ('entered', 'exited')),
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_geofence_events_user_id ON public.geofence_events(user_id);
CREATE INDEX idx_geofence_events_geofence_id ON public.geofence_events(geofence_id);
CREATE INDEX idx_geofence_events_created_at ON public.geofence_events(created_at DESC);

-- ============================================================================
-- ROW-LEVEL SECURITY POLICIES
-- ============================================================================

-- Profiles: Users can see their own profile and circle members' profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can view circle members' profiles"
  ON public.profiles FOR SELECT
  USING (
    id IN (
      SELECT cm.user_id FROM circle_members cm
      WHERE cm.circle_id IN (
        SELECT circle_id FROM circle_members WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Circles: Members can view their circles
ALTER TABLE public.circles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Circle members can view the circle"
  ON public.circles FOR SELECT
  USING (
    id IN (
      SELECT circle_id FROM circle_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Only admin can update circle"
  ON public.circles FOR UPDATE
  USING (admin_id = auth.uid());

CREATE POLICY "Only admin can delete circle"
  ON public.circles FOR DELETE
  USING (admin_id = auth.uid());

CREATE POLICY "Users can create circles"
  ON public.circles FOR INSERT
  WITH CHECK (admin_id = auth.uid());

-- Circle Members: Visibility for circle members
ALTER TABLE public.circle_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their circle memberships"
  ON public.circle_members FOR SELECT
  USING (
    user_id = auth.uid() OR
    circle_id IN (
      SELECT circle_id FROM circle_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can join circles"
  ON public.circle_members FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Admins can manage circle members"
  ON public.circle_members FOR UPDATE
  USING (
    circle_id IN (
      SELECT id FROM circles WHERE admin_id = auth.uid()
    )
  );

-- Geofences: Circle members can view and admins can manage
ALTER TABLE public.geofences ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Circle members can view geofences"
  ON public.geofences FOR SELECT
  USING (
    circle_id IN (
      SELECT circle_id FROM circle_members WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Circle admins can manage geofences"
  ON public.geofences FOR INSERT
  WITH CHECK (
    circle_id IN (
      SELECT id FROM circles WHERE admin_id = auth.uid()
    )
  );

CREATE POLICY "Circle admins can update geofences"
  ON public.geofences FOR UPDATE
  USING (
    circle_id IN (
      SELECT id FROM circles WHERE admin_id = auth.uid()
    )
  );

CREATE POLICY "Circle admins can delete geofences"
  ON public.geofences FOR DELETE
  USING (
    circle_id IN (
      SELECT id FROM circles WHERE admin_id = auth.uid()
    )
  );

-- Geofence Events: Users can view events for their circles
ALTER TABLE public.geofence_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view geofence events in their circles"
  ON public.geofence_events FOR SELECT
  USING (
    geofence_id IN (
      SELECT id FROM geofences
      WHERE circle_id IN (
        SELECT circle_id FROM circle_members WHERE user_id = auth.uid()
      )
    )
  );

CREATE POLICY "System can insert geofence events"
  ON public.geofence_events FOR INSERT
  WITH CHECK (true);

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to generate unique 6-digit invite codes
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
  code TEXT;
  EXISTS BOOLEAN;
BEGIN
  LOOP
    code := LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
    EXISTS := (SELECT COUNT(*) FROM circles WHERE invite_code = code) > 0;
    EXIT WHEN NOT EXISTS;
  END LOOP;
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Function to update user's last_seen timestamp
CREATE OR REPLACE FUNCTION update_last_seen()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  NEW.last_seen = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update last_seen on profiles table
CREATE TRIGGER update_profiles_last_seen
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_last_seen();

-- ============================================================================
-- INITIAL DATA / COMMENTS
-- ============================================================================

COMMENT ON TABLE public.profiles IS 'User profiles with real-time location data';
COMMENT ON TABLE public.circles IS 'Groups of users who share location';
COMMENT ON TABLE public.circle_members IS 'Membership records for circles';
COMMENT ON TABLE public.geofences IS 'Safe zones with geofencing alerts';
COMMENT ON TABLE public.geofence_events IS 'Historical log of geofence entries/exits';
