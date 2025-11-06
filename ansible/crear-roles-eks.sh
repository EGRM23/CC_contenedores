#!/bin/bash

# Script para crear roles de IAM para EKS
echo "=== Creando roles IAM para EKS ==="

# Configuración
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"

echo "Cuenta AWS: $ACCOUNT_ID"
echo "Región: $REGION"
echo ""

# Función para verificar si un rol existe
check_role_exists() {
    aws iam get-role --role-name $1 > /dev/null 2>&1
    return $?
}

# 1. Crear rol para EKS Cluster
echo "1. Creando rol para EKS Cluster..."
if check_role_exists "eks-cluster-role"; then
    echo "   ⚠️  El rol 'eks-cluster-role' ya existe"
else
    cat > /tmp/eks-cluster-role-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    aws iam create-role \
        --role-name eks-cluster-role \
        --assume-role-policy-document file:///tmp/eks-cluster-role-trust-policy.json

    aws iam attach-role-policy \
        --role-name eks-cluster-role \
        --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy

    echo "   ✅ Rol 'eks-cluster-role' creado exitosamente"
fi

# 2. Crear rol para EKS NodeGroup
echo ""
echo "2. Creando rol para EKS NodeGroup..."
if check_role_exists "eks-nodegroup-role"; then
    echo "   ⚠️  El rol 'eks-nodegroup-role' ya existe"
else
    cat > /tmp/eks-nodegroup-role-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    aws iam create-role \
        --role-name eks-nodegroup-role \
        --assume-role-policy-document file:///tmp/eks-nodegroup-role-trust-policy.json

    # Adjuntar políticas necesarias para NodeGroup
    aws iam attach-role-policy \
        --role-name eks-nodegroup-role \
        --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy

    aws iam attach-role-policy \
        --role-name eks-nodegroup-role \
        --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

    aws iam attach-role-policy \
        --role-name eks-nodegroup-role \
        --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly

    echo "   ✅ Rol 'eks-nodegroup-role' creado exitosamente"
fi

# 3. Verificar y mostrar resultados
echo ""
echo "3. Verificando creación de roles..."
echo ""

# Obtener ARNs
CLUSTER_ROLE_ARN=$(aws iam get-role --role-name eks-cluster-role --query 'Role.Arn' --output text 2>/dev/null || echo "NO_EXISTE")
NODEGROUP_ROLE_ARN=$(aws iam get-role --role-name eks-nodegroup-role --query 'Role.Arn' --output text 2>/dev/null || echo "NO_EXISTE")

echo "=== RESUMEN ==="
echo "Cluster Role ARN: $CLUSTER_ROLE_ARN"
echo "NodeGroup Role ARN: $NODEGROUP_ROLE_ARN"
echo ""

# Verificar políticas adjuntas
echo "Políticas adjuntas a eks-cluster-role:"
aws iam list-attached-role-policies --role-name eks-cluster-role --query 'AttachedPolicies[].PolicyName' --output table

echo ""
echo "Políticas adjuntas a eks-nodegroup-role:"
aws iam list-attached-role-policies --role-name eks-nodegroup-role --query 'AttachedPolicies[].PolicyName' --output table

echo ""
echo "=== CONFIGURACIÓN PARA TU ARCHIVO ==="
echo "Copia esto a tu configuración:"
echo "eks_cluster_role_arn: \"$CLUSTER_ROLE_ARN\""
echo "eks_nodegroup_role_arn: \"$NODEGROUP_ROLE_ARN\""

# Limpiar archivos temporales
rm -f /tmp/eks-*-trust-policy.json

echo ""
echo "✅ Proceso completado"