# Devsu Demo DevOps

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

# 🚀 Arquitectura General del Proyecto

```mermaid
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
🧱 Infraestructura creada con Terraform
css
Copiar código
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
└── credentials.json
Terraform despliega:

☸️ Cluster GKE: devsu-demo-cluster

🧩 Node Pool: 1 nodo e2-medium

🌐 Networking + asignación de IPs

🔐 kubeconfig para acceso al cluster

🐳 Flujo de Contenedores (Docker → GCR → GKE)
mermaid
Copiar código
flowchart TD
    A[Máquina local] -->|docker build| B[gcr.io/.../demo-api:v1]
    B -->|docker push| C[Google Container Registry]

    C -->|pull| D[Nodos del cluster GKE]
    D --> E[Pod ejecutando la API Django]
🔐 Flujo HTTPS con Cert-Manager + Let's Encrypt
mermaid
Copiar código
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
🔄 Pipeline de Integración Continua (GitHub Actions)
mermaid
Copiar código
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
🛠️ Tecnologías Principales
Python 3.11 / Django Rest Framework

Docker

Terraform

Google Kubernetes Engine (GKE)

Kubernetes (Deployments, Services, Ingress)

NGINX Ingress Controller

Cert-Manager + Let's Encrypt

GitHub Actions

🔐 Crear Service Account para Terraform (Google Cloud)
1️⃣ Crear Service Account
URL:
https://console.cloud.google.com/iam-admin/serviceaccounts

makefile
Copiar código
Nombre: terraform-admin
ID: terraform-admin
Descripción: Cuenta para automatización con Terraform
2️⃣ Asignar permisos
Roles necesarios:

bash
Copiar código
roles/container.admin
roles/compute.admin
roles/storage.admin
roles/iam.serviceAccountUser
3️⃣ Crear una llave JSON
Guardar el archivo como:

bash
Copiar código
terraform/credentials.json
4️⃣ Exportar variable de entorno
bash
Copiar código
$env:GOOGLE_APPLICATION_CREDENTIALS="terraform/credentials.json"
5️⃣ Autenticación
bash
Copiar código
gcloud auth activate-service-account --key-file terraform/credentials.json
gcloud projects list
📦 Replicar el Proyecto Desde GitHub
1️⃣ Clonar repositorio
bash
Copiar código
git clone https://github.com/Silverhand16/devsu-demo_devops-python.git
cd devsu-demo-devops-python
☁️ Crear Infraestructura (Terraform)
bash
Copiar código
cd terraform
terraform init
terraform apply
Obtener credenciales del cluster:

bash
Copiar código
gcloud container clusters get-credentials devsu-demo-cluster --region us-central1 --project <project_id>
☸️ Configuración de Kubernetes
Instalar NGINX Ingress Controller
bash
Copiar código
kubectl get pods -n ingress-nginx
Instalar Cert-Manager
bash
Copiar código
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.15.0/cert-manager.yaml
kubectl get pods -n cert-manager
Crear issuer y configuraciones
bash
Copiar código
kubectl apply -f k8s/cluster-issuer-prod.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
🐳 Construcción y subida de imagen Docker
bash
Copiar código
docker build -t gcr.io/<project_id>/demo-api:v1 .
gcloud auth configure-docker
docker push gcr.io/<project_id>/demo-api:v1
🚀 Despliegue en Kubernetes (GKE)
bash
Copiar código
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
Verificar:

bash
Copiar código
kubectl get pods
kubectl get svc
kubectl get ingress
🔐 Verificación de HTTPS
bash
Copiar código
kubectl describe certificate
kubectl get challenges -A
Abrir en navegador:

👉 https://prueba-devops.duckdns.org

📁 Estructura del Proyecto
pgsql
Copiar código
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
🖥️ Despliegue en Docker Desktop + Kubernetes Local
1️⃣ Activar Kubernetes en Docker Desktop
Settings → Kubernetes →
Enable Kubernetes

bash
Copiar código
kubectl get nodes
Debe mostrar:

Copiar código
docker-desktop   Ready
2️⃣ Clonar proyecto
bash
Copiar código
git clone https://github.com/Silverhand16/devsu-demo_devops-python.git
cd devsu-demo-devops-python
3️⃣ Construir imagen Docker local
bash
Copiar código
docker build -t demo-api:local .
docker images
4️⃣ Crear ConfigMap y Secret
bash
Copiar código
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
5️⃣ Editar Deployment para usar la imagen local
En k8s/deployment.yaml:

yaml
Copiar código
image: demo-api:local
imagePullPolicy: Never
6️⃣ Aplicar recursos
bash
Copiar código
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
7️⃣ Exponer API local
bash
Copiar código
kubectl port-forward svc/devsu-demo-service 8000:8000
Abrir en:
http://localhost:8000

