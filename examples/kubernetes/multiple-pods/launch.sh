#!/bin/bash

count=10
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

while getopts dc: flag
do
    case "${flag}" in
        d) delete=1;;
        c) count=${OPTARG};;
    esac
done

for (( i = 1; i <= $count; i++ )) ; do
    if [ -z ${delete} ]; then
      echo "creating $i pod"
      sed "s/{{pod-index}}/$i/g" $SCRIPTPATH/pod-template.yaml | kubectl apply -f - ;
    else
      echo "deleting $i pod"
      sed "s/{{pod-index}}/$i/g" $SCRIPTPATH/pod-template.yaml | kubectl delete --force -f - ;
    fi
done
