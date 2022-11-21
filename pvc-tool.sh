#!/bin/bash

# © Copyright IBM Corporation 2022
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [[ -z "$1" ]] ; then
    echo 'Error: A queue manager name must be specified.'
    echo 'Usage: ./pvc-tool.sh <queue-manager name> <queue-manager namespace>'
    exit 0
fi

if [[ -z "$2" ]] ; then
    echo 'Error: A namespace has not been specified.'
    echo 'Usage: ./pvc-tool.sh <queue-manager name> <queue-manager namespace>'
    exit 0
fi

echo -e "Queue Manager Name: $1 \n"

qmpods=$(oc get pods -n $2 -l app.kubernetes.io/instance=$1 -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
echo -e "Queue Manager Pods: \n$qmpods\n"

podi=0
pvci=0
if [ -n "$qmpods" ]; then
    for i in ${qmpods[@]}
    do 
    echo -ne "\nSetting up pvc-inspector for pod ${i} ... \n" 
    worker=$(oc get pod -n $2 $i -o go-template='{{.spec.nodeName}}{{"\n"}}')
    echo "Worker: $worker"
    pvcs=$(oc get pod -n $2 $i -o go-template='{{- range .spec.volumes -}}{{- if .persistentVolumeClaim -}}{{.persistentVolumeClaim.claimName}}{{"\n"}}{{end}}{{end}}')
    echo -e $pvcs
    if [ -n "$pvcs" ]; then
        export WORKER=$worker
        export NAME=$i
        let podi=podi+1
        let pvci=0
        for pvc in ${pvcs[@]}
        do
        let pvci=pvci+1
        export "MOUNT${pvci}"=$pvc
        done
        echo -e "Mounting $pvci PVCs: \n$pvcs"
        echo -e "\n"
        if [[ "$pvci" -eq 1 ]]; then
            ( echo "cat <<EOF" ; cat pvc-inspector-1.yaml_template ; echo EOF ) | sh > pvc-inspector.yaml
        elif [[ "$pvci" -eq 2 ]]; then
            ( echo "cat <<EOF" ; cat pvc-inspector-2.yaml_template ; echo EOF ) | sh > pvc-inspector.yaml
        else
            ( echo "cat <<EOF" ; cat pvc-inspector-3.yaml_template ; echo EOF ) | sh > pvc-inspector.yaml
        fi
        oc apply -n $2 -f pvc-inspector.yaml
    else
        echo 'Warning: No PVCs found. Check that the specified Queue Manager is not using ephemeral storage.'
    fi
    done
else
    echo 'Warning: No Queue Manager pods found. Check that the Queue Manager name is correct.'
fi