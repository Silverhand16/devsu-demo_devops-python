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


flowchart TD
    A[Repositorio GitHub] --> B[GitHub Actions - CI/CD]
    B -->|Lint + Validaciones + Terraform| C[Google Cloud Platform]

    C --> D[GKE Cluster]
    D --> E[Deployment]
    E --> F[Service]
    F --> G[NGINX Ingress]

    G --> H[Cert-Manager]
    H --> I[Let's Encrypt - Servidor ACME]

    I --> J[Certificado TLS almacenado en Kubernetes]
    G --> K[API Pública HTTPS<br>https://prueba-devops.duckdns.org]
Infraestructura creada con Terraform
css
Copiar código
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
└── credentials.json
Terraform despliega:

Cluster GKE: devsu-demo-cluster
Node Pool: 1 nodo e2-medium
Networking + asignación de IPs
kubeconfig para acceso al cluster

Flujo de Contenedores (Docker → GCR → GKE)

flowchart TD
    A[Máquina local] -->|docker build| B[gcr.io/.../demo-api:v1]
    B -->|docker push| C[Google Container Registry]
    C -->|pull| D[Nodos del cluster GKE]
    D --> E[Pod ejecutando la API Django]
    
Flujo HTTPS con Cert-Manager + Let's Encrypt
sequenceDiagram
    participant U as Usuario
    participant I as NGINX Ingress
    participant C as Cert-Manager
    participant L as Let's Encrypt
    
    U->>I: Solicitud HTTPS
    I->>C: Solicitud de certificado
    C->>L: Desafío ACME HTTP-01
    L->>C: Validación exitosa
    C->>I: Certificado TLS emitido y guardado
    I->>U: Respuesta HTTPS segura
    
Pipeline de Integración Continua (GitHub Actions)
flowchart TD
    A[Push o Pull Request] --> B[GitHub Actions]
    B --> C[1. Checkout del repositorio]
    C --> D[2. Instalación de Python]
    D --> E[3. Instalación de dependencias]
    E --> F[4. Linter de Python]
    F --> G[5. Terraform Init]
    G --> H[6. Terraform Validate]
    H --> I[7. Instalar Kubeconform]
    I --> J[8. Validación de manifiestos Kubernetes]
    J --> K[Resultado del CI]
    
Tecnologías Principales
Python 3.11 / Django Rest Framework
Docker
Terraform
Google Kubernetes Engine (GKE)
Kubernetes (Deployments, Services, Ingress)
NGINX Ingress Controller
Cert-Manager + Let's Encrypt
GitHub Actions

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
