-- users (managers, residents, staff)
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT,
  full_name TEXT,
  role TEXT NOT NULL, -- 'resident'|'manager'|'staff'
  phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  last_seen TIMESTAMP WITH TIME ZONE
);

-- estates
CREATE TABLE estates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- houses/units
CREATE TABLE houses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  estate_id UUID REFERENCES estates(id) ON DELETE CASCADE,
  number TEXT,
  owner_id UUID REFERENCES users(id),
  status TEXT, -- 'occupied'|'vacant'
  balance BIGINT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- devices
CREATE TABLE devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  estate_id UUID REFERENCES estates(id),
  name TEXT,
  type TEXT, -- 'light'|'sensor'|'water_pump'|'gate'
  topic TEXT, -- mqtt topic
  meta JSONB,
  state JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- device telemetry
CREATE TABLE device_telemetry (
  id BIGSERIAL PRIMARY KEY,
  device_id UUID REFERENCES devices(id),
  ts TIMESTAMP WITH TIME ZONE DEFAULT now(),
  payload JSONB
);

-- payments
CREATE TABLE payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  estate_id UUID REFERENCES estates(id),
  amount BIGINT NOT NULL,
  currency TEXT DEFAULT 'NGN',
  status TEXT, -- 'pending'|'paid'|'failed'
  external_ref TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- requests (maintenance)
CREATE TABLE requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  house_id UUID REFERENCES houses(id),
  user_id UUID REFERENCES users(id),
  category TEXT,
  description TEXT,
  status TEXT DEFAULT 'pending',
  assigned_to UUID, -- staff user id
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- community posts
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID REFERENCES users(id),
  estate_id UUID REFERENCES estates(id),
  content TEXT,
  image_url TEXT,
  video_url TEXT,
  pinned BOOLEAN DEFAULT false,
  allow_comments BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id),
  author_id UUID REFERENCES users(id),
  text TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
