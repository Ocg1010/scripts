#!/bin/bash

for rutas in $(cat rutas); do
    # Convertir el nombre del directorio a mayúsculas
    RUTAS_UPPER=$(echo "$rutas" | tr '[:lower:]' '[:upper:]')
    RUTAS_LOWER=$(echo "$rutas")

    # Cambiar al directorio especificado
    if cd "$rutas"; then
      # Crear un subdirectorio con el nombre en mayúsculas
      # Ingresar a directorio trace
	    cd ${RUTAS_UPPER}2
	    cd alert/ 
	    touch log.xml  
      # Volver al directorio anterior
      cd /u01/app/oracle/diag/rdbms
    else
        echo "Error: No se pudo acceder al directorio $rutas, creando directorio"

    fi
done

