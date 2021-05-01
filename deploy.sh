#!/usr/bin/bash

START=11
END=136
HOME_DIR=$(pwd)
CREATOR=$(whoami)

echo 
echo
echo "Enter an available lane number between 1-254  "
echo
read -p '  Lane Number:  ' LANE_NUM

echo
echo
echo "Enter the solution practice abbreviation - ex. Security = SEC,  Network = NET "
echo
read -p '  Solutions Practice Abbreviation:  ' PRACTICE

echo
echo
echo "Enter the requestor's name-"
echo
read -p '  Requestor:  ' OWNER

echo
echo
echo "Enter the cooresponding number of the vNGFW vendor "
echo "  1.  Fortinet"
echo "  2.  PaloAlto"
echo "  3.  Juniper"
echo "  4.  Sophos"
echo "  5.  Watchguard"
echo "  6.  Cisco - FMC/FTD"
echo "  7.  SaaS (no NGFW)"
echo "  8.  Fortinet BYOL"
read -p '  1-8: ' VENDOR_NUM

echo
echo 
echo "Add ThreatReplayer VM to lane?"
echo
read -p '  y or n: ' TERAPACKETS

if [[ ${TERAPACKETS} == "y" ]]; then
  echo
  echo "How many secondary IPs (1-125)?"
  echo
  read -p '  Secondary IPs: ' END_sel
  END=(${END_sel}+11);
fi

echo 
echo
echo "Add desktop VMs and servers for EDR solution?"
echo
read -p ' Diesktop - Windows 10 Pro - y or n: ' WIN
if [[ ${WIN} == "y" ]]; then
  echo
  read -p ' How many instances?: ' WIN_NUM
  DEVICE2_TYPE=W10
fi
echo
read -p ' Desktop - Debian 10 - y or n: ' LINUX
if [[ ${LINUX} == "y" ]]; then
  echo
  read -p ' How many instances?: ' LINUX_NUM
  DEVICE3_TYPE=D10
fi

if [[ ${VENDOR_NUM} == 1 ]]; then
  VENDOR=Fortinet
  DEVICE_TYPE=vNGFW
  echo
fi

if [[ ${VENDOR_NUM} == 2 ]]; then
  VENDOR=PaloAlto
  DEVICE_TYPE=vNGFW
  echo
fi

if [[ ${VENDOR_NUM} == 3 ]]; then
  VENDOR=Juniper
  DEVICE_TYPE=vNGFW
  echo
fi

if [[ ${VENDOR_NUM} == 4 ]]; then
  VENDOR=Sophos
  DEVICE_TYPE=vNGFW
  echo
fi

if [[ ${VENDOR_NUM} == 5 ]]; then
  VENDOR=Watchguard
  DEVICE_TYPE=vNGFW
  echo
fi

if [[ ${VENDOR_NUM} == 6 ]]; then
  VENDOR=Cisco
  DEVICE_TYPE=vFMC
  DEVICE1_TYPE=vFTD
fi

if [[ ${VENDOR_NUM} == 7 ]]; then
  VENDOR=SaaS
  DEVICE_TYPE=W10
fi

if [[ ${VENDOR_NUM} == 8 ]]; then
  VENDOR=FortinetBYOL
  DEVICE_TYPE=vNGFW
fi

cd ${HOME_DIR}
rm -f ${HOME_DIR}/vars.yml
LANE="L${LANE_NUM}"
LANE_RG="${PRACTICE}-${LANE}-${VENDOR}"
VMname=$(echo ${PRACTICE}-${LANE}-${DEVICE_TYPE} | tr '[:upper:]' '[:lower:]')
VMname1=$(echo ${PRACTICE}-${LANE}-${DEVICE1_TYPE} | tr '[:upper:]' '[:lower:]')
VMnameT=$(echo ${PRACTICE}-${LANE}-Terapackets | tr '[:upper:]' '[:lower:]')
VMname2=$(echo ${PRACTICE}-${LANE}-${DEVICE2_TYPE} | tr '[:upper:]' '[:lower:]')
VMname3=$(echo ${PRACTICE}-${LANE}-${DEVICE3_TYPE} | tr '[:upper:]' '[:lower:]')

echo 
echo
echo "Resource Group:  ${LANE_RG}"
echo
echo
echo "Deploying lane ${LANE_NUM}  "
echo
echo
echo
echo "HOLD PLEASE          "
echo
echo
echo
echo "lane: ${LANE}" > ${HOME_DIR}/vars.yml
echo "lane_num: ${LANE_NUM}" >> ${HOME_DIR}/vars.yml
echo "practice: ${PRACTICE}" >> ${HOME_DIR}/vars.yml
echo "vendor: ${VENDOR}" >> ${HOME_DIR}/vars.yml
echo "location: southcentralus" >> ${HOME_DIR}/vars.yml
echo "lane_rg: ${LANE_RG}" >> ${HOME_DIR}/vars.yml
echo "vendor2: ${VENDOR2}" >> ${HOME_DIR}/vars.yml
echo "vendor3: ${VENDOR3}" >> ${HOME_DIR}/vars.yml
echo "device_type: ${DEVICE_TYPE}" >> ${HOME_DIR}/vars.yml
echo "device1_type: ${DEVICE1_TYPE}" >> ${HOME_DIR}/vars.yml
echo "device2_type: ${DEVICE2_TYPE}" >> ${HOME_DIR}/vars.yml
echo "device3_type: ${DEVICE3_TYPE}" >> ${HOME_DIR}/vars.yml
echo "vm_name: ${VMname}" >> ${HOME_DIR}/vars.yml
echo "vm_name1: ${VMname1}" >> ${HOME_DIR}/vars.yml
echo "vm_name2: ${VMname2}" >> ${HOME_DIR}/vars.yml
echo "vm_name3: ${VMname3}" >> ${HOME_DIR}/vars.yml
echo "vm_nameT: ${VMnameT}" >> ${HOME_DIR}/vars.yml
echo "owner: ${OWNER}" >> ${HOME_DIR}/vars.yml
echo "creator: ${CREATOR}" >> ${HOME_DIR}/vars.yml


echo "ansible-playbook ./${VENDOR}.yml"
ansible-playbook ./${VENDOR}.yml
echo
echo
echo "az vm auto-shutdown --location southcentralus -g ${LANE_RG} -n ${PRACTICE}-${LANE}-${DEVICE_TYPE} --time 0300"
az vm auto-shutdown --location southcentralus -g ${LANE_RG} -n ${PRACTICE}-${LANE}-${DEVICE_TYPE} --time 0300

if [[ ${VENDOR_NUM} == 6 ]]; then
  echo "ansible-playbook ./CiscoFTD.yml"
  ansible-playbook ./CiscoFTD.yml
  echo
  echo
  echo "az vm auto-shutdown --location southcentralus -g ${LANE_RG} -n ${PRACTICE}-${LANE}-${DEVICE1_TYPE} --time 0300"
  az vm auto-shutdown --location southcentralus -g ${LANE_RG} -n ${PRACTICE}-${LANE}-${DEVICE1_TYPE} --time 0300
fi
if [[ ${TERAPACKETS} == "y" ]]; then
     
     echo "ansible-playbook ./Terapackets.yml"
     ansible-playbook ./Terapackets.yml
     echo
     echo     
     echo "az vm auto-shutdown -location southcentralus -g ${LANE_RG} -n ${PRACTICE}-${LANE}-Terapackets --time 0300"
     az vm auto-shutdown --location southcentralus -g ${LANE_RG} -n "${PRACTICE}-${LANE}-Terapackets" --time 0300
     echo
     echo
     echo
     echo "KEEP HOLDING"
     echo
     echo
     echo
     while [[ ${START} -le ${END} ]]; do
       echo ${START}
       az network nic ip-config create --resource-group ${LANE_RG} --nic-name ${PRACTICE}-${LANE}-TP-wan-nic --name 1488${START} --private-ip-address 10.${LANE_NUM}.3.${START}
       az network nic ip-config create --resource-group ${LANE_RG} --nic-name ${PRACTICE}-${LANE}-TP-internal-nic --name 88${START} --private-ip-address 10.${LANE_NUM}.1.${START}
       let "START=START+1";
       done
fi
if [[ ${WIN} == "y" ]]; then
     echo
     echo
     echo
     echo " KEEP HOLDING"
     echo
     echo
     echo
     COUNTER=1
     while [[ ${COUNTER} -le ${WIN_NUM} ]]; do 
      echo "ansible-playbook ./W10-${COUNTER}.yml"
      ansible-playbook ./W10-${COUNTER}.yml
      echo
      echo
      echo "az vm auto-shutdown --location southcentralus -g ${LANE_RG} -n ${PRACTICE}-${LANE}-W10-${COUNTER} --time 0300"
      az vm auto-shutdown --location southcentralus -g ${LANE_RG} -n ${PRACTICE}-${LANE}-W10-${COUNTER} --time 0300
      let "COUNTER=COUNTER+1"
      echo
      echo
      done
fi

if [[ ${LINUX} == "y" ]]; then
     COUNTER=1
     echo
     echo " Viva La Revolution!!! "
     echo
     echo
     while [[ ${COUNTER} -le ${LINUX_NUM} ]]; do 
      echo "ansible-playbook ./D10-${COUNTER}.yml"
      ansible-playbook ./D10-${COUNTER}.yml
      echo
      echo
      echo "az vm auto-shutdown --location southcentralus -g ${LANE_RG} -n ${PRACTICE}-${LANE}-D10-${COUNTER} --time 0300"
      az vm auto-shutdown --location southcentralus -g ${LANE_RG} -n ${PRACTICE}-${LANE}-D10-${COUNTER} --time 0300
      let "COUNTER=COUNTER+1"
      echo
      echo
      done
fi

echo
echo
echo
echo "Thank you for holding"
echo
echo "Please continue to hold until the ride has come to a complete stop"
echo
echo
echo 
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
date
echo
echo
echo
echo "                <<  <<  -      LANE      -  >>  >>  "
echo "                  >>  >>  - SUCCESSFUL -  <<  <<    "
echo
echo
echo
echo "  SUMMARY    "
echo
echo "   - Solutions Practice: ${PRACTICE}"
echo
echo "   - Lane: ${LANE}"
echo
echo "   - Requester: ${OWNER}"
echo
echo "   - Resource Group:  ${LANE_RG}"
echo
echo "   - ${DEVICE_TYPE}: ${PRACTICE}-${LANE}-${DEVICE_TYPE}"
echo "   - ${VENDOR} ${DEVICE_TYPE} Public IP: $(az vm show -d -g ${LANE_RG} -n ${PRACTICE}-${LANE}-${DEVICE_TYPE} --query publicIps -o tsv)"
echo "       https://$(az vm show -d -g ${LANE_RG} -n ${PRACTICE}-${LANE}-${DEVICE_TYPE} --query publicIps -o tsv)/"
echo

if [[ ${VENDOR_NUM} == "6" ]]; then
  echo "   - VM: ${PRACTICE}-${LANE}-${DEVICE1_TYPE}"
  echo "   - ${VENDOR} ${DEVICE1_TYPE} Public IP: $(az vm show -d -g ${LANE_RG} -n ${PRACTICE}-${LANE}-${DEVICE1_TYPE} --query publicIps -o tsv)"
  echo "       ssh shi@$(az vm show -d -g ${LANE_RG} -n ${PRACTICE}-${LANE}-${DEVICE1_TYPE} --query publicIps -o tsv)"
  echo
fi

if [[ ${WIN} == "y" ]]; then
  echo "   - VM: ${PRACTICE}-${LANE}-w10-1"
  echo "   - Windows 10 W10-1 Public IP: $(az vm show -d -g ${LANE_RG} -n ${PRACTICE}-${LANE}-W10-1 --query publicIps -o tsv)"
  echo "       mstsc /v:$(az vm show -d -g ${LANE_RG} -n ${PRACTICE}-${LANE}-W10-1 --query publicIps -o tsv) /prompt"
  echo
fi

if [[ ${LINUX} == "y" ]]; then
  echo "   - VM: ${PRACTICE}-${LANE}-D10-1"
  echo "   - Debian 10 D10-1 Public IP: $(az vm show -d -g ${LANE_RG} -n ${PRACTICE}-${LANE}-D10-1 --query publicIps -o tsv)"
  echo "       ssh shi@$(az vm show -d -g ${LANE_RG} -n ${PRACTICE}-${LANE}-D10-1 --query publicIps -o tsv)"
  echo
fi

if [[ ${TERAPACKETS} == "y" ]]; then
  echo "   - VM: ${PRACTICE}-${LANE}-Terapackets"
  echo "   - ThreatReplayer Public IP: $(az vm show -d -g ${LANE_RG} -n ${PRACTICE}-${LANE}-Terapackets --query publicIps -o tsv)"
  echo "       ssh shi@$(az vm show -d -g ${LANE_RG} -n ${PRACTICE}-${LANE}-Terapackets --query publicIps -o tsv)"
  echo
fi
echo "   - Login Credentials:  shi / 5ecur!ty_10I    "
echo
echo
echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
echo
echo "Test Lane Deployment Script"
echo "Rev. 0.4.25-MTW"
echo
echo "SHI | ASG Test Engineering"
echo "4/2021"
echo 
echo