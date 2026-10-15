#!/usr/bin/env bash
set -Eeuo pipefail

cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo "Usage : ./deploy.sh environments/dev.tfvars"
    exit 1
fi

VARS_FILE="$1"

if [ ! -f "$VARS_FILE" ]; then
    echo "ERREUR : fichier de variables introuvable : $VARS_FILE"
    exit 1
fi

case "$VARS_FILE" in
    environments/dev.tfvars)
        ENVIRONMENT="dev"
        ;;
    environments/test.tfvars)
        ENVIRONMENT="test"
        ;;
    *)
        echo "ERREUR : utilisez environments/dev.tfvars ou environments/test.tfvars"
        exit 1
        ;;
esac

echo "========== ENVIRONNEMENT : $ENVIRONMENT =========="

echo "========== 1. INITIALISATION TERRAFORM =========="
terraform init -input=false

echo "========== 2. VALIDATION TERRAFORM =========="
terraform fmt -check
terraform validate

echo "========== 3. SELECTION DU WORKSPACE =========="
terraform workspace select "$ENVIRONMENT"

echo "========== 4. PROVISIONNEMENT =========="
terraform apply -input=false -auto-approve -var-file="$VARS_FILE"

INVENTORY_FILE="$(terraform output -raw inventory_file)"
HTTP_URL="$(terraform output -raw http_url)"

echo "========== 5. ATTENTE DE SSH =========="

SSH_READY=false

for i in {1..20}; do
    if ansible smartcity -i "$INVENTORY_FILE" -m ping >/dev/null 2>&1; then
        SSH_READY=true
        echo "Hote Ansible accessible."
        break
    fi

    echo "Attente de l'hote... tentative $i/20"
    sleep 2
done

if [ "$SSH_READY" != "true" ]; then
    echo "ERREUR : l'hote Ansible ne repond pas."
    exit 1
fi

echo "========== 6. CONFIGURATION ANSIBLE =========="
ansible-playbook -i "$INVENTORY_FILE" playbook.yml

echo "========== 7. TEST HTTP =========="
curl --fail --silent --show-error --max-time 10 "$HTTP_URL"

echo
echo "========== DEPLOIEMENT TERMINE =========="
echo "Environnement : $ENVIRONMENT"
echo "Adresse HTTP : $HTTP_URL"
