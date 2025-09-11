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
CREATE TYPE menu_status AS ENUM ('pending', 'completed', 'not_completed','unassigned');

-- Crear tabla de menús asignados por día
CREATE TABLE daily_menus (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  menu_id UUID REFERENCES menus(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  day_index INTEGER NOT NULL, -- 0=sábado, 1=domingo, ..., 8=domingo siguiente
  status menu_status DEFAULT 'unassigned',
  actual_menu_id UUID REFERENCES menus(id) ON DELETE SET NULL, -- menú real consumido si no cumplió
  order_position INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  
  UNIQUE(day_index, date)
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

-- -- Función para inicializar menús diarios para un usuario
-- CREATE OR REPLACE FUNCTION initialize_user_weekly_menus(user_uuid UUID)
-- RETURNS VOID AS $$
-- DECLARE
--     start_saturday DATE;
--     i INTEGER;
-- BEGIN
--     -- Encontrar el sábado de esta semana
--     start_saturday := CURRENT_DATE - EXTRACT(DOW FROM CURRENT_DATE)::INTEGER + 6;
--     IF EXTRACT(DOW FROM CURRENT_DATE) = 6 THEN -- Si hoy es sábado
--         start_saturday := CURRENT_DATE;
--     END IF;
    
--     -- Crear los 9 registros (day_index 0 a 8)
--     FOR i IN 0..8 LOOP
--         INSERT INTO daily_menus (user_id, date, day_index, order_position, status)
--         VALUES (user_uuid, start_saturday + i, i, i, 'pending')
--         ON CONFLICT (user_id, day_index) 
--         DO UPDATE SET 
--             date = EXCLUDED.date,
--             order_position = EXCLUDED.order_position;
--     END LOOP;
    
--     RAISE NOTICE 'Initialized weekly menus for user %', user_uuid;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;

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


-- -- Función que debe ejecutarse cada viernes para resetear los menús
-- CREATE OR REPLACE FUNCTION weekly_menu_reset()
-- RETURNS VOID AS $$
-- BEGIN
--     -- Solo ejecutar si es viernes
--     IF EXTRACT(DOW FROM CURRENT_DATE) = 5 THEN
--         -- Resetear solo los menús de lunes a domingo (day_index 2-8)
--         -- NO resetear sábado (day_index 0) ni domingo (day_index 1) porque aún no han pasado
--         UPDATE daily_menus 
--         SET menu_id = NULL, 
--             status = 'pending',
--             actual_menu_id = NULL,
--             updated_at = TIMEZONE('utc'::text, NOW())
--         WHERE day_index >= 2 AND day_index <= 8; -- Solo lunes (2) a domingo siguiente (8)
        
--         -- Actualizar las fechas para la nueva semana
--         -- Calcular el lunes de la siguiente semana
--         DECLARE
--             next_monday DATE := CURRENT_DATE + (9 - EXTRACT(DOW FROM CURRENT_DATE))::INTEGER;
--         BEGIN
--             -- Actualizar fechas para la próxima semana (lunes a domingo)
--             UPDATE daily_menus 
--             SET date = next_monday + (day_index - 2) -- day_index 2 = lunes
--             WHERE day_index >= 2 AND day_index <= 8;
--         END;
        
--         RAISE NOTICE 'Weekly menu reset completed: Reset menus from Monday to Sunday, kept Saturday and Sunday from previous week';
--     ELSE
--         RAISE NOTICE 'Weekly reset can only be executed on Fridays. Today is %', 
--             CASE EXTRACT(DOW FROM CURRENT_DATE)
--                 WHEN 0 THEN 'Sunday'
--                 WHEN 1 THEN 'Monday' 
--                 WHEN 2 THEN 'Tuesday'
--                 WHEN 3 THEN 'Wednesday'
--                 WHEN 4 THEN 'Thursday'
--                 WHEN 6 THEN 'Saturday'
--             END;
--     END IF;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;;


-- Función que se ejecuta cada viernes para crear la nueva semana
CREATE OR REPLACE FUNCTION create_new_week()
RETURNS VOID AS $$
DECLARE
    next_monday DATE;
    i INTEGER;
    new_day_index INTEGER;
BEGIN
    -- Solo ejecutar si es viernes
    IF EXTRACT(DOW FROM CURRENT_DATE) = 5 THEN
        -- Calcular el lunes de la siguiente semana
        next_monday := CURRENT_DATE + (9 - EXTRACT(DOW FROM CURRENT_DATE))::INTEGER;
        
        -- Crear 7 nuevos registros (lunes a domingo de la siguiente semana)
        FOR i IN 0..6 LOOP
            new_day_index := i + 2; -- day_index: 2=lunes, 3=martes... 8=domingo
            
            -- Solo crear si no existe ya un registro para esa fecha y day_index
            INSERT INTO daily_menus (
                user_id,        -- NULL inicialmente
                menu_id,        -- NULL inicialmente  
                date,           -- Fecha específica
                day_index,      -- 2-8 (lunes a domingo)
                status,
                order_position,
                created_at,
                updated_at
            )
            VALUES (
                NULL,                           -- Sin usuario asignado
                NULL,                           -- Sin menú asignado
                next_monday + i,                -- Fecha del día específico
                new_day_index,                  -- day_index correspondiente
                'pending',                      -- Estado pendiente
                new_day_index,                  -- Posición igual al day_index
                TIMEZONE('utc'::text, NOW()),   -- Fecha creación
                TIMEZONE('utc'::text, NOW())    -- Fecha actualización
            )
            ON CONFLICT (day_index, date) DO NOTHING; -- No duplicar si ya existe
        END LOOP;
        
        RAISE NOTICE 'Created new week: % to % (day_index 2-8)', 
                     next_monday, next_monday + 6;
    ELSE
        RAISE NOTICE 'New week creation only runs on Fridays. Today is %', 
                     TO_CHAR(CURRENT_DATE, 'Day');
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para inicializar registros por primera vez (ejecutar manualmente una sola vez)
CREATE OR REPLACE FUNCTION initialize_first_week()
RETURNS VOID AS $$
DECLARE
    current_saturday DATE;
    i INTEGER;
BEGIN
    -- Encontrar el proximo sábado de esta semana
    current_saturday := CURRENT_DATE - EXTRACT(DOW FROM CURRENT_DATE)::INTEGER + 6;
    IF EXTRACT(DOW FROM CURRENT_DATE) = 6 THEN
        current_saturday := CURRENT_DATE;
    END IF;
    
    -- Encontrar el sábado anterior a esta semana
    -- current_saturday := CURRENT_DATE - (EXTRACT(DOW FROM CURRENT_DATE)::INTEGER + 1) % 7;
    
    -- Crear 9 registros iniciales (sábado=0, domingo=1, lunes=2...domingo=8)
    FOR i IN 0..8 LOOP
        INSERT INTO daily_menus (
            user_id, menu_id, date, day_index, status, order_position
        ) VALUES (
            NULL, NULL, current_saturday + i, i, 'pending', i
        ) ON CONFLICT (day_index, date) DO NOTHING;
    END LOOP;
    
    RAISE NOTICE 'Initialized first week: % to %', current_saturday, current_saturday + 8;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Ejecutar solo la primera vez
SELECT initialize_first_week();