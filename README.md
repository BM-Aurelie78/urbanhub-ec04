# UrbanHub — EC04 Partie 1

## 1. Présentation du projet

UrbanHub est un projet de déploiement automatisé d'un service web Smart City.

Ce projet réutilise et adapte un TP Terraform/Ansible existant.
L'infrastructure est provisionnée avec Terraform et le serveur web
est configuré avec Ansible.

## 2. Architecture et choix techniques

- Plateforme : VPS Linux avec Docker rootless.
- Terraform : création de l'image Docker, du conteneur et de l'inventaire Ansible.
- Ansible : installation, démarrage et activation de Nginx.
- Jinja2 : génération d'une page HTML personnalisée.
- Bash : orchestration du déploiement et des tests.
- Workspaces Terraform : isolation des environnements DEV et TEST.

La solution utilise des conteneurs Docker sur un VPS existant,
et non des machines virtuelles cloud distinctes.

## 3. Prérequis

- VPS Linux avec Docker accessible à l'utilisateur.
- Terraform >= 1.6.
- Ansible.
- Bash et curl.
- Une paire de clés SSH ED25519 pour la connexion Ansible.
- Ports 12330, 12331, 18130 et 18131 disponibles.

Le fichier authorized_keys doit être créé localement avant
le déploiement. Il doit contenir la clé SSH publique autorisée.

Exemple, si la clé publique existe :

    cp ~/.ssh/id_ed25519.pub authorized_keys

Ne jamais publier de clé privée SSH.

## 4. Déploiement automatisé

Développement :

    ./deploy.sh environments/dev.tfvars

Test :

    ./deploy.sh environments/test.tfvars

Le script initialise Terraform, vérifie la configuration,
sélectionne le workspace, provisionne les ressources,
récupère l'inventaire généré, attend SSH, exécute Ansible
et vérifie la réponse HTTP.

## 5. Vérification du service

Depuis le VPS :

    curl -i http://127.0.0.1:18130
    curl -i http://127.0.0.1:18131

Les deux environnements ont été vérifiés avec une réponse HTTP 200.

## 6. Tests automatisés — Partie B1

Le script utilise :

- terraform fmt -check
- terraform validate
- ansible-playbook
- curl --fail

Un test volontairement invalide dans variables.tf a provoqué
l'arrêt de la chaîne avec un code de retour 1.
Après restauration du fichier valide, le déploiement DEV
s'est terminé avec un code de retour 0.

## 7. Environnements DEV et TEST — Partie B2

Les deux environnements utilisent le même script et
des fichiers de variables distincts :

- environments/dev.tfvars
- environments/test.tfvars

Les états Terraform sont séparés par les workspaces dev et test.

DEV : http://127.0.0.1:18130
TEST : http://127.0.0.1:18131

Les deux services ont répondu HTTP 200.

## 8. Monitoring et alerte — Partie A4

Une vérification des outils de supervision existants a été
effectuée sur le VPS.

Le tableau de bord CPU, mémoire, réseau, temps de réponse HTTP
et l'alerte associée n'ont pas encore été mis en place et validés.

Cette exigence reste incomplète.

## 9. Destruction des ressources

Les ressources peuvent être détruites séparément
pour chaque environnement, après récupération des preuves :

    terraform workspace select dev
    terraform destroy -var-file=environments/dev.tfvars

    terraform workspace select test
    terraform destroy -var-file=environments/test.tfvars

Ces commandes sont documentées mais ne doivent pas être lancées
avant la fin des vérifications et de la collecte des preuves.

## 10. Sécurité et limites

- Docker fonctionne en mode rootless.
- Les ports HTTP UrbanHub sont liés à 127.0.0.1 sur le VPS.
- Les états Terraform et les clés privées sont exclus de Git.
- Le fichier authorized_keys n'est pas publié.
- La supervision reste à finaliser.
- La configuration SSH et les permissions doivent être
  revérifiées avant une utilisation en production.

## 11. Utilisation de l'intelligence artificielle

Modèle et plateforme :
ChatGPT (OpenAI), interface Web.

Périmètre :
Aide à l'analyse du sujet, adaptation du TP Terraform/Ansible,
organisation des tests, interprétation des sorties de commandes,
préparation de la documentation et des preuves.

Principaux prompts et contexte :
- Identifier les exigences EC04 couvertes par les anciens TP.
- Adapter le déploiement à deux environnements DEV et TEST.
- Vérifier le comportement des tests automatisés.
- Préparer le dépôt Git et le README.
- Étudier les possibilités de supervision du VPS.

Audit critique :
Les résultats ont été vérifiés par des commandes exécutées
sur le VPS, notamment terraform validate, les sorties Ansible,
les tests HTTP et le test d'échec volontaire.
La supervision non réalisée est déclarée comme incomplète.

Sécurité :
Vérification des fichiers avant le commit Git, exclusion des
états Terraform et des clés privées, contrôle des accès locaux.

## 12. Preuves

Les captures et résultats de commandes sont regroupés dans
le dossier 02_preuves de l'archive finale.
