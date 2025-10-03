#!/bin/bash

echo "Desplegando Secrets..."
kubectl apply -f k8s/secret.yaml

echo "Desplegando volúmenes persistentes..."
kubectl apply -f k8s/db-pvc.yaml

echo "Desplegando servicio de base de datos..."
kubectl apply -f k8s/db-deployment.yaml
kubectl apply -f k8s/db-service.yaml

echo "Desplegando servicio de backend..."
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml

echo "Desplegando servicio de frontend..."
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

echo "=== INSTALANDO INGRESS CONTROLLER ==="
echo "Instalando NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

echo "Esperando a que el Ingress Controller esté listo..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=300s

echo "Verificando estado del Ingress Controller..."
kubectl get pods -n ingress-nginx

echo "Obteniendo IP del Ingress..."
kubectl get svc -n ingress-nginx ingress-nginx-controller

echo "=== CONFIGURANDO INGRESS ==="
echo "Desplegando reglas de Ingress..."
kubectl apply -f k8s/ingress.yaml

echo "Esperando a que el Ingress esté listo..."
sleep 10

echo "=== CONFIGURACIÓN DE ACCESO ==="
echo "Obteniendo IP para acceso..."
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$INGRESS_IP" ]; then
  echo "No se pudo obtener LoadBalancer IP, usando NodePort..."
  INGRESS_PORT=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.spec.ports[0].nodePort}')
  echo "Accede a tu aplicación en: http://localhost:$INGRESS_PORT"
else
  echo "Configurando /etc/hosts..."
  if ! grep -q "miapp.local" /etc/hosts; then
    echo "$INGRESS_IP miapp.local" | sudo tee -a /etc/hosts
    echo "Entrada añadida: $INGRESS_IP miapp.local"
  else
    sudo sed -i "s/.*miapp.local/$INGRESS_IP miapp.local/" /etc/hosts
    echo "Entrada actualizada: $INGRESS_IP miapp.local"
  fi
  echo "Accede a tu aplicación en: http://miapp.local"
fi

echo "=== VERIFICACIÓN FINAL ==="
echo "¡Despliegue completado!"
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A

echo "=== URLs DE ACCESO ==="
echo "Frontend: http://miapp.local"
echo "Backend API: http://miapp.local/api"
echo "Para ver logs: kubectl logs -f deployment/frontend"
