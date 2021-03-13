#### KUBERNETES MANIFESTS DEPLOYMENT USING INGRESS

My project explains how we can make use of nginx-ingress controllers to expose our services to outer-world using LoadBalancers being backed up by Ingress.

1. Ingress

   An API object that manages external access to the services in a cluster, typically HTTP.

   Ingress may provide load balancing, SSL termination and name-based virtual hosting.

   Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

   An Ingress may be configured to give Services externally-reachable URLs, load balance traffic, terminate SSL / TLS, and offer name-based virtual hosting. An Ingress controller is responsible for fulfilling the Ingress, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

   An Ingress does not expose arbitrary ports or protocols. Exposing services other than HTTP and HTTPS to the internet typically uses a service of type Service.Type=NodePort or Service.Type=LoadBalancer.

Thereby, I have made use of Host-Based Routing Mechanism for Ingress where precise matches require that the HTTP host header matches the host field. Wildcard matches require the HTTP host header is equal to the suffix of the wildcard rule.

Also in this project i have made use of EFS (AWS FileSystem) to store filesystem data as a replica for the default volume (network file system ) provided by Kubernetes. The use of volumes is because of persistency as in kubernetes if any application is deployed with no persistent setup, the data produced or consumed by the application becomes ephermal and if the container crashes the kubelet will restart the container to maintain the desired state but this time the container will be launched with a clean state.

Now, to use EFS as the persistent volume for applications deployed in Kubernetes I have made use of the EFS CSI Drivers (Container Storage Interface).

The official Documentation on this is provided by AWS.

    https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html
