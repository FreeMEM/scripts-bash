#!/bin/bash

# Obtener información del sistema
memoria_disponible=$(free -h | awk '/Mem:/{print $4}')
espacio_disco=$(df -h | awk '$NF=="/"{print $4}')
carga_sistema=$(uptime | awk -F 'load average:' '{print $2}')

# Comprobamos el estado de Nginx
nginx_status=$(/usr/sbin/service nginx status)
nginx_start=$(/usr/sbin/service nginx start)

# Verificamos si Nginx no está activo
if [[ ! $nginx_status =~ "active (running)" ]]; then
    mensaje="Nginx no está corriendo. Iniciando Nginx...

Información adicional:
- Memoria disponible: $memoria_disponible
- Espacio en disco: $espacio_disco
- Carga del sistema: $carga_sistema"

    echo "$mensaje"
    logger -t nginx_checker "$mensaje"
    # Iniciamos Nginx
    $nginx_start 

    # Verificamos el estado después de iniciar Nginx
    if [[ $nginx_status =~ "active (running)" ]]; then
        mensaje="Nginx se ha iniciado correctamente."
	logger -t nginx_checker "$mensaje"
	#echo "$mensaje" | mailx -s "Estado de Nginx" -r "$REMITENTE" -S smtp="$SMTP_SERVER:$SMTP_PORT" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$SMTP_USERNAME" -S smtp-auth-password="$SMTP_PASSWORD" "$DESTINATARIO"
    else
        mensaje="Hubo un problema al iniciar Nginx. Por favor, revisa los registros de error."
	logger -t nginx_checker "$mensaje"
        #echo "$mensaje" | mailx -s "Estado de Nginx" -r "$REMITENTE" -S smtp="$SMTP_SERVER:$SMTP_PORT" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$SMTP_USERNAME" -S smtp-auth-password="$SMTP_PASSWORD" "$DESTINATARIO" 
    fi
fi