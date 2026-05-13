-- 会员商城数据库初始化脚本
-- 在 Supabase SQL Editor 中粘贴全部内容，点击 Run 执行

-- 1. 商品表
CREATE TABLE IF NOT EXISTS products (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL DEFAULT '',
  image TEXT NOT NULL DEFAULT '',
  description TEXT NOT NULL DEFAULT '',
  specs JSONB NOT NULL DEFAULT '[]'::jsonb,
  prices JSONB NOT NULL DEFAULT '[]'::jsonb,
  stock INT NOT NULL DEFAULT 999,
  featured BOOLEAN NOT NULL DEFAULT false,
  sort_order INT NOT NULL DEFAULT 0,
  tags JSONB NOT NULL DEFAULT '[]'::jsonb,
  sell_type TEXT NOT NULL DEFAULT 'direct',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. 订单表
CREATE TABLE IF NOT EXISTS orders (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL DEFAULT '',
  username TEXT NOT NULL DEFAULT '',
  product_name TEXT NOT NULL DEFAULT '',
  spec_chosen JSONB NOT NULL DEFAULT '[]'::jsonb,
  price_chosen JSONB NOT NULL DEFAULT '{}'::jsonb,
  quantity INT NOT NULL DEFAULT 1,
  total_price FLOAT NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'pending',
  expire_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. 用户表
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL DEFAULT '',
  password TEXT NOT NULL DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. 设置表
CREATE TABLE IF NOT EXISTS settings (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL DEFAULT '{}'::jsonb
);

-- 5. 插入默认设置
INSERT INTO settings (key, value) VALUES ('site_config', '{
  "siteName": "会员商城",
  "heroTitle": "优质会员服务，即刻开启",
  "heroSub": "选择适合你的会员套餐，享受专属权益与服务",
  "contactInfo": "扫码添加微信咨询",
  "alipayQr": "",
  "adminPassword": "admin123",
  "categories": [
    {"id": "c1", "icon": "🔥", "label": "全部", "image": ""},
    {"id": "c2", "icon": "⭐", "label": "推荐", "image": ""},
    {"id": "c3", "icon": "💎", "label": "会员", "image": ""},
    {"id": "c4", "icon": "🛡️", "label": "企业", "image": ""},
    {"id": "c5", "icon": "📱", "label": "入门", "image": ""}
  ]
}') ON CONFLICT (key) DO NOTHING;

-- 6. 插入默认商品
INSERT INTO products (name, image, featured, sell_type, stock, sort_order, tags, description, specs, prices)
SELECT * FROM (VALUES
  ('基础版会员', '', false, 'direct', 999, 1, '["c5","c3"]',
   '<p>适合个人用户入门使用，包含<b>核心功能</b>。</p><p>✅ 核心功能全部可用<br>✅ 每月 <b style="color:#2563eb">100次</b> 调用额度<br>✅ 社区支持<br>✅ 基础数据统计</p>',
   '[{"name":"时长","options":["1个月","3个月","1年"]},{"name":"版本","options":["标准版"]}]',
   '[{"label":"月付","price":19,"originalPrice":29},{"label":"年付","price":190,"originalPrice":228}]'
  ),
  ('专业版会员', '', true, 'direct', 500, 2, '["c2","c3"]',
   '<p>适合专业用户，<b style="color:#e4393c">功能更全面</b>，优先支持。</p><p>🔥 全部核心功能<br>🔥 每月 <b style="color:#2563eb">1000次</b> 调用额度<br>🔥 <b>优先客服支持</b><br>🔥 高级数据分析<br>🔥 API 接入权限<br>🔥 团队协作（最多5人）</p>',
   '[{"name":"时长","options":["1个月","3个月","1年"]},{"name":"版本","options":["标准版","高级版"]}]',
   '[{"label":"月付","price":49,"originalPrice":69},{"label":"年付","price":490,"originalPrice":588}]'
  ),
  ('企业版会员', '', false, 'direct', 100, 3, '["c4","c3"]',
   '<p>适合企业团队，<b style="color:#7c3aed">功能无限制</b>，专属服务。</p><p>💎 全部功能无限制<br>💎 <b style="color:#e4393c">无限</b>调用额度<br>💎 7×24 专属客服<br>💎 定制化数据分析<br>💎 全套 API 接入<br>💎 团队协作（无限人数）<br>💎 🏆 1v1 技术指导<br>💎 🛡️ SLA 99.9% 保障</p>',
   '[{"name":"时长","options":["1个月","3个月","1年"]},{"name":"版本","options":["企业版"]}]',
   '[{"label":"月付","price":99,"originalPrice":129},{"label":"年付","price":990,"originalPrice":1188}]'
  )
) AS t(name, image, featured, sell_type, stock, sort_order, tags, description, specs, prices)
WHERE NOT EXISTS (SELECT 1 FROM products LIMIT 1);

-- 7. 关闭 RLS（简化管理，只用 anon key）
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- 允许匿名用户对所有表进行所有操作
CREATE POLICY "Allow all" ON products FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON orders FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all" ON settings FOR ALL USING (true) WITH CHECK (true);
