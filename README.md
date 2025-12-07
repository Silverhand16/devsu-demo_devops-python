# Devsu Demo DevOps

Este repositorio contiene una API **Django** desplegada automáticamente utilizando:

- **Terraform** (infraestructura como código)
- **Google Kubernetes Engine (GKE)**
- **Docker**
- **NGINX Ingress Controller**
- **Cert-Manager + Let's Encrypt**
- **DuckDNS** como DNS dinámico
- **GitHub Actions (CI/CD)**

---

# Arquitectura General del Proyecto

```text
+-------------------------+
|    GitHub Repository    |
+-----------+-------------+
            |
            v CI/CD
+-------------------------+       +------------------------------+
|    GitHub Actions (CI)  |       |    Terraform on local host   |
|  - Lint Python          |       |  - Creates GKE cluster       |
|  - Validate K8s         |       |  - Creates Node Pool         |
|  - Validate Terraform   |       |  - Outputs kubeconfig        |
+-----------+-------------+       +------------------------------+
            |
            v
+-----------------------------+
|     Google Cloud Platform   |
|  +------------------------+ |
|  |      GKE Cluster       | |
|  |  - Deployment          | |
|  |  - Service             | |
|  |  - Ingress (Nginx)     | |
|  |  - Cert-Manager        | |
|  +------------------------+ |
+-----------------------------+
            |
            v
+--------------------------------+
|        HTTPS Public API        |
| https://prueba-devops.duckdns.org |
+--------------------------------+
```

Infraestructura creada con Terraform
```text
Infraestructura creada por Terraform

+-----------------------------------------------------+
|                     Terraform                       |
|        main.tf, variables.tf, outputs.tf            |
+--------------------------+--------------------------+
                           |
                           | creates
                           v
+-----------------------------------------------------+
|                     Google Cloud                    |
|  • GKE Cluster (devsu-demo-cluster)                 |
|  • Node Pool (1 e2-medium node)                     |
|  • Networking + IP Allocation                       |
+-----------------------------------------------------+
```

Diagrama de Contenedores (Docker → GCR → GKE)
```text
+-----------------------------------------------------+
|                   Docker build .                    |
|                   Image tagged:                     |
|                 gcr.io/.../demo-api:v1              |
+--------------------------+--------------------------+
                           |
                           | push
                           v
                 Google Container Registry (GCR)

+-----------------------------------------------------+
|               Stores production images              |
+--------------------------+--------------------------+
                           |
                           | pull
                           v
                       GKE Nodes

+-----------------------------------------------------+
|      Container Runtime loads image                  |
|      Pod runs Django API                            |
+-----------------------------------------------------+
```

Diagrama Cert-Manager + Let's Encrypt
```text
User visits: https://prueba-devops.duckdns.org
                   |
                   v
            NGINX Ingress (K8s)
                   |
                   v
          Cert-Manager Webhook
                   |
                   v
        Let's Encrypt ACME Server
                   |
        Issues TLS Certificates
                   |
                   v
   Certificate stored as Secret in Kubernetes
```

Diagrama del Pipeline CI
```text
          Developer Push / PR
                   |
                   v
        GitHub Actions Workflow

+--------------------------------------------------+
|  1. Checkout repo                                |
|  2. Install Python                               |
|  3. Install requirements                          |
|  4. Lint Python                                   |
|  5. Terraform init (safe mode)                    |
|  6. Terraform validate                            |
|  7. Install kubeconform                           |
|  8. Validate Kubernetes manifests                 |
+--------------------------------------------------+

                   |
                   v
              Status Badge
      (CI Passed / Failed in GitHub)
```

**Tecnologías Principales**
- Python 3.11 / Django Rest Framework
- Docker
- Terraform
- Google Kubernetes Engine (GKE)
- Kubernetes (Deployments, Services, Ingress)
- NGINX Ingress Controller
- Cert-Manager + Let's Encrypt
- GitHub Actions
---

## Pasos para crear Service Account para Terraform (Google Cloud)
1) Crear Service Account
URL: https://console.cloud.google.com/iam-admin/serviceaccounts
```bash
Nombre: terraform-admin
ID: terraform-admin
Descripción: Cuenta para automatización con Terraform
```
2) Asignar permisos
Roles necesarios:
roles/container.admin
roles/compute.admin
roles/storage.admin
roles/iam.serviceAccountUser

3) Crear una llave JSON
Guardar el archivo como:
```bash
terraform/credentials.json
```
4) Exportar variable de entorno
```bash
$env:GOOGLE_APPLICATION_CREDENTIALS="terraform/credentials.json"
```
5) Autenticación
```bash
gcloud auth activate-service-account --key-file terraform/credentials.json
gcloud projects list
```
# Pasos para replicar el proyecto usando el repositorio de Github
1) Clonar repositorio
```bash
git clone https://github.com/Silverhand16/devsu-demo_devops-python.git
cd devsu-demo-devops-python
```
2) Crear Infraestructura (Terraform)
```bash
cd terraform
terraform init
terraform apply
```
3) Obtener credenciales del cluster:
```bash
gcloud container clusters get-credentials devsu-demo-cluster --region us-central1 --project <project_id>
```
4) Configuración de Kubernetes
Instalar NGINX Ingress Controller
```bash
kubectl get pods -n ingress-nginx
```
5) Instalar Cert-Manager
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.yaml
kubectl get pods -n cert-manager
```
6) Crear issuer y configuraciones
```bash
kubectl apply -f k8s/cluster-issuer-prod.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
```
7) Construcción y subida de imagen Docker
```bash
docker build -t gcr.io/<project_id>/demo-api:v1 .
gcloud auth configure-docker
docker push gcr.io/<project_id>/demo-api:v1
```
8) Despliegue en Kubernetes (GKE)
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
```
Verificar:
```bash
kubectl get pods
kubectl get svc
kubectl get ingress
```
9) Verificación de HTTPS
```bash
kubectl describe certificate
kubectl get challenges -A
```
10) Abrir en navegador:
```bash
https://prueba-devops.duckdns.org
```

## Estructura del Proyecto
```bash
devsu-demo-devops-python/
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
```
---
## Despliegue en Docker Desktop + Kubernetes Local
1️) Activar Kubernetes en Docker Desktop
Settings → Kubernetes → Enable Kubernetes
```bash
kubectl get nodes
```
Debe mostrar:
```bash
docker-desktop   Ready
```
2️) Clonar proyecto
```bash
git clone https://github.com/Silverhand16/devsu-demo_devops-python.git
cd devsu-demo-devops-python
```
3️) Construir imagen Docker local
```bash
docker build -t demo-api:local .
docker images
```
4️) Crear ConfigMap y Secret
```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
```
5️) Editar Deployment para usar la imagen local
En k8s/deployment.yaml:
```bash
image: demo-api:local
imagePullPolicy: Never
```
6️) Aplicar recursos
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
7️) Exponer API local
```bash
kubectl port-forward svc/devsu-demo-service 8000:8000
```
Abrir en:
```bash
http://localhost:8000
```
