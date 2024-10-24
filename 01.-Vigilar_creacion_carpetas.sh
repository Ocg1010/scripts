#!/bin/bash

# Archivo de log donde se registrarán los cambios
LOG_FILE="/opt/directory_monitor.log"
# Tamaño máximo permitido para el log (500 MB)
MAX_LOG_SIZE=$((500 * 1024 * 1024))

# Función para comprimir el log si excede el tamaño máximo
compressLog() {
  if [ -f "${LOG_FILE}" ] && [ $(stat -c%s "${LOG_FILE}") -ge "${MAX_LOG_SIZE}" ]; then
    TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')  # Formato de fecha y hora legible
    bzip2 "${LOG_FILE}"  # Comprimir el archivo log usando bzip2
    mv "${LOG_FILE}.bz2" "${LOG_FILE%.log}_${TIMESTAMP}.log.bz2"  # Renombrar el archivo comprimido
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Log comprimido debido al tamaño" > "${LOG_FILE}"  # Reiniciar el log original
  fi
}

# Función para escribir en el log y luego comprobar si es necesario comprimir
writeLog() {
    echo "$1" >> "${LOG_FILE}"
    compressLog  # Comprimir solo después de escribir en el log
}

# Función para monitorear una ruta
monitorRuta() {
    local ruta="$1"
    local iniciales="${INITIAL_DIRS[$ruta]}"
    
    CURRENT_DIRS=($(find "${ruta}" -mindepth 1 -maxdepth 1 -type d | sort))
    NEW_DIRS=($(comm -13 <(printf "%s\n" "${iniciales}") <(printf "%s\n" "${CURRENT_DIRS[@]}")))

    if [ ${#NEW_DIRS[@]} -gt 0 ]; then
        for dir in "${NEW_DIRS[@]}"; do
            writeLog "$(date '+%Y-%m-%d %H:%M:%S') - Nueva carpeta creada en ${ruta}: ${dir}"
        done
        INITIAL_DIRS["$ruta"]=$(printf "%s\n" "${CURRENT_DIRS[@]}")
    fi
}

# Inicializar un array para almacenar los directorios iniciales
declare -A INITIAL_DIRS

# Leer rutas de prueba.txt y expandirlas correctamente
while IFS= read -r ruta; do
    for i in $ruta; do  # Expandir rutas con comodines
        INITIAL_DIRS["$i"]=$(find "${i}" -mindepth 1 -maxdepth 1 -type d | sort)
    done
done < prueba.txt


# Monitorear cambios en un bucle infinito
while true; do
  sleep 10  # Esperar 10 segundos antes del siguiente chequeo

  # Iterar sobre las rutas y comparar los directorios
  while IFS= read -r ruta; do
    for i in $ruta; do  # Expandir las rutas con comodines
        monitorRuta "$i"
    done
  done < prueba.txt

  # Llamar a la función para comprimir el log si es necesario
  compressLog
done
