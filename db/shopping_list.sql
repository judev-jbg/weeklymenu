-- Crear tabla de ingredientes/insumos
CREATE TABLE ingredients (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Crear tabla de lista de compras
CREATE TABLE shopping_list (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  ingredient_id UUID REFERENCES ingredients(id) ON DELETE CASCADE NOT NULL,
  quantity VARCHAR(100),
  is_purchased BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  UNIQUE(user_id, ingredient_id)
);

CREATE INDEX idx_shopping_list_user ON shopping_list(user_id);
CREATE INDEX idx_ingredients_name ON ingredients(name);

ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden ver todos los ingredientes" ON ingredients FOR SELECT USING (true);
CREATE POLICY "Usuarios pueden crear ingredientes" ON ingredients FOR INSERT USING (true);
CREATE POLICY "Usuarios pueden gestionar su lista de compras" ON shopping_list FOR ALL USING (true);

INSERT INTO ingredients (name, category) VALUES
('Pasta', 'Carbohidratos'),
('Pollo', 'Proteínas'),
('Lechuga', 'Verduras'),
('Tomate', 'Verduras'),
('Cebolla', 'Verduras'),
('Arroz', 'Carbohidratos'),
('Lentejas', 'Legumbres'),
('Pescado', 'Proteínas'),
('Queso', 'Lácteos'),
('Pan', 'Carbohidratos');
