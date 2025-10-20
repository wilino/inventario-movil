import 'database.dart';

/// Servicio para inicializar datos de ejemplo en la base de datos
/// Ejecutar una sola vez al inicio de la aplicación
class DataSeeder {
  final AppDatabase db;

  DataSeeder(this.db);

  /// Verifica si ya hay datos
  Future<bool> hasData() async {
    final count = await db
        .customSelect(
          'SELECT COUNT(*) as count FROM products',
          readsFrom: {db.products},
        )
        .getSingleOrNull();

    return count != null && count.read<int>('count') > 0;
  }

  /// Inicializa datos de ejemplo (solo si la DB está vacía)
  Future<void> seedIfEmpty() async {
    if (await hasData()) {
      print('ℹ️ Ya existen datos en la base de datos');
      return;
    }

    print('🌱 Inicializando datos de ejemplo...');

    try {
      await _seedData();
      print('✅ Datos de ejemplo creados exitosamente');
    } catch (e, stack) {
      print('❌ Error al crear datos de ejemplo: $e');
      print(stack);
    }
  }

  Future<void> _seedData() async {
    final now = DateTime.now();

    // Insertar datos usando SQL directo para evitar problemas con Companions
    await db.customStatement('''
      INSERT INTO products (id, sku, name, description, category, cost_price, sale_price, unit, has_variants, is_active, created_at, updated_at)
      VALUES 
        ('prod_001', 'SKU-001', 'Lámpara de Mesa Moderna', 'Lámpara decorativa', 'Iluminación', 600.0, 850.0, 'pz', 1, 1, '${now.toIso8601String()}', '${now.toIso8601String()}'),
        ('prod_002', 'SKU-002', 'Jarrón Cerámico Grande', 'Jarrón artesanal', 'Decoración', 800.0, 1200.0, 'pz', 1, 1, '${now.toIso8601String()}', '${now.toIso8601String()}'),
        ('prod_003', 'SKU-003', 'Cuadro Abstracto Canvas', 'Cuadro moderno', 'Arte', 500.0, 800.0, 'pz', 0, 1, '${now.toIso8601String()}', '${now.toIso8601String()}'),
        ('prod_004', 'SKU-004', 'Cojín Decorativo', 'Cojín de terciopelo', 'Textiles', 150.0, 250.0, 'pz', 1, 1, '${now.toIso8601String()}', '${now.toIso8601String()}'),
        ('prod_005', 'SKU-005', 'Espejo de Pared', 'Espejo decorativo', 'Decoración', 700.0, 1100.0, 'pz', 0, 1, '${now.toIso8601String()}', '${now.toIso8601String()}');
    ''');

    await db.customStatement('''
      INSERT INTO product_variants (id, product_id, attrs, sku, created_at, updated_at)
      VALUES 
        ('var_001', 'prod_001', '{"color": "Negro"}', 'SKU-001-BL', '${now.toIso8601String()}', '${now.toIso8601String()}'),
        ('var_002', 'prod_001', '{"color": "Blanco"}', 'SKU-001-WH', '${now.toIso8601String()}', '${now.toIso8601String()}'),
        ('var_003', 'prod_002', '{"tamaño": "Grande"}', 'SKU-002-GR', '${now.toIso8601String()}', '${now.toIso8601String()}'),
        ('var_004', 'prod_004', '{"color": "Azul"}', 'SKU-004-BL', '${now.toIso8601String()}', '${now.toIso8601String()}'),
        ('var_005', 'prod_004', '{"color": "Gris"}', 'SKU-004-GR', '${now.toIso8601String()}', '${now.toIso8601String()}');
    ''');

    await db.customStatement('''
      INSERT INTO suppliers (id, name, contact_name, email, phone, address, tax_id, is_active, created_at, updated_at)
      VALUES 
        ('supp_001', 'Decoraciones Elite S.A.', 'Juan Pérez', 'contacto@decorelite.com', '+52 55 1234 5678', 'Av. Reforma 123, CDMX', 'DEL-123456-ABC', 1, '${now.toIso8601String()}', '${now.toIso8601String()}'),
        ('supp_002', 'Artesanías Mexicanas', 'María González', 'ventas@artmex.com', '+52 55 9876 5432', 'Calle Artesanos 45, Puebla', 'ARM-654321-XYZ', 1, '${now.toIso8601String()}', '${now.toIso8601String()}'),
        ('supp_003', 'Importadora Moderna', 'Carlos Ramírez', 'compras@impmoderna.com', '+52 33 5555 7777', 'Zona Industrial, Guadalajara', 'IMO-789012-QWE', 1, '${now.toIso8601String()}', '${now.toIso8601String()}');
    ''');

    // Inventario inicial
    await db.customStatement('''
      INSERT INTO inventory (id, store_id, product_id, variant_id, stock_qty, min_qty, max_qty, updated_at)
      VALUES 
        ('inv_001', 'store_001', 'prod_001', 'var_001', 15.0, 5.0, 50.0, '${now.toIso8601String()}'),
        ('inv_002', 'store_001', 'prod_001', 'var_002', 20.0, 5.0, 50.0, '${now.toIso8601String()}'),
        ('inv_003', 'store_001', 'prod_002', 'var_003', 8.0, 3.0, 30.0, '${now.toIso8601String()}'),
        ('inv_004', 'store_001', 'prod_003', NULL, 12.0, 4.0, 25.0, '${now.toIso8601String()}'),
        ('inv_005', 'store_001', 'prod_004', 'var_004', 25.0, 10.0, 100.0, '${now.toIso8601String()}'),
        ('inv_006', 'store_001', 'prod_004', 'var_005', 4.0, 10.0, 100.0, '${now.toIso8601String()}'),
        ('inv_007', 'store_001', 'prod_005', NULL, 10.0, 5.0, 30.0, '${now.toIso8601String()}');
    ''');

    // Ventas de los últimos 30 días
    final sale1Date = now.subtract(const Duration(days: 2)).toIso8601String();
    final sale2Date = now.subtract(const Duration(days: 5)).toIso8601String();
    final sale3Date = now.subtract(const Duration(days: 7)).toIso8601String();
    final sale4Date = now.subtract(const Duration(days: 10)).toIso8601String();
    final sale5Date = now.subtract(const Duration(days: 15)).toIso8601String();

    await db.customStatement('''
      INSERT INTO sales (id, store_id, author_user_id, subtotal, discount, tax, total, customer, notes, at, created_at, updated_at, is_deleted)
      VALUES 
        ('sale_001', 'store_001', 'user_001', 2850.0, 150.0, 432.0, 3132.0, 'Cliente Regular', 'Venta de mostrador', '$sale1Date', '$sale1Date', '$sale1Date', 0),
        ('sale_002', 'store_001', 'user_001', 1200.0, 0.0, 192.0, 1392.0, 'Ana Martínez', 'Entrega a domicilio', '$sale2Date', '$sale2Date', '$sale2Date', 0),
        ('sale_003', 'store_001', 'user_001', 3500.0, 350.0, 504.0, 3654.0, 'Pedro López', 'Pedido especial', '$sale3Date', '$sale3Date', '$sale3Date', 0),
        ('sale_004', 'store_001', 'user_001', 950.0, 0.0, 152.0, 1102.0, 'Laura Sánchez', NULL, '$sale4Date', '$sale4Date', '$sale4Date', 0),
        ('sale_005', 'store_001', 'user_001', 2100.0, 100.0, 320.0, 2320.0, 'Roberto García', NULL, '$sale5Date', '$sale5Date', '$sale5Date', 0);
    ''');

    await db.customStatement('''
      INSERT INTO sale_items (id, sale_id, product_id, variant_id, product_name, qty, unit_price, total)
      VALUES 
        ('sitem_001', 'sale_001', 'prod_001', 'var_001', 'Lámpara de Mesa Moderna - Negro', 2.0, 850.0, 1700.0),
        ('sitem_002', 'sale_001', 'prod_004', 'var_004', 'Cojín Decorativo - Azul', 3.0, 250.0, 750.0),
        ('sitem_003', 'sale_002', 'prod_005', NULL, 'Espejo de Pared', 1.0, 1100.0, 1100.0),
        ('sitem_004', 'sale_003', 'prod_002', 'var_003', 'Jarrón Cerámico Grande', 2.0, 1200.0, 2400.0),
        ('sitem_005', 'sale_003', 'prod_003', NULL, 'Cuadro Abstracto Canvas', 1.0, 800.0, 800.0),
        ('sitem_006', 'sale_004', 'prod_004', 'var_004', 'Cojín Decorativo - Azul', 3.0, 250.0, 750.0),
        ('sitem_007', 'sale_005', 'prod_001', 'var_002', 'Lámpara de Mesa Moderna - Blanco', 2.0, 850.0, 1700.0);
    ''');

    // Compras de los últimos 30 días
    final purch1Date = now.subtract(const Duration(days: 3)).toIso8601String();
    final purch2Date = now.subtract(const Duration(days: 8)).toIso8601String();
    final purch3Date = now.subtract(const Duration(days: 20)).toIso8601String();

    await db.customStatement('''
      INSERT INTO purchases (id, store_id, supplier_id, supplier_name, author_user_id, subtotal, discount, tax, total, invoice_number, notes, at, created_at, updated_at, is_deleted)
      VALUES 
        ('purch_001', 'store_001', 'supp_001', 'Decoraciones Elite S.A.', 'user_001', 15000.0, 750.0, 2280.0, 16530.0, 'FAC-001', 'Reposición de inventario', '$purch1Date', '$purch1Date', '$purch1Date', 0),
        ('purch_002', 'store_001', 'supp_002', 'Artesanías Mexicanas', 'user_001', 8500.0, 0.0, 1360.0, 9860.0, 'FAC-002', 'Nuevos productos artesanales', '$purch2Date', '$purch2Date', '$purch2Date', 0),
        ('purch_003', 'store_001', 'supp_003', 'Importadora Moderna', 'user_001', 12000.0, 600.0, 1824.0, 13224.0, 'FAC-003', 'Importación trimestral', '$purch3Date', '$purch3Date', '$purch3Date', 0);
    ''');

    await db.customStatement('''
      INSERT INTO purchase_items (id, purchase_id, product_id, variant_id, product_name, qty, unit_price, subtotal)
      VALUES 
        ('pitem_001', 'purch_001', 'prod_001', 'var_001', 'Lámpara de Mesa Moderna - Negro', 10.0, 600.0, 6000.0),
        ('pitem_002', 'purch_001', 'prod_002', 'var_003', 'Jarrón Cerámico Grande', 5.0, 800.0, 4000.0),
        ('pitem_003', 'purch_002', 'prod_004', 'var_004', 'Cojín Decorativo - Azul', 20.0, 150.0, 3000.0),
        ('pitem_004', 'purch_003', 'prod_003', NULL, 'Cuadro Abstracto Canvas', 15.0, 500.0, 7500.0);
    ''');

    // Traslados
    final trans1Date = now.subtract(const Duration(days: 12)).toIso8601String();
    final trans2Date = now.subtract(const Duration(days: 2)).toIso8601String();
    final trans3Date = now.subtract(const Duration(hours: 6)).toIso8601String();

    await db.customStatement('''
      INSERT INTO transfers (id, from_store_id, to_store_id, product_id, variant_id, product_name, qty, status, requested_by, sent_by, received_by, notes, requested_at, sent_at, received_at, created_at, updated_at)
      VALUES 
        ('trans_001', 'store_001', 'store_002', 'prod_001', 'var_001', 'Lámpara de Mesa Moderna - Negro', 5.0, 'completed', 'user_001', 'user_001', 'user_001', 'Rebalanceo de inventario', '$trans1Date', '$trans1Date', '$trans1Date', '$trans1Date', '$trans1Date'),
        ('trans_002', 'store_001', 'store_002', 'prod_004', 'var_004', 'Cojín Decorativo - Azul', 10.0, 'in_transit', 'user_001', 'user_001', NULL, 'Envío urgente', '$trans2Date', '$trans2Date', NULL, '$trans2Date', '$trans2Date'),
        ('trans_003', 'store_001', 'store_003', 'prod_003', NULL, 'Cuadro Abstracto Canvas', 3.0, 'pending', 'user_001', NULL, NULL, 'Solicitud de traslado', '$trans3Date', NULL, NULL, '$trans3Date', '$trans3Date');
    ''');

    print('✓ Productos y variantes');
    print('✓ Proveedores');
    print('✓ Inventario inicial');
    print('✓ 5 ventas con items');
    print('✓ 3 compras con items');
    print('✓ 3 traslados');
  }

  /// Limpia todos los datos
  Future<void> clearAllData() async {
    print('🗑️ Limpiando base de datos...');

    await db.customStatement('DELETE FROM sale_items');
    await db.customStatement('DELETE FROM sales');
    await db.customStatement('DELETE FROM purchase_items');
    await db.customStatement('DELETE FROM purchases');
    await db.customStatement('DELETE FROM transfers');
    await db.customStatement('DELETE FROM inventory');
    await db.customStatement('DELETE FROM product_variants');
    await db.customStatement('DELETE FROM products');
    await db.customStatement('DELETE FROM suppliers');

    print('✅ Base de datos limpiada');
  }
}
