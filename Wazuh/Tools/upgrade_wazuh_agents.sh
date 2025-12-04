#!/bin/bash
# Script en shell para actualizar todos los agentes que hay activos en una instalación de Wazuh, si el agente esta actualizado da un error, indica que esta actualizado
# y va al siguiente (como mejora se puede cruzar la lista de agentes activos, con los que necesitan actualización)
# Recordar los agentes no deben estar nunca en versión superior al Wazuh Server
#
# @risingonline
# Fecha: 04/12/2025

PATH_COMPOSER=/siem/wazuh
PATH_ACTUAL=$(pwd)
LIST_FILE=/tmp/agent.lst

cd $PATH_COMPOSER
AGENTES_ACTIVOS=$(docker compose exec wazuh.manager bash -c "/var/ossec/bin/agent_control -lc | grep [0-9] | grep -v 000 | cut -d"," -f1 | sed 's/   ID: //g'" | tee $LIST_FILE)
echo "Actualizando agentes Wazuh activos: "
echo "$AGENTES_ACTIVOS"
for ID in $(cat $LIST_FILE)
do
        docker compose exec wazuh.manager bash -c "/var/ossec/bin/agent_upgrade -a $ID"
        if [ $? == 0 ]
        then
                echo "Agente Wazuh $ID esta actualizado."
        else
                RC=$?
                echo "Revisar manualmente el estado del agente $ID, ha habido algún problema."
        fi
done
cd $PATH_ACTUAL
exit $RC