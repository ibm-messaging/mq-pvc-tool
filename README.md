# MQ PVC Inspector tool

This tool is designed to be used with MQ on Red Hat OpenShift Container Platform or Kubernetes.
The tool enables errors and other information to be gathered from the PVCs of a Queue Manager in the case where the Queue Manager pod cannot be directly accessed.
This could be due to a CrashLoopBackoff, Error or some other cause.

In OpenShift a Queue Manager can have multiple pods associated with it, and each of those pods can have multiple PVCs.
This tool will mount the PVCs associated with all Queue Manager pods of a Queue Manager deployment to a set of PVC inspector pods.
By mounting the PVCs to the inspector pods the files can be accessed within the inspector pods.


## Running the tool

1. To use the tool simply run:`./pvc-tool.sh <queue-manager name> <queue-manager namespace>`

    Between 1 and 3 PVC inspector pods will be created.
    Each inspector pod corresponds to each of the queue manager pods and their files.

1. To access the files run: 
`oc rsh <pvc-inspector-pod-name>`

    The pod contains a folder for each of the PVCs that have been mounted.
    Its name is the same as that of the PVC.

1. To cleanup the PVC inspector pods simply run:
`oc delete pods -l tool=mq-pvc-inspector`

    This will delete all PVC inspector pods. It will cause no change to the queue manager or PVCs themselves.

## Issues and contributions

For issues relating to this tool, please use the GitHub issue tracker associated with this repository. If you do submit a Pull Request related to this tool, please indicate in the Pull Request that you accept and agree to be bound by the terms of the [Developer's Certificate of Origin](DCO1.1.txt).

## Copyright

© Copyright IBM Corporation 2022