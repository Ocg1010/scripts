#!/bin/bash

# Archivo de log donde se registrarán los cambios
LOG_FILE="/opt/directory_monitor.log"
# Tamaño máximo permitido para el log (500 MB)
MAX_LOG_SIZE=$((500 * 1024 * 1024))

# Ruta de referencia
RUTA="/u01/app/oracle/diag/rdbms/*/*/incident/"

# Función para comprimir el log si excede el tamaño máximo
compressLog() {
  if [ -f "${LOG_FILE}" ] && [ $(stat -c%s "${LOG_FILE}") -ge "${MAX_LOG_SIZE}" ]; then
    TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')  # Formato de fecha y hora legible
    bzip2 "${LOG_FILE}"  # Comprimir el archivo log usando bzip2
    mv "${LOG_FILE}.bz2" "${LOG_FILE%.log}_${TIMESTAMP}.log.bz2"  # Renombrar el archivo comprimido
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Log comprimido debido al tamaño" > "${LOG_FILE}"  # Reiniciar el log original
  fi
}

# Bucle infinito para monitorear los cambios
INITIAL_DIRS=($(find ${RUTA} -mindepth 1 -maxdepth 1 -type d | sort))
INITIAL_COUNT=${#INITIAL_DIRS[@]}
#echo -e "[+] Inicialmente tenemos este conteo: ${INITIAL_COUNT}"

while true; do
  sleep 10  # Esperar 10 segundos antes del siguiente chequeo
  CURRENT_DIRS=($(find ${RUTA} -mindepth 1 -maxdepth 1 -type d | sort))
  NEW_DIRS=($(comm -13 <(printf "%s\n" "${INITIAL_DIRS[@]}") <(printf "%s\n" "${CURRENT_DIRS[@]}")))

  # Verificar si hay nuevas carpetas
  if [ ${#NEW_DIRS[@]} -gt 0 ]; then
        #echo -e "[!] Nuevas carpetas creadas:"
    for dir in "${NEW_DIRS[@]}"; do
      #echo -e "[+] ${dir}"
      echo "$(date '+%Y-%m-%d %H:%M:%S') - Nueva carpeta creada: ${dir}" >> "${LOG_FILE}"
    done
        INITIAL_DIRS=("${CURRENT_DIRS[@]}")  # Actualizar la lista de directorios iniciales
  else
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Sin cambios: ${#CURRENT_DIRS[@]} directorios existentes." >> /dev/null
        #echo -e "[!] Sin cambios: ${#CURRENT_DIRS[@]} directorios existentes."
  fi

  # Actualizar el conteo de directorios
  INITIAL_COUNT=${#CURRENT_DIRS[@]}
  #echo -e "[+] Ahora tenemos este conteo: ${INITIAL_COUNT}"
  # Llamar a la función para comprimir el log si es necesario
  compressLog
done

