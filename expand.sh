#!/bin/bash

# Variables
DISK="/dev/sda"                           # Cambia si no es el disco correcto
PART="${DISK}1"                            # Partición
LUKS_DEV="/dev/mapper/luks-604d8a28-62ea-4586-a3bc-7fdf66fec7e1"  # Cambia si el LUKS es diferente

# Verificar si el script se ejecuta como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script debe ejecutarse como root."
  exit 1
fi

# Expande la partición usando parted
echo "Redimensionando la partición $PART a su tamaño máximo..."
parted --script "$DISK" resizepart 1 100%
if [ $? -ne 0 ]; then
  echo "Error redimensionando la partición. Abortando."
  exit 1
fi

# Redimensionar el contenedor LUKS
echo "Redimensionando el contenedor LUKS..."
cryptsetup resize "$LUKS_DEV"
if [ $? -ne 0 ]; then
  echo "Error redimensionando el contenedor LUKS. Abortando."
  exit 1
fi

# Redimensionar el sistema de archivos (ext4)
echo "Redimensionando el sistema de archivos ext4..."
resize2fs "$LUKS_DEV"
if [ $? -ne 0 ]; then
  echo "Error redimensionando el sistema de archivos. Abortando."
  exit 1
fi

# Verificar el nuevo tamaño
echo "Verificando el nuevo tamaño del sistema de archivos..."
df -h | grep "$LUKS_DEV"

echo "Proceso completado exitosamente. El espacio en disco ha sido expandido."
