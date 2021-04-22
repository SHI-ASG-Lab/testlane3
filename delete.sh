#!/usr/bin/bash
echo
echo
echo "Enter name of resource group to be deleted -"
echo
read -p '  Resource group name: ' LANE_RG
echo
echo
echo "${LANE_RG} will be deleted "
echo
echo
az group delete --name ${LANE_RG}
