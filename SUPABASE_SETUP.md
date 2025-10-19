# Configuración de Supabase

## Paso 1: Crear Proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com)
2. Crea un nuevo proyecto
3. Guarda la URL y la anon key

## Paso 2: Crear Tablas en Supabase

Ejecuta el siguiente SQL en el SQL Editor de Supabase:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla de Tiendas/Almacenes
CREATE TABLE stores (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('store', 'warehouse')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Perfiles de Usuario
CREATE TABLE user_profiles (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  store_id UUID REFERENCES stores(id),
  full_name TEXT NOT NULL,
  role TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Productos
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  category TEXT,
  sku TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  is_deleted BOOLEAN DEFAULT FALSE
);

-- Tabla de Variantes de Productos
CREATE TABLE product_variants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  attrs JSONB,
  sku TEXT UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  is_deleted BOOLEAN DEFAULT FALSE
);

-- Tabla de Inventario
CREATE TABLE inventory (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID REFERENCES stores(id),
  product_id UUID REFERENCES products(id),
  variant_id UUID REFERENCES product_variants(id),
  stock_qty INTEGER NOT NULL DEFAULT 0,
  min_qty INTEGER,
  max_qty INTEGER,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Compras
CREATE TABLE purchases (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID REFERENCES stores(id),
  product_id UUID REFERENCES products(id),
  variant_id UUID REFERENCES product_variants(id),
  qty INTEGER NOT NULL,
  unit_cost DECIMAL(10,2),
  at TIMESTAMPTZ NOT NULL,
  author_user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Ventas
CREATE TABLE sales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  store_id UUID REFERENCES stores(id),
  product_id UUID REFERENCES products(id),
  variant_id UUID REFERENCES product_variants(id),
  qty INTEGER NOT NULL,
  unit_price DECIMAL(10,2),
  at TIMESTAMPTZ NOT NULL,
  customer TEXT,
  author_user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Transferencias
CREATE TABLE transfers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  from_store_id UUID REFERENCES stores(id),
  to_store_id UUID REFERENCES stores(id),
  product_id UUID REFERENCES products(id),
  variant_id UUID REFERENCES product_variants(id),
  qty INTEGER NOT NULL,
  at TIMESTAMPTZ NOT NULL,
  author_user_id UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Paso 3: Crear Triggers para updated_at

```sql
-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER update_stores_updated_at BEFORE UPDATE ON stores
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_product_variants_updated_at BEFORE UPDATE ON product_variants
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON inventory
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_purchases_updated_at BEFORE UPDATE ON purchases
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sales_updated_at BEFORE UPDATE ON sales
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transfers_updated_at BEFORE UPDATE ON transfers
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

## Paso 4: Configurar Row Level Security (RLS)

```sql
-- Habilitar RLS en todas las tablas
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfers ENABLE ROW LEVEL SECURITY;

-- Política para stores: los usuarios solo ven su tienda
CREATE POLICY "Users can view their store" ON stores
  FOR SELECT USING (
    id IN (
      SELECT store_id FROM user_profiles WHERE user_id = auth.uid()
    )
  );

-- Política para user_profiles: los usuarios ven su propio perfil
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (user_id = auth.uid());

-- Política para products: acceso por tienda
CREATE POLICY "Users can view all products" ON products
  FOR SELECT USING (true);

CREATE POLICY "Users can insert products" ON products
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update products" ON products
  FOR UPDATE USING (true);

-- Política para inventory: solo inventario de su tienda
CREATE POLICY "Users can view inventory of their store" ON inventory
  FOR SELECT USING (
    store_id IN (
      SELECT store_id FROM user_profiles WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert inventory" ON inventory
  FOR INSERT WITH CHECK (
    store_id IN (
      SELECT store_id FROM user_profiles WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update inventory" ON inventory
  FOR UPDATE USING (
    store_id IN (
      SELECT store_id FROM user_profiles WHERE user_id = auth.uid()
    )
  );

-- Políticas similares para purchases, sales, transfers
CREATE POLICY "Users can view purchases of their store" ON purchases
  FOR SELECT USING (
    store_id IN (
      SELECT store_id FROM user_profiles WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert purchases" ON purchases
  FOR INSERT WITH CHECK (
    store_id IN (
      SELECT store_id FROM user_profiles WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can view sales of their store" ON sales
  FOR SELECT USING (
    store_id IN (
      SELECT store_id FROM user_profiles WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert sales" ON sales
  FOR INSERT WITH CHECK (
    store_id IN (
      SELECT store_id FROM user_profiles WHERE user_id = auth.uid()
    )
  );
```

## Paso 5: Crear RPC para Transferencias Atómicas

```sql
CREATE OR REPLACE FUNCTION perform_transfer(
  p_from_store_id UUID,
  p_to_store_id UUID,
  p_product_id UUID,
  p_variant_id UUID,
  p_qty INTEGER,
  p_at TIMESTAMPTZ,
  p_author_user_id UUID
) RETURNS UUID AS $$
DECLARE
  v_transfer_id UUID;
  v_from_inventory_id UUID;
  v_to_inventory_id UUID;
BEGIN
  -- Generar ID para la transferencia
  v_transfer_id := uuid_generate_v4();
  
  -- Restar del inventario origen
  UPDATE inventory 
  SET stock_qty = stock_qty - p_qty,
      updated_at = NOW()
  WHERE store_id = p_from_store_id 
    AND product_id = p_product_id
    AND (variant_id = p_variant_id OR (variant_id IS NULL AND p_variant_id IS NULL));
    
  -- Sumar al inventario destino
  UPDATE inventory 
  SET stock_qty = stock_qty + p_qty,
      updated_at = NOW()
  WHERE store_id = p_to_store_id 
    AND product_id = p_product_id
    AND (variant_id = p_variant_id OR (variant_id IS NULL AND p_variant_id IS NULL));
    
  -- Si no existe el inventario destino, crearlo
  IF NOT FOUND THEN
    INSERT INTO inventory (id, store_id, product_id, variant_id, stock_qty, updated_at)
    VALUES (uuid_generate_v4(), p_to_store_id, p_product_id, p_variant_id, p_qty, NOW());
  END IF;
  
  -- Registrar la transferencia
  INSERT INTO transfers (id, from_store_id, to_store_id, product_id, variant_id, qty, at, author_user_id, created_at, updated_at)
  VALUES (v_transfer_id, p_from_store_id, p_to_store_id, p_product_id, p_variant_id, p_qty, p_at, p_author_user_id, NOW(), NOW());
  
  RETURN v_transfer_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Paso 6: Habilitar Realtime

En el panel de Supabase:
1. Ve a Database > Replication
2. Habilita Realtime para las tablas:
   - inventory
   - sales
   - purchases
   - transfers
   - products

## Paso 7: Datos de Prueba (Opcional)

```sql
-- Insertar tiendas de ejemplo
INSERT INTO stores (id, name, type) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Tienda Central', 'store'),
  ('22222222-2222-2222-2222-222222222222', 'Almacén Principal', 'warehouse');

-- Insertar productos de ejemplo
INSERT INTO products (name, description, category, sku) VALUES
  ('Alfombra Persa', 'Alfombra de lujo estilo persa', 'Alfombras', 'ALF-001'),
  ('Piso Flotante Oak', 'Piso flotante imitación madera roble', 'Pisos', 'PIS-001'),
  ('Vinilo Decorativo', 'Vinilo adhesivo para paredes', 'Viniles', 'VIN-001');
```

## Paso 8: Configurar en la App

En tu aplicación Flutter, configura las variables:

```bash
# Opción 1: Con --dart-define
flutter run --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co --dart-define=SUPABASE_ANON_KEY=tu_anon_key

# Opción 2: Crear archivo .env (requiere flutter_dotenv)
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_anon_key
```

## Verificación

1. Ve a Table Editor en Supabase
2. Verifica que todas las tablas existen
3. Prueba insertar datos manualmente
4. Verifica que los triggers funcionen (updated_at se actualiza)
5. Prueba la autenticación desde la app
