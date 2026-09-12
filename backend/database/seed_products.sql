-- ============================================
-- Migrate existing data from products.json into Supabase
-- ============================================

-- First, create the artisan record
INSERT INTO artisans (id, user_id, name, craft_specialization, location, state, bio, is_verified, created_at)
VALUES (
  'ap_1',
  (SELECT id FROM auth.users LIMIT 1),
  'Ramesh Kumar',
  'Blue Pottery',
  'Jaipur, Rajasthan',
  'Rajasthan',
  'Skilled artisan specializing in traditional blue pottery from Jaipur.',
  true,
  now()
)
ON CONFLICT (id) DO NOTHING;

-- Create the store record
INSERT INTO stores (id, artisan_id, name, slug, description, craft_category, location, state, is_verified, is_active, created_at, updated_at)
VALUES (
  'st_1',
  'ap_1',
  'Ramesh Kumar''s Pottery',
  'ramesh-kumars-pottery',
  'Traditional blue pottery from Jaipur, Rajasthan',
  'Pottery & Ceramics',
  'Jaipur, Rajasthan',
  'Rajasthan',
  true,
  true,
  now(),
  now()
)
ON CONFLICT (id) DO NOTHING;

-- Insert all 5 products from products.json
INSERT INTO products (id, store_id, artisan_id, name, description, price, discount_price, category, craft_type, material, image_urls, stock_quantity, is_published, status, visibility, tags, created_at, updated_at)
VALUES
(
  'prod_1789125403156',
  'st_1',
  'ap_1',
  'Product',
  'Authentic handcrafted creation made by skilled artisan.',
  790000.0,
  790000.0,
  'Pottery & Ceramics',
  '',
  '',
  ARRAY['https://acutpnwhubbmptbgtnih.supabase.co/storage/v1/object/public/products/prod_1789125403156.jpg'],
  10,
  true,
  'approved',
  'public',
  ARRAY['Handmade'],
  '2026-09-11T11:16:45Z'::timestamptz,
  now()
),
(
  'prod_1789115989770',
  'st_1',
  'ap_1',
  'Handcrafted Artwork',
  'Authentic handcrafted creation made by skilled artisan.',
  100.0,
  100.0,
  'Pottery & Ceramics',
  '',
  '',
  ARRAY['https://acutpnwhubbmptbgtnih.supabase.co/storage/v1/object/public/products/prod_1789115989770.jpg'],
  10,
  true,
  'approved',
  'public',
  ARRAY['Handmade'],
  '2026-09-11T08:39:52Z'::timestamptz,
  now()
),
(
  'prod_1789109193285',
  'st_1',
  'ap_1',
  'Handcrafted Craft',
  'Authentic handcrafted creation made by skilled artisan.',
  50.0,
  50.0,
  'Pottery & Ceramics',
  '',
  '',
  ARRAY['https://acutpnwhubbmptbgtnih.supabase.co/storage/v1/object/public/products/prod_1789109193285.jpg'],
  10,
  true,
  'approved',
  'public',
  ARRAY['Handmade'],
  '2026-09-11T06:46:36Z'::timestamptz,
  now()
),
(
  'prod_1789075173247',
  'st_1',
  'ap_1',
  'Handcrafted Craft',
  'Authentic handcrafted creation made by skilled artisan.',
  100000.0,
  100000.0,
  'Pottery & Ceramics',
  'Handcrafted',
  '',
  ARRAY['https://acutpnwhubbmptbgtnih.supabase.co/storage/v1/object/public/products/prod_1789075173247.jpg'],
  10,
  true,
  'approved',
  'public',
  ARRAY['Handcrafted', 'Handmade'],
  '2026-09-10T21:19:36Z'::timestamptz,
  now()
),
(
  'prod_1789073386_eb0db6',
  'st_1',
  'ap_1',
  'Terracotta Blue Pottery Vase',
  'Authentic handcrafted Blue Pottery Vase made with traditional techniques in Jaipur.',
  850.0,
  999.0,
  'Pottery & Ceramics',
  'Blue Pottery',
  'Clay',
  ARRAY['https://acutpnwhubbmptbgtnih.supabase.co/storage/v1/object/public/products/prod_1789073386_eb0db6.jpg'],
  10,
  true,
  'approved',
  'public',
  ARRAY['Pottery', 'Blue Pottery', 'Handmade'],
  '2026-09-10T20:49:47Z'::timestamptz,
  now()
)
ON CONFLICT (id) DO NOTHING;
