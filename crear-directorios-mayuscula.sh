#!/bin/bash

for rutas in $(cat rutas); do
    # Convertir el nombre del directorio a mayúsculas
    RUTAS_UPPER=$(echo "$rutas" | tr '[:lower:]' '[:upper:]')
    
    # Cambiar al directorio especificado
    if cd "$rutas"; then
        # Crear un subdirectorio con el nombre en mayúsculas
        mkdir "$RUTAS_UPPER"
        # Volver al directorio anterior
        cd - > /dev/null
    else
        echo "Error: No se pudo acceder al directorio $rutas"
    fi
done

