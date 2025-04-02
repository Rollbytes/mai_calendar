-- Create events table
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  color TEXT NOT NULL,
  is_all_day BOOLEAN DEFAULT FALSE,
  location_path TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Enable Row Level Security
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Create policy for authenticated users to select their own events
CREATE POLICY "Users can view their own events" ON events
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create policy for authenticated users to insert their own events
CREATE POLICY "Users can insert their own events" ON events
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create policy for authenticated users to update their own events
CREATE POLICY "Users can update their own events" ON events
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Create policy for authenticated users to delete their own events
CREATE POLICY "Users can delete their own events" ON events
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create a trigger to automatically update updated_at on row update
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_events_updated_at
  BEFORE UPDATE ON events
  FOR EACH ROW
  EXECUTE PROCEDURE update_updated_at_column(); 