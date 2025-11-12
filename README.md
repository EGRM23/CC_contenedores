# 🚀 Despliegue EKS con Ansible - CC Contenedores

[![AWS EKS](https://img.shields.io/badge/AWS-EKS-orange?logo=amazon-aws)](https://aws.amazon.com/eks/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28-blue?logo=kubernetes)](https://kubernetes.io/)
[![Ansible](https://img.shields.io/badge/Ansible-2.9+-red?logo=ansible)](https://www.ansible.com/)

Proyecto de infraestructura como código para desplegar aplicaciones containerizadas en **Amazon EKS** usando **Ansible** como herramienta de automatización.

## 📋 Prerrequisitos

### 🔧 Herramientas Requeridas
```bash
# Verificar instalaciones
ansible --version        # 2.9+
aws --version           # AWS CLI v2
kubectl version --client # 1.28+
helm version            # 3.0+

# Configurar credenciales AWS
aws configure

# Verificar identidad
aws sts get-caller-identity

# Configurar región por defecto
aws configure set region us-east-1