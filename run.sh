#!/bin/bash

# Script para ejecutar la aplicación de inventario
# Uso: ./run.sh [opciones]

echo "🚀 Iniciando aplicación de Inventario Offline-First..."
echo ""

# Verificar si Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado"
    echo "Instala Flutter desde: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter encontrado: $(flutter --version | head -n 1)"
echo ""

# Opción 1: Sin Supabase (solo local)
if [ "$1" == "local" ]; then
    echo "🏃 Ejecutando en modo LOCAL (sin Supabase)..."
    flutter run
    exit 0
fi

# Opción 2: Con Supabase
if [ "$1" == "supabase" ]; then
    if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
        echo "⚠️  Variables de entorno no configuradas"
        echo "Por favor configura:"
        echo "  export SUPABASE_URL='https://tu-proyecto.supabase.co'"
        echo "  export SUPABASE_ANON_KEY='tu_anon_key'"
        echo ""
        echo "O pásalas directamente:"
        echo "  SUPABASE_URL=xxx SUPABASE_ANON_KEY=xxx ./run.sh supabase"
        exit 1
    fi
    
    echo "🌐 Ejecutando con Supabase..."
    flutter run \
        --dart-define=SUPABASE_URL="$SUPABASE_URL" \
        --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
    exit 0
fi

# Mostrar ayuda
echo "Uso: ./run.sh [opción]"
echo ""
echo "Opciones:"
echo "  local      - Ejecutar en modo local (sin Supabase)"
echo "  supabase   - Ejecutar con Supabase (requiere variables de entorno)"
echo ""
echo "Ejemplos:"
echo "  ./run.sh local"
echo "  SUPABASE_URL=xxx SUPABASE_ANON_KEY=xxx ./run.sh supabase"
echo ""
echo "Por defecto se ejecutará en modo local..."
flutter run
