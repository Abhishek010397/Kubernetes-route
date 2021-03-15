#### KUBERNETES MANIFESTS DEPLOYMENT USING INGRESS

My project explains how we can make use of nginx-ingress controllers to expose our services to outer-world using LoadBalancers being backed up by Ingress.

1. Ingress

   An API object that manages external access to the services in a cluster, typically HTTP.

   Ingress may provide load balancing, SSL termination and name-based virtual hosting.

   Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

   An Ingress may be configured to give Services externally-reachable URLs, load balance traffic, terminate SSL / TLS, and offer name-based virtual hosting. An Ingress controller is responsible for fulfilling the Ingress, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

   An Ingress does not expose arbitrary ports or protocols. Exposing services other than HTTP and HTTPS to the internet typically uses a service of type Service.Type=NodePort or Service.Type=LoadBalancer.

Thereby, I have made use of Host-Based Routing Mechanism for Ingress where precise matches require that the HTTP host header matches the host field. Wildcard matches require the HTTP host header is equal to the suffix of the wildcard rule.

2. EFS

   Also in this project i have made use of EFS (AWS FileSystem) to store filesystem data as a replica for the default volume (network file system ) provided by Kubernetes. The use of volumes is because of persistency as in kubernetes if any application is deployed with no persistent setup, the data produced or consumed by the application becomes ephermal and if the container crashes the kubelet will restart the container to maintain the desired state but this time the container will be launched with a clean state.

Now, to use EFS as the persistent volume for applications deployed in Kubernetes I have made use of the EFS CSI Drivers (Container Storage Interface).

3.  HPA

    I have also included HPA(Horizational Pod Autoscaler) in my project as we are not certain about our pods resource requirements and how those requirements might change depending on usage patterns, external dependencies, or other factors. HPA can automatically scale the number of Pods in your workload based on one or more metrics of the following types:-

              Actual resource usage: when a given Pod's CPU or memory usage exceeds a threshold. This can be expressed as a raw value or as a percentage of the amount the Pod requests for that resource.

              Custom metrics: based on any metric reported by a Kubernetes object in a cluster, such as the rate of client requests per second or I/O writes per second.

              This can be useful if your application is prone to network bottlenecks, rather than CPU or memory.

             External metrics: based on a metric from an application or service external to your cluster.

    For example, your workload might need more CPU when ingesting a large number of requests from a pipeline such as Pub/Sub. You can create an external metric for the size of the queue, and configure HPA to automatically increase the number of Pods when the queue size reaches a given threshold, and to reduce the number of Pods when the queue size shrinks.

    Each configured Horizontal Pod Autoscaler object operates using a control loop. A separate HPA object exists for each workflow. Each HPA object periodically checks a given workload's metrics against the target thresholds you configure, and changes the shape of the workload automatically.

The official Documentation on this is provided by AWS.

https://docs.aws.amazon.com/eks/latest/userguide/efs-csi.html

![alt-text](https://github.com/Abhishek010397/Kubernetes-route/blob/master/Route.png)
