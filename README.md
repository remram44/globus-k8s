Globus Connect for Kubernetes
=============================

This repository contains images and manifests to run a Globus endpoint on Kubernetes.

Globus Connect can either be run stand-alone or as a sidecar container.

Step 1: Create a PersistentVolumeClaim for the Globus state
-----------------------------------------------------------

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: globus-state
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
  volumeMode: Filesystem
```

```console
$ kubectl create -f globus-volume.yml
```

Step 2: Add the sidecar container to your application
-----------------------------------------------------

Add the Globus container to your Pod, by editing your application's manifest. You can also run Globus as a stand-alone Pod if you don't use a volume that is exclusively attached in another.

You should mount the volumes to be shared using `volumeMounts` and list them in the `GLOBUS_PATHS` environment variable using [the Globus configuration format](https://docs.globus.org/globus-connect-personal/install/linux/#config-paths).

```yaml
...
spec:
  securityContext:
    fsGroup: 2000
    fsGroupChangePolicy: OnRootMismatch
  containers:
    - ... # Your existing containers
    - name: globus-connect
      image: ghcr.io/remram44/globus-k8s
      #securityContext:
      #  runAsUser: 472 # Optional, run as a specific user ID
      volumeMounts:
        - name: globus-state
          mountPath: /var/lib/globus/lta
        - name: data
          mountPath: /data
        - name: model
          mountPath: /models
      env:
        - name: GLOBUS_PATHS
          # List of paths to export
          # <path>,<sharing flag>,<write flag>
          # sharing flag:
          #     1 allows sharing for the path, 0 disallows sharing
          #     (unavailable with Connect Personal)
          # write flag:
          #     1 allows read+write access, 0 allows read-only access
          # See also https://docs.globus.org/globus-connect-personal/install/linux/#config-paths
          # Alternatively, mount a file over /var/lib/globus/lta/config-paths
          value: |
            /data,0,1
            /models,0,0
  volumes:
    - ...
    - name: globus-state
      persistentVolumeClaim:
        claimName: globus-state
```

Step 3: Register your endpoint with Globus
------------------------------------------

Run the following command:

```console
$ kubectl exec -ti -c globus-connect deploy/my-app -- setup
```

And follow the steps to associate this instance of Globus Connect Personal with your Globus account.

Once this is done, you will be able to see it in the Globus file browser under the name you chose. Please refer to [their documentation](https://docs.globus.org/guides/tutorials/manage-files/transfer-files/) to transfer files.
