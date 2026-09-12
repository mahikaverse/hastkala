-- ============================================
-- HastKala Complete Database Schema
-- Supabase PostgreSQL
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. ARTISANS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS artisans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT '',
  avatar_url TEXT DEFAULT '',
  bio TEXT DEFAULT '',
  craft_specialization TEXT DEFAULT '',
  location TEXT DEFAULT '',
  state TEXT DEFAULT '',
  years_of_experience INTEGER DEFAULT 0,
  craft_story TEXT DEFAULT '',
  contact_email TEXT,
  contact_phone TEXT,
  website TEXT,
  instagram TEXT,
  facebook TEXT,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  followers_count INTEGER DEFAULT 0,
  products_count INTEGER DEFAULT 0,
  average_rating NUMERIC(3,1) DEFAULT 0.0,
  total_reviews INTEGER DEFAULT 0
);

-- ============================================
-- 2. STORES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS stores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  artisan_id UUID REFERENCES artisans(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT '',
  slug TEXT DEFAULT '',
  description TEXT DEFAULT '',
  logo_url TEXT DEFAULT '',
  banner_url TEXT DEFAULT '',
  craft_category TEXT DEFAULT '',
  location TEXT DEFAULT '',
  state TEXT DEFAULT '',
  average_rating NUMERIC(3,1) DEFAULT 0.0,
  total_reviews INTEGER DEFAULT 0,
  total_products INTEGER DEFAULT 0,
  total_sales INTEGER DEFAULT 0,
  total_followers INTEGER DEFAULT 0,
  is_verified BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 3. PRODUCTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE,
  artisan_id UUID REFERENCES artisans(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT '',
  description TEXT DEFAULT '',
  price NUMERIC(10,2) NOT NULL DEFAULT 0,
  discount_price NUMERIC(10,2),
  category TEXT DEFAULT '',
  subcategory TEXT DEFAULT '',
  image_urls TEXT[] DEFAULT '{}',
  variants JSONB DEFAULT '[]',
  stock_quantity INTEGER DEFAULT 0,
  is_published BOOLEAN DEFAULT true,
  is_featured BOOLEAN DEFAULT false,
  craft_type TEXT,
  material TEXT,
  weight TEXT,
  dimensions TEXT,
  shipping_info TEXT,
  tags TEXT[] DEFAULT '{}',
  average_rating NUMERIC(3,1) DEFAULT 0.0,
  total_reviews INTEGER DEFAULT 0,
  total_sales INTEGER DEFAULT 0,
  views INTEGER DEFAULT 0,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  visibility TEXT DEFAULT 'private' CHECK (visibility IN ('private', 'public')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 4. B2B REQUIREMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS b2b_requirements (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  buyer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT '',
  description TEXT DEFAULT '',
  category TEXT DEFAULT '',
  material TEXT,
  craft_type TEXT,
  quantity INTEGER DEFAULT 0,
  budget_min NUMERIC(10,2),
  budget_max NUMERIC(10,2),
  delivery_location TEXT,
  deadline TIMESTAMPTZ,
  customization TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('draft', 'active', 'fulfilled', 'closed')),
  enquiries_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 5. B2B ENQUIRIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS b2b_enquiries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  buyer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  buyer_name TEXT DEFAULT '',
  artisan_id UUID REFERENCES artisans(id) ON DELETE SET NULL,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  requirement_id UUID REFERENCES b2b_requirements(id) ON DELETE SET NULL,
  message TEXT DEFAULT '',
  quantity INTEGER DEFAULT 0,
  budget NUMERIC(10,2),
  delivery_location TEXT,
  deadline TIMESTAMPTZ,
  customization TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'replied', 'accepted', 'rejected', 'closed')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 6. B2B QUOTES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS b2b_quotes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  enquiry_id UUID REFERENCES b2b_enquiries(id) ON DELETE CASCADE,
  artisan_id UUID REFERENCES artisans(id) ON DELETE SET NULL,
  quantity INTEGER DEFAULT 0,
  price_per_piece NUMERIC(10,2) NOT NULL DEFAULT 0,
  lead_time_days INTEGER DEFAULT 0,
  message TEXT DEFAULT '',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 7. B2B ORDERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS b2b_orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  buyer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  artisan_id UUID REFERENCES artisans(id) ON DELETE SET NULL,
  product_id UUID REFERENCES products(id) ON DELETE SET NULL,
  quote_id UUID REFERENCES b2b_quotes(id) ON DELETE SET NULL,
  enquiry_id UUID REFERENCES b2b_enquiries(id) ON DELETE SET NULL,
  product_name TEXT DEFAULT '',
  quantity INTEGER DEFAULT 0,
  price_per_piece NUMERIC(10,2) NOT NULL DEFAULT 0,
  total_amount NUMERIC(12,2) NOT NULL DEFAULT 0,
  lead_time_days INTEGER DEFAULT 0,
  delivery_location TEXT,
  status TEXT DEFAULT 'enquiry' CHECK (status IN ('enquiry', 'quote', 'confirmed', 'production', 'ready', 'shipped', 'delivered', 'cancelled')),
  artisan_message TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- 8. B2B SAVED ARTISANS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS b2b_saved_artisans (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  buyer_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  artisan_id UUID REFERENCES artisans(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(buyer_id, artisan_id)
);

-- ============================================
-- INDEXES for performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_products_artisan_id ON products(artisan_id);
CREATE INDEX IF NOT EXISTS idx_products_store_id ON products(store_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_visibility ON products(visibility);
CREATE INDEX IF NOT EXISTS idx_products_craft_type ON products(craft_type);

CREATE INDEX IF NOT EXISTS idx_stores_artisan_id ON stores(artisan_id);
CREATE INDEX IF NOT EXISTS idx_stores_slug ON stores(slug);

CREATE INDEX IF NOT EXISTS idx_artisans_user_id ON artisans(user_id);

CREATE INDEX IF NOT EXISTS idx_b2b_requirements_buyer_id ON b2b_requirements(buyer_id);
CREATE INDEX IF NOT EXISTS idx_b2b_requirements_status ON b2b_requirements(status);

CREATE INDEX IF NOT EXISTS idx_b2b_enquiries_buyer_id ON b2b_enquiries(buyer_id);
CREATE INDEX IF NOT EXISTS idx_b2b_enquiries_artisan_id ON b2b_enquiries(artisan_id);
CREATE INDEX IF NOT EXISTS idx_b2b_enquiries_product_id ON b2b_enquiries(product_id);
CREATE INDEX IF NOT EXISTS idx_b2b_enquiries_status ON b2b_enquiries(status);

CREATE INDEX IF NOT EXISTS idx_b2b_quotes_enquiry_id ON b2b_quotes(enquiry_id);
CREATE INDEX IF NOT EXISTS idx_b2b_quotes_artisan_id ON b2b_quotes(artisan_id);

CREATE INDEX IF NOT EXISTS idx_b2b_orders_buyer_id ON b2b_orders(buyer_id);
CREATE INDEX IF NOT EXISTS idx_b2b_orders_artisan_id ON b2b_orders(artisan_id);
CREATE INDEX IF NOT EXISTS idx_b2b_orders_status ON b2b_orders(status);

CREATE INDEX IF NOT EXISTS idx_b2b_saved_buyer_id ON b2b_saved_artisans(buyer_id);
CREATE INDEX IF NOT EXISTS idx_b2b_saved_artisan_id ON b2b_saved_artisans(artisan_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS) Policies
-- ============================================

-- Enable RLS on all tables
ALTER TABLE artisans ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_requirements ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_enquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE b2b_saved_artisans ENABLE ROW LEVEL SECURITY;

-- ARTISANS policies
CREATE POLICY "Artisans are viewable by everyone"
  ON artisans FOR SELECT
  USING (true);

CREATE POLICY "Artisans can insert their own profile"
  ON artisans FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Artisans can update their own profile"
  ON artisans FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Artisans can delete their own profile"
  ON artisans FOR DELETE
  USING (auth.uid() = user_id);

-- STORES policies
CREATE POLICY "Stores are viewable by everyone"
  ON stores FOR SELECT
  USING (true);

CREATE POLICY "Store owners can insert"
  ON stores FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM artisans WHERE artisans.id = stores.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "Store owners can update"
  ON stores FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM artisans WHERE artisans.id = stores.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "Store owners can delete"
  ON stores FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM artisans WHERE artisans.id = stores.artisan_id AND artisans.user_id = auth.uid())
  );

-- PRODUCTS policies
CREATE POLICY "Published products are viewable by everyone"
  ON products FOR SELECT
  USING (is_published = true AND status = 'approved' AND visibility = 'public');

CREATE POLICY "Artisans can view all their own products"
  ON products FOR SELECT
  USING (
    EXISTS (SELECT 1 FROM artisans WHERE artisans.id = products.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "Artisans can insert products"
  ON products FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM artisans WHERE artisans.id = products.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "Artisans can update their own products"
  ON products FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM artisans WHERE artisans.id = products.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "Artisans can delete their own products"
  ON products FOR DELETE
  USING (
    EXISTS (SELECT 1 FROM artisans WHERE artisans.id = products.artisan_id AND artisans.user_id = auth.uid())
  );

-- B2B REQUIREMENTS policies
CREATE POLICY "Requirements viewable by everyone"
  ON b2b_requirements FOR SELECT
  USING (true);

CREATE POLICY "Buyers can insert their requirements"
  ON b2b_requirements FOR INSERT
  WITH CHECK (auth.uid() = buyer_id);

CREATE POLICY "Buyers can update their own requirements"
  ON b2b_requirements FOR UPDATE
  USING (auth.uid() = buyer_id);

CREATE POLICY "Buyers can delete their own requirements"
  ON b2b_requirements FOR DELETE
  USING (auth.uid() = buyer_id);

-- B2B ENQUIRIES policies
CREATE POLICY "Enquiries viewable by involved parties"
  ON b2b_enquiries FOR SELECT
  USING (
    auth.uid() = buyer_id
    OR EXISTS (SELECT 1 FROM artisans WHERE artisans.id = b2b_enquiries.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "Buyers can insert enquiries"
  ON b2b_enquiries FOR INSERT
  WITH CHECK (auth.uid() = buyer_id);

CREATE POLICY "Artisans can update enquiries addressed to them"
  ON b2b_enquiries FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM artisans WHERE artisans.id = b2b_enquiries.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "Buyers can update their own enquiries"
  ON b2b_enquiries FOR UPDATE
  USING (auth.uid() = buyer_id);

-- B2B QUOTES policies
CREATE POLICY "Quotes viewable by involved parties"
  ON b2b_quotes FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM b2b_enquiries
      WHERE b2b_enquiries.id = b2b_quotes.enquiry_id
      AND b2b_enquiries.buyer_id = auth.uid()
    )
    OR EXISTS (SELECT 1 FROM artisans WHERE artisans.id = b2b_quotes.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "Artisans can insert quotes"
  ON b2b_quotes FOR INSERT
  WITH CHECK (
    EXISTS (SELECT 1 FROM artisans WHERE artisans.id = b2b_quotes.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "Artisans can update their own quotes"
  ON b2b_quotes FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM artisans WHERE artisans.id = b2b_quotes.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "Buyers can update quote status"
  ON b2b_quotes FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM b2b_enquiries
      WHERE b2b_enquiries.id = b2b_quotes.enquiry_id
      AND b2b_enquiries.buyer_id = auth.uid()
    )
  );

-- B2B ORDERS policies
CREATE POLICY "Orders viewable by involved parties"
  ON b2b_orders FOR SELECT
  USING (
    auth.uid() = buyer_id
    OR EXISTS (SELECT 1 FROM artisans WHERE artisans.id = b2b_orders.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "System can insert orders"
  ON b2b_orders FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Artisans can update their orders"
  ON b2b_orders FOR UPDATE
  USING (
    EXISTS (SELECT 1 FROM artisans WHERE artisans.id = b2b_orders.artisan_id AND artisans.user_id = auth.uid())
  );

CREATE POLICY "Buyers can update their orders"
  ON b2b_orders FOR UPDATE
  USING (auth.uid() = buyer_id);

-- B2B SAVED ARTISANS policies
CREATE POLICY "Buyers can view their own saved artisans"
  ON b2b_saved_artisans FOR SELECT
  USING (auth.uid() = buyer_id);

CREATE POLICY "Buyers can save artisans"
  ON b2b_saved_artisans FOR INSERT
  WITH CHECK (auth.uid() = buyer_id);

CREATE POLICY "Buyers can unsave artisans"
  ON b2b_saved_artisans FOR DELETE
  USING (auth.uid() = buyer_id);

-- ============================================
-- UPDATED_AT auto-update trigger
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_stores_updated_at
  BEFORE UPDATE ON stores
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_b2b_requirements_updated_at
  BEFORE UPDATE ON b2b_requirements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_b2b_enquiries_updated_at
  BEFORE UPDATE ON b2b_enquiries
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_b2b_quotes_updated_at
  BEFORE UPDATE ON b2b_quotes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_b2b_orders_updated_at
  BEFORE UPDATE ON b2b_orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
