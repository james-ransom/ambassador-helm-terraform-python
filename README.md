# DEMO: Ambassador + Terraform + GCP + NGINX + helm  🚀

We are going to use Ambassador to route to different backends based on path.  
```
/search/ -> will go to backend-k8s-v2 service
/groupings/ -> will go to backend-k8s service
```

Let's roll! 
## Setup service account keys 

Place a GCP service account key file in the base directory. More info: https://stackoverflow.com/questions/46287267/how-can-i-get-the-file-service-account-json-for-google-translate-api 
The key file will look like this: 

```
cat secret.json 
{
  "type": "service_account",
  "project_id": "PROJECT",
  .... 
}
```

## Setup the project in vars.tf

```
variable "project" {
 type = string
 default = "[YOUR_PROJECTNAME_HERE]"
}

```


## Setup terraform 

```
cd ambassador-helm-terraform/terraform;
terraform apply 
```

## Setup k8s 

```
cd ambassador-helm-terraform/app;
sh build.sh

```

## View mappings 
```
kubectl get mappings

NAME                SOURCE HOST   SOURCE PREFIX   DEST SERVICE        STATE   REASON
mapping-groupings                 /groupings/     backend-k8s:80              
mapping-search                    /search/        backend-k8s-v2:80  
```

## View load balancer for ambassador 

```
kubectl get services --all-namepaces

NAMESPACE         NAME                   TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
ambassador        ambassador             LoadBalancer   10.55.248.153   10.128.0.43     80:32610/TCP                 75m
ambassador        edge-stack             LoadBalancer   10.55.251.209   34.67.121.152 << this thing!!  80:30410/TCP,443:30398/TCP   71m
default           backend-k8s            LoadBalancer   10.55.249.109   34.173.19.132   80:31578/TCP                 89m
default           backend-k8s-v2         LoadBalancer   10.55.241.123   35.202.99.12    80:31841/TCP                 89m
... 
```


# Let's test it out! 

The goal is we want one ip address that will hit different backends based on PATH.   In this demo we have two paths 
```
/search/ -> will go to backend-k8s-v2 service
/groupings/ -> will go to backend-k8s service
```

## Let's open the logs for EACH backend services (there are 2)

Let's try /search which is v2. 

```
curl http://34.67.121.152/search/?THIS_SHOULD_HIT_BACKEND_SERVICE-V2
```
Ok let's check this logs for service 2

```
kubectl logs -f backend-k8s-v2-6878c89f9b-28fm9 

[pid: 8|app: 0|req: 3021/3021] 10.52.3.9 () {44 vars in 686 bytes} [Sat Aug 19 22:08:08 2023] GET /search/?THIS_SHOULD_HIT_BACKEND_SERVICE-V2 => generated 106 bytes in 0 msecs (HTTP/1.1 200) 2 headers in 80 bytes (1 switches on core 0)
[pid: 8|app: 0|req: 3022/3022] 10.52.3.9 () {44 vars in 686 bytes} [Sat Aug 19 22:08:08 2023] GET /search/?THIS_SHOULD_HIT_BACKEND_SERVICE-V2 => generated 106 bytes in 0 msecs (HTTP/1.1 200) 2 headers in 80 bytes (1 switches on core 0)
[pid: 8|app: 0|req: 3023/3023] 10.52.2.13 () {44 vars in 689 bytes} [Sat Aug 19 22:08:08 2023] GET /search/?THIS_SHOULD_HIT_BACKEND_SERVICE-V2 => generated 106 bytes in 0 msecs (HTTP/1.1 200) 2 headers in 80 bytes (1 switches on core 0)
```

Let's try /groupings which is v1. 

```
curl http://34.67.121.152/groupings/?SERVICE-V1-SWEET
```
Ok let's check this logs for service 1

```
kubectl logs -f backend-k8s-7b8c7fdf47-5jg85  

secs (HTTP/1.1 200) 2 headers in 79 bytes (1 switches on core 0)
[pid: 7|app: 0|req: 999/999] 10.52.2.13 () {44 vars in 642 bytes} [Sat Aug 19 22:10:32 2023] GET /groupings/?SERVICE-V1-SWEET => generated 91 bytes in 0 msecs (HTTP/1.1 200) 2 headers in 79 bytes (1 switches on core 0)
[pid: 7|app: 0|req: 1000/1000] 10.52.3.9 () {44 vars in 643 bytes} [Sat Aug 19 22:10:32 2023] GET /groupings/?SERVICE-V1-SWEET => generated 91 bytes in 0 msecs (HTTP/1.1 200) 2 headers in 79 bytes (1 switches on core 0)
[pid: 7|app: 0|req: 1001/1001] 10.52.1.11 () {44 vars in 644 bytes} [Sat Aug 19 22:10:32 2023] GET /groupings/?SERVICE-V1-SWEET => generated 91 bytes in 0 msecs (HTTP/1.1 200) 2 headers in 79 bytes (1 switches on core 0)
```



# 💸 SWEET we now have a path based load balancer using Ambassador on GCP 💸💸💸



