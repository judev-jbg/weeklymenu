-- Crear tabla de menús disponibles
CREATE TABLE menus (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Crear enum para estados de menú asignado
CREATE TYPE menu_status AS ENUM ('pending', 'completed', 'not_completed');

-- Crear tabla de menús asignados por día
CREATE TABLE daily_menus (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  menu_id UUID REFERENCES menus(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  day_index INTEGER NOT NULL, -- 0=sábado, 1=domingo, ..., 8=domingo siguiente
  status menu_status DEFAULT 'pending',
  actual_menu_id UUID REFERENCES menus(id) ON DELETE SET NULL, -- menú real consumido si no cumplió
  order_position INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  UNIQUE(user_id, day_index)
);

CREATE INDEX idx_daily_menus_user_date ON daily_menus(user_id, date);
CREATE INDEX idx_daily_menus_status ON daily_menus(status);
CREATE INDEX idx_menus_name ON menus(name);

ALTER TABLE menus ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_menus ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden ver todos los menús" ON menus FOR SELECT USING (true);
CREATE POLICY "Usuarios pueden crear menús" ON menus FOR INSERT WITH CHECK (true);

CREATE POLICY "Usuarios pueden ver sus menús diarios" ON daily_menus FOR SELECT USING (true);
CREATE POLICY "Usuarios pueden gestionar sus menús diarios" ON daily_menus FOR ALL USING(true);

-- Función para inicializar menús diarios para un usuario
CREATE OR REPLACE FUNCTION initialize_user_weekly_menus(user_uuid UUID)
RETURNS VOID AS $$
DECLARE
    start_date DATE;
    i INTEGER;
BEGIN
    -- Encontrar el sábado más cercano (inicio de semana)
    start_date := CURRENT_DATE - EXTRACT(DOW FROM CURRENT_DATE)::INTEGER + 6;
    IF EXTRACT(DOW FROM CURRENT_DATE) = 6 THEN -- Si hoy es sábado
        start_date := CURRENT_DATE;
    END IF;
    
    -- Crear 9 menús diarios (sábado a domingo siguiente)
    FOR i IN 0..8 LOOP
        INSERT INTO daily_menus (user_id, date, day_index, order_position)
        VALUES (user_uuid, start_date + i, i, i)
        ON CONFLICT (user_id, day_index) DO NOTHING;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Triggers para actualizar timestamps
CREATE TRIGGER update_menus_updated_at BEFORE UPDATE
    ON menus FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_daily_menus_updated_at BEFORE UPDATE
    ON daily_menus FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

INSERT INTO menus (name, description) VALUES
('Pasta con pollo', 'Deliciosa pasta con trozos de pollo y salsa cremosa'),
('Ensalada César', 'Ensalada fresca con pollo, crutones y aderezo césar'),
('Arroz con verduras', 'Arroz integral salteado con verduras mixtas'),
('Sopa de lentejas', 'Sopa nutritiva de lentejas con verduras'),
('Tacos de pescado', 'Tacos frescos con pescado empanizado y salsa'),
('Pizza casera', 'Pizza hecha en casa con ingredientes frescos'),
('Pollo asado', 'Pollo asado al horno con hierbas y especias');
