#!/bin/bash

################################
#
# Nombre: gestor_paquetes.sh
# Autor: Rafael Martín Mayor <rmarmay2004@gmail.com>
#
# Objetivo: Gestionar paquetes.
#
# Entradas: Nombre del paquete.
# Salidas: Gestionado de dicho paquete.
#
# Historial:
#   2024-02-08: versión final
#
################################


# Verifica si el paquete está instalado en el sistema
check_installed() {
    dpkg -s $1 > /dev/null 2>&1
    return $?
}

# Función para buscar el paquete en los repositorios
search_package() {
    apt search $1 | grep -E "^$1/"
}

# Función para mostrar la información del paquete
show_package_info() {
    apt show $1
}

# Función para instalar el paquete
install_package() {
    sudo apt install $1
}

# Función para actualizar el paquete
update_package() {
    sudo apt install --only-upgrade $1
}

# Función para eliminar el paquete
remove_package() {
    sudo apt remove $1
}

# Función para eliminar totalmente el paquete
purge_package() {
    sudo apt purge $1
}

# Solicitar al usuario el nombre del paquete si no se proporciona como argumento
if [ -z "$1" ]; then
    read -p "Por favor, introduce el nombre del paquete: " package_name
else
    package_name=$1
fi

# Sincronizar el listado de software local
sudo apt update

# Verificar si el paquete está instalado
if check_installed $package_name; then
    echo "El paquete $package_name está instalado."
    echo "1. Mostrar versión"
    echo "2. Reinstalar"
    echo "3. Actualizar"
    echo "4. Eliminar (guardando la configuración)"
    echo "5. Eliminar totalmente"

    read -p "Selecciona una opción (1-5): " option

    case $option in
        1)
            dpkg -l | grep $package_name
            ;;
        2)
            remove_package $package_name
            install_package $package_name
            ;;
        3)
            update_package $package_name
            ;;
        4)
            remove_package $package_name
            ;;
        5)
            purge_package $package_name
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
else
    echo "El paquete $package_name no está instalado."

    # Verificar si el paquete existe en los repositorios
    if search_package $package_name; then
        echo "El paquete $package_name existe en los repositorios."
        show_package_info $package_name

        read -p "¿Quieres instalar el paquete? (y/n): " install_option
        if [ "$install_option" == "y" ]; then
            install_package $package_name
        fi
    else
        echo "No hay ningún paquete que se llame $package_name en los repositorios."
        echo "Resultado de la búsqueda:"
        search_package $package_name
    fi
fi
