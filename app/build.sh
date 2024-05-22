if [ -z "$2" ]
then
    echo "sh build.sh [json_key_file] [project]"
    exit 0;
fi

if [ ! -f $1 ]; then
    echo "Service account json file not found"
    exit 0; 
fi

# Log INTO GCP 
docker login -u _json_key -p "$(cat $1)" https://us-central1-docker.pkg.dev 
gcloud auth configure-docker
docker buildx build --platform=linux/amd64  --tag us-central1-docker.pkg.dev/$2/backend/ambassador-helm-tf:1.0 .


docker tag us-central1-docker.pkg.dev/$2/backend/ambassador-helm-tf:1.0 us-central1-docker.pkg.dev/$2/backend/ambassador-helm-tf:latest
docker push us-central1-docker.pkg.dev/$2/backend/ambassador-helm-tf:1.0
docker push us-central1-docker.pkg.dev/$2/backend/ambassador-helm-tf:latest

#sed -i '' 's/VERSION/VER-1/g' main.py 

kubectl apply -f deployment.yaml 
kubectl apply -f deployment-v2.yaml
kubectl apply -f service.yaml 

# Check if the namespace exists
namespace="ambassador"
#if kubectl get namespace "$namespace" &> /dev/null; then
#   echo "Namespace '$namespace' already exists, skipping helm install."
#else
   # INSTALL HELM AND AMBASSADOR 
   helm repo add datawire https://app.getambassador.io
   helm repo update
   kubectl create namespace ambassador && \
   kubectl apply -f https://app.getambassador.io/yaml/edge-stack/3.7.2/aes-crds.yaml
   kubectl wait --timeout=90s --for=condition=available deployment emissary-apiext -n emissary-system
   helm install edge-stack --namespace ambassador datawire/edge-stack && \
   kubectl -n ambassador wait --for condition=available --timeout=90s deploy -lproduct=aes
#fi 

kubectl apply -f ambassador-lb.yaml
kubectl apply -f listen3.yaml 
kubectl apply -f host.yaml
kubectl apply -f mapping-search.yaml
kubectl apply -f mapping-groupings.yaml
