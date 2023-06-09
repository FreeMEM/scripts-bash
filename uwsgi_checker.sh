#!/bin/bash

# Obtener información del sistema
memoria_disponible=$(free -h | awk '/Mem:/{print $4}')
espacio_disco=$(df -h | awk '$NF=="/"{print $4}')
carga_sistema=$(uptime | awk -F 'load average:' '{print $2}')
tail_uwsgi=$(tail -100 /var/log/uwsgi/app/django.log)
tail_syslog=$(tail -100 /var/log/syslog)

# Comprobamos el estado de Nginx
nginx_status=$(/usr/sbin/service uwsgi status)
nginx_start=$(/usr/sbin/service uwsgi start)

# Verificamos si Nginx no está activo
if [[ ! $nginx_status =~ "active (running)" ]]; then
    mensaje="Uwsgi no está corriendo. Iniciando uwsgi...

Información adicional:
- Memoria disponible: $memoria_disponible
- Espacio en disco: $espacio_disco
- Carga del sistema: $carga_sistema

Últimas 100 líneas de /var/log/uwsgi/app/django.log
$tail_uwsgi

Últimas 100 líneas de syslog
$tail_syslog
"

    echo "$mensaje"
    logger -t uwsgi_checker "$mensaje"
    # Iniciamos uwsgi
    $uwsgi_start 

    # Verificamos el estado después de iniciar uwsgi
    if [[ $uwsgi_status =~ "active (running)" ]]; then
        mensaje="uwsgi se ha iniciado correctamente."
	logger -t uwsgi_checker "$mensaje"
	#echo "$mensaje" | mailx -s "Estado de uwsgi" -r "$REMITENTE" -S smtp="$SMTP_SERVER:$SMTP_PORT" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$SMTP_USERNAME" -S smtp-auth-password="$SMTP_PASSWORD" "$DESTINATARIO"
    else
        mensaje="Hubo un problema al iniciar uwsgi. Por favor, revisa los registros de error."
	logger -t uwsgi_checker "$mensaje"
        #echo "$mensaje" | mailx -s "Estado de Nginx" -r "$REMITENTE" -S smtp="$SMTP_SERVER:$SMTP_PORT" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$SMTP_USERNAME" -S smtp-auth-password="$SMTP_PASSWORD" "$DESTINATARIO" 
    fi
fi