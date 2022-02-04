#!/bin/bash

#######################################
# Configuration Initialization Script #
#######################################

set -x

if [[ -z "$1" ]]
then
  echo "[ERROR][config.sh] - An IBM API Connect installation OpenShift poject was not provided"
  exit 1
else
  APIC_NAMESPACE=$1
  echo "IBM API Connect has been installed in the ${APIC_NAMESPACE} OpenShift project"
fi

if [[ -z "$2" ]]
then
  # Get the name of the IBM API Connect Cluster instance
  if [ `oc get APIConnectCluster -n ${APIC_NAMESPACE} --no-headers | wc -l` -eq 1 ]
  then 
    APIC_CLUSTER_NAME=`oc get APIConnectCluster -n tools --no-headers | awk '{print $1}'`
    echo "IBM API Connect Cluster instance name is ${APIC_CLUSTER_NAME}"
  else
    echo "[ERROR][config.sh] - There are none or multiple IBM API Connect Cluster instances. Please, make sure you have an instance of IBM API Connect Cluster or provide what instance to work with as second input parameter if mutliple IBM API Connect Cluster instances available"
    exit 1
  fi
else
  APIC_CLUSTER_NAME=$2
  echo "IBM API Connect Cluster instance name is ${APIC_CLUSTER_NAME}"
fi


# Make a configuration files directory
cd ..
rm -rf config
mkdir config
cd config

# Get the needed URLs for the automation
APIC_PLATFORM_API_URL=`oc -n ${APIC_NAMESPACE} get mgmt ${APIC_CLUSTER_NAME}-mgmt -o jsonpath="{.status.zenRoute}" && echo ""`
if [[ -z "${APIC_PLATFORM_API_URL}" ]]; then echo "[ERROR][config.sh] - An error ocurred getting the IBM API Connect Platform API url"; exit 1; fi
APIC_GATEWAY_URL=`oc get routes -n ${APIC_NAMESPACE} | grep gateway | grep -v manager | awk '{print $2}'`
if [[ -z "${APIC_GATEWAY_URL}" ]]; then echo "[ERROR][config.sh] - An error ocurred getting the IBM API Connect Gateway url"; exit 1; fi

# Storing the urls in the JSON config file
echo "{" >> config.json
echo "\"APIC_PLATFORM_API_URL\":\"${APIC_PLATFORM_API_URL}\"," >> config.json
echo "\"APIC_GATEWAY_URL\":\"${APIC_GATEWAY_URL}\"" >> config.json
echo "}" >> config.json


# DEBUG information
if [[ ! -z "${DEBUG}" ]]
then
  echo "This is the environment configuration"
  echo "-------------------------------------"
  cat config.json
fi
