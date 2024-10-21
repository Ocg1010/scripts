#!/bin/bash

# Archivo de log donde se registrarán los cambios
LOG_FILE="directory_monitor.log"
# Tamaño máximo permitido para el log (500 MB)
MAX_LOG_SIZE=$((500 * 1024 * 1024))

# Ruta de referencia
RUTA="/u01/app/oracle/diag/rdbms/*/*/incident/"

# Función para comprimir el log si excede el tamaño máximo
compress_log() {
    if [ -f "${LOG_FILE}" ] && [ $(stat -c%s "${LOG_FILE}") -ge "${MAX_LOG_SIZE}" ]; then
        TIMESTAMP=$(date '+%Y%m%d%H%M%S')
        gzip "${LOG_FILE}"
        mv "${LOG_FILE}.gz" "${LOG_FILE%.log}_${TIMESTAMP}.log.gz"
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Log comprimido debido al tamaño" > "${LOG_FILE}"
    fi
}

# Bucle infinito para monitorear los cambios
initial_dirs=($(find ${RUTA} -mindepth 1 -maxdepth 1 -type d | sort))
initial_count=${#initial_dirs[@]}
echo -e "[+] Inicialmente tenemos este conteo: ${initial_count}"

while true; do
    sleep 10  # Esperar 10 segundos antes del siguiente chequeo
    current_dirs=($(find ${RUTA} -mindepth 1 -maxdepth 1 -type d | sort))
    new_dirs=($(comm -13 <(printf "%s\n" "${initial_dirs[@]}") <(printf "%s\n" "${current_dirs[@]}")))

    # Verificar si hay nuevas carpetas
    if [ ${#new_dirs[@]} -gt 0 ]; then
        echo -e "[!] Nuevas carpetas creadas:"
        for dir in "${new_dirs[@]}"; do
            echo -e "[+] ${dir}"
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Nueva carpeta creada: ${dir}" >> "${LOG_FILE}"
        done
        initial_dirs=("${current_dirs[@]}")  # Actualizar la lista de directorios iniciales
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Sin cambios: ${#current_dirs[@]} directorios existentes." >> "${LOG_FILE}"
        echo -e "[!] Sin cambios: ${#current_dirs[@]} directorios existentes."
    fi

    # Actualizar el conteo de directorios
    initial_count=${#current_dirs[@]}
    echo -e "[+] Ahora tenemos este conteo: ${initial_count}"

    # Llamar a la función para comprimir el log si es necesario
    compress_log
done
