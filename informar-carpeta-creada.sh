#!/bin/bash

# Nombre del archivo que contiene las rutas a monitorear
RUTAS_FILE="rutas"
# Archivo de log donde se registrarán los cambios
LOG_FILE="/opt/directory_monitor.log"

# Lee las rutas desde el archivo y las guarda en un array
mapfile -t MONITORED_DIRS < "$RUTAS_FILE"

# Inicializa un array para almacenar el conteo de directorios en cada ruta
declare -A DIR_COUNTS

# Captura el conteo inicial de directorios para cada ruta
for dir in "${MONITORED_DIRS[@]}"; do
    DIR_COUNTS["$dir"]=$(find "$dir" -type d | wc -l)
done

while true; do
    sleep 10  # Intervalo de tiempo entre verificaciones

    # Recorre cada ruta monitoreada
    for dir in "${MONITORED_DIRS[@]}"; do
        CURRENT_COUNT=$(find "$dir" -type d | wc -l)  # Obtiene el conteo actual de directorios

        # Compara el conteo actual con el anterior
        if [ "$CURRENT_COUNT" -ne "${DIR_COUNTS[$dir]}" ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Cambio detectado en $dir: Contador de directorios pasó de ${DIR_COUNTS[$dir]} a $CURRENT_COUNT" >> "$LOG_FILE"
            # Actualiza el conteo después de registrar el cambio
            DIR_COUNTS["$dir"]=$CURRENT_COUNT
        fi
    done
done

