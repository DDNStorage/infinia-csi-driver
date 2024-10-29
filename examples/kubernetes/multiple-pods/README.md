#simple utility to create multiple pods with one dynamic volume per pod

How to use:
1. Apply common StorageClass for all pods `lubectl apply -f examples/kubernetes/multiple-pods/storage-class.yaml`
2. Create required amount of pods `./examples/kubernetes/multiple-pods/launch.sh -c {required_amount}`


Cleanup:
1. Delete pods `./examples/kubernetes/multiple-pods/launch.sh -c {required_amount} -d`

`-c {required_amount}` could be skipped, the default value is 10 pods

