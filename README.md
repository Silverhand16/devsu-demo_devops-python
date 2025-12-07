# Devsu Demo DevOps

Este repositorio contiene una API **Django** desplegada automáticamente usando:

- **Terraform** (infraestructura)
- **Google Kubernetes Engine (GKE)**
- **Docker**
- **NGINX Ingress Controller**
- **Cert-Manager + Let's Encrypt**
- **DuckDNS** como DNS dinámico
- **GitHub Actions (CI)**

---

# 🚀 Arquitectura General

flowchart TD
    A[GitHub Repository] --> B[GitHub Actions CI/CD]
    B -->|Lint + Validate + Terraform| C[Google Cloud Platform]
    C --> D[GKE Cluster]
    D --> E[Deployment]
    E --> F[Service]
    F --> G[NGINX Ingress]
    G --> H[Cert-Manager]
    H --> I[Let's Encrypt ACME Server]
    I --> J[TLS Secret in Kubernetes]
    G --> K[HTTPS Public API<br>https://prueba-devops.duckdns.org]


Diagrama de Contenedores (Docker → GCR → GKE)
Local Dev Machine
┌────────────────────────┐
│  Docker build .        │
│  Image tagged:         │
│  gcr.io/.../demo-api:v1│
└──────────────┬─────────┘
               │ push
               ▼
 Google Container Registry (GCR)
┌──────────────────────────────┐
│ Stores production images     │
└──────────────┬───────────────┘
               │ pull
               ▼
GKE Nodes
┌──────────────────────────────┐
│ Container Runtime loads image│
│ Pod runs Django API          │
└──────────────────────────────┘

Diagrama Cert-Manager + Let's Encrypt
User visits: https://prueba-devops.duckdns.org
                  │
                  ▼
         NGINX Ingress (K8s)
                  │
                  ▼
         Cert-Manager Webhook
                  │
                  ▼
         Let's Encrypt ACME Server
                  │
        Issues TLS Certificates
                  ▼
   Certificate stored as Secret in Kubernetes

Diagrama del Pipeline CI

           Developer Push / PR
                     │
                     ▼
         GitHub Actions Workflow
 ┌──────────────────────────────────────┐
 │ 1. Checkout repo                     │
 │ 2. Install Python                    │
 │ 3. Install requirements              │
 │ 4. Lint Python                       │
 │ 5. Terraform init (safe mode)        │
 │ 6. Terraform validate                 │
 │ 7. Install kubeconform               │
 │ 8. Validate Kubernetes manifests      │
 └──────────────────────────────────────┘
                     │
                     ▼
                Status Badge
          (CI Passed / Failed in GitHub)


Tecnologías usadas

Python 3.11 / Django Rest Framework
Docker
Terraform
Google Kubernetes Engine (GKE)
Kubernetes (Deployments, Services, Ingress)
Nginx Ingress Controller
Cert-Manager + Let's Encrypt
GitHub Actions

Crear Service Account en Google Cloud

Pasos en google cloud

Paso 1
Google Cloud Console → https://console.cloud.google.com/iam-admin/serviceaccounts

Crear:
Name: terraform-admin
ID: terraform-admin
Description: Terraform automation service account

paso 2
Asignar permisos
Service Account → Permissions → Grant Access

Roles obligatorios:
roles/container.admin
roles/compute.admin
roles/storage.admin
roles/iam.serviceAccountUser

Paso 3
Crear llave JSON
Service Account → Keys → Add Key → JSON
Guardar archivo descargado en:
terraform/credentials.json

Paso 4
Exportar variable de entorno

$env:GOOGLE_APPLICATION_CREDENTIALS="terraform/credentials.json"

Paso 5
Autenticación
gcloud auth activate-service-account --key-file terraform/credentials.json
Verificar:
gcloud projects list

Pasos para replicar el proyecto usando el repositorio de Github

Paso 1 
clonar el repositorio
git clone https://github.com/Silverhand16/devsu-demo_devops-python.git
cd devsu-demo-devops-python

Paso 2 
Infraestructura con Terraform

cd terraform
terraform init

Aplicar infraestructura
terraform apply

Obtener credenciales del cluster
gcloud container clusters get-credentials devsu-demo-cluster --region us-central1 --project <tu_project_id>

Paso 3
Crear recursos de Kubernetes

Instalar Nginx Ingress Controller
Verificar:
kubectl get pods -n ingress-nginx

Instalar Cert-Manager (para HTTPS)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.yaml

Verificar:
kubectl get pods -n cert-manager

Crear ClusterIssuer (Let's Encrypt)
kubectl apply -f k8s/cluster-issuer-prod.yaml

Crear ConfigMap y Secret
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml

Paso 4
Construir y publicar la imagen Docker

Costruccion de la imagen
docker build -t gcr.io/<project_id>/demo-api:v1 .

Autenticarse en GCR
gcloud auth configure-docker

Push
docker push gcr.io/<project_id>/demo-api:v1

Paso 5
Desplegar la aplicación en Kubernetes

Aplicar:
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml

Verificar:
kubectl get pods
kubectl get svc
kubectl get ingress

Paso 6 
Verificar HTTPS y Certificados
kubectl describe certificate
kubectl get challenges -A
Esperar que el certificado quede Ready.

Luego abrir:
https://prueba-devops.duckdns.org o URL dada por el DNS

Estructura del proyecto
devsu-demo-devops-python/
│
├── api/                
├── demo/              
├── k8s/              
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── cluster-issuer-prod.yaml
│   ├── configmap.yaml
│   └── secret.yaml
│
├── terraform/         
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── credentials.json 
│
├── Dockerfile
├── requirements.txt
├── README.md
└── .github/workflows/deploy.yml


Despliegue con Docker desktop y kubernetes local
Paso 1 

Abrir Docker Desktop
Ir a Settings → Kubernetes
Activar Enable Kubernetes
Aplicar los cambios y esperar a que termine de instalar.

Verificar:
kubectl get nodes

Debe mostrar:
docker-desktop   Ready

Paso 2
clonar el repositorio
git clone https://github.com/Silverhand16/devsu-demo_devops-python.git
cd devsu-demo-devops-python

Paso 3
Construir la imagen Docker local
docker build -t demo-api:local .
Confirmar:
docker images

Paso 4
Crear ConfigMap y Secret (local)
ConfigMap:
kubectl apply -f k8s/configmap.yaml

Secret:
kubectl apply -f k8s/secret.yaml

Paso 5
 Editar el deployment para que use la imagen local
k8s/deployment.yaml

Y cambiar:
image: demo-api:local
imagePullPolicy: Never

Paso 6
Aplicar los recursos Kubernetes
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

Verificar:
kubectl get pods
kubectl get svc

El servicio debe verse así:
devsu-demo-service   ClusterIP   10.x.x.x   <none>    8000/TCP

Paso 7
Exponer la app en tu máquina local
kubectl port-forward svc/devsu-demo-service 8000:8000

