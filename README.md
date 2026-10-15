# UrbanHub — EC04 Partie 1
## Déploiement automatisé d'un service web

## 1. Présentation du projet

UrbanHub est un projet Smart City s'inscrivant dans une démarche de jumeau numérique urbain.

L'objectif de cette épreuve EC04 est d'automatiser le provisionnement d'une infrastructure, la configuration d'un serveur web et la vérification de son fonctionnement.

Le projet réutilise et adapte un environnement pédagogique existant.

## 2. Choix techniques

- Terraform : provisionnement de l'infrastructure.
- Docker : simulation d'un serveur sur le VPS pédagogique.
- Ansible : installation et configuration du serveur.
- Nginx : hébergement de la page web.
- Jinja2 : personnalisation de la page HTML.
- Bash : orchestration du déploiement.
- Git : versionnement du projet.

Le conteneur Docker représente un environnement serveur simulé. Il ne constitue pas une machine virtuelle dans un cloud public.

## 3. Architecture technique

Le déploiement repose sur la chaîne suivante :

Terraform → Docker → Inventaire Ansible → Ansible → Nginx → Test HTTP

Terraform crée le conteneur Docker et génère automatiquement un inventaire Ansible.

Ansible utilise cet inventaire pour se connecter au conteneur, installer Nginx, démarrer le service et publier une page HTML personnalisée.

Le script deploy.sh orchestre l'ensemble des étapes.

## 4. Prérequis

- Un serveur Linux avec Docker fonctionnel.
- Terraform installé.
- Ansible installé.
- Bash et curl disponibles.
- Une paire de clés SSH pour l'accès au conteneur.
- Des ports SSH et HTTP disponibles.

Le projet utilise deux environnements distincts :

| Environnement | SSH | HTTP |
|---|---|---|
| DEV | 12330 | 18130 |
| TEST | 12331 | 18131 |

Les services HTTP sont accessibles localement depuis le VPS.

## 5. Déploiement automatisé

Pour déployer DEV :

    ./deploy.sh environments/dev.tfvars

Pour déployer TEST :

    ./deploy.sh environments/test.tfvars

Le script réalise successivement :

1. L'initialisation Terraform.
2. La vérification du format et de la configuration Terraform.
3. La sélection du workspace correspondant.
4. Le provisionnement des ressources.
5. L'attente de la disponibilité SSH.
6. L'exécution du playbook Ansible.
7. La vérification HTTP du service.

L'inventaire Ansible et l'adresse HTTP sont récupérés depuis les outputs Terraform.

## 6. Configuration du serveur web

Le playbook Ansible effectue :

- La mise à jour du cache APT.
- L'installation de Nginx.
- Le démarrage de Nginx.
- L'activation du service au démarrage.
- Le déploiement d'une page HTML personnalisée avec Jinja2.

La page affiche notamment la ville configurée et le nom d'hôte du conteneur.

## 7. Résultats du déploiement DEV

La commande utilisée est :

    ./deploy.sh environments/dev.tfvars

Le conteneur urbanhub-dev a été provisionné et configuré.

Une nouvelle exécution du script a produit :

- Terraform : 0 added, 0 changed, 0 destroyed.
- Ansible : ok=5, changed=0, unreachable=0, failed=0.
- Test HTTP : réponse valide.
- Message final : DEPLOIEMENT TERMINE.
- Code de retour : 0.

Ces résultats montrent que le déploiement est reproductible et qu'une nouvelle exécution ne provoque pas de modification inutile des ressources.

L'adresse du service DEV est :

    http://127.0.0.1:18130

Le contrôle HTTP a retourné le statut 200 OK.

## 8. Tests automatisés — B1

Le script utilise les commandes suivantes avant le provisionnement :

    terraform fmt -check
    terraform validate

Après la configuration Ansible, il contrôle le service avec curl.

Le script utilise également :

    set -Eeuo pipefail

Cette configuration permet d'interrompre la chaîne lorsqu'une commande échoue.

### Démonstration d'un échec bloquant

Une déclaration volontairement invalide a été introduite temporairement dans variables.tf :

    type = type_inexistant

Lors de l'exécution de deploy.sh, Terraform a détecté l'erreur dès l'étape terraform init.

Le script s'est interrompu avec un code de retour 1.

Les étapes de provisionnement, de configuration Ansible et de vérification HTTP n'ont pas été exécutées.

### Correction et nouvelle exécution

Le fichier variables.tf a ensuite été restauré.

Les commandes terraform fmt -check et terraform validate ont confirmé la validité de la configuration.

Une nouvelle exécution de deploy.sh s'est terminée correctement :

- Terraform : aucune modification nécessaire.
- Ansible : failed=0 et unreachable=0.
- Test HTTP : réponse valide.
- Code de retour : 0.

La comparaison démontre que le script bloque une exécution en erreur et fonctionne de nouveau après correction.

## 9. Déploiement multi-environnements — B2

Le projet utilise deux fichiers de variables :

- environments/dev.tfvars
- environments/test.tfvars

Deux workspaces Terraform isolent les états :

- dev
- test

Le même script deploy.sh est utilisé pour les deux environnements.

DEV utilise le conteneur urbanhub-dev et le port HTTP 18130.

TEST utilise le conteneur urbanhub-test et le port HTTP 18131.

Les deux conteneurs ont été vérifiés simultanément avec docker ps.

Les tests HTTP ont retourné :

- DEV : HTTP 200.
- TEST : HTTP 200.

Ces résultats confirment le fonctionnement des deux environnements.

Lors du premier déploiement, la préparation de l'accès SSH de TEST a nécessité une intervention manuelle. Cette limite doit être prise en compte dans l'évaluation de l'automatisation complète.

## 10. Supervision et alertes

La supervision demandée comprend :

- L'utilisation CPU.
- L'utilisation mémoire.
- La bande passante réseau.
- Le temps de réponse HTTP.
- Au moins une alerte avec un seuil justifié.

Les vérifications réalisées sur le VPS n'ont pas permis d'identifier une installation opérationnelle de Prometheus, Grafana ou Netdata.

Aucun tableau de bord ni aucune alerte fonctionnelle n'ont été démontrés à ce stade.

Cette partie reste donc non réalisée.

## 11. Sécurité et gestion des secrets

Les fichiers d'état Terraform, les clés privées SSH, les fichiers temporaires et les fichiers de sauvegarde sont exclus du dépôt Git au moyen de .gitignore.

Le fichier authorized_keys contient une clé publique SSH et n'est pas publié dans le dépôt.

Aucun mot de passe ni token d'accès ne doit être ajouté au code source.

Les ports des conteneurs UrbanHub sont liés à l'adresse locale 127.0.0.1 du VPS.

Les accès SSH doivent être vérifiés et les clés d'hôtes validées avant leur utilisation.

## 12. Destruction des ressources

Pour détruire les ressources de DEV :

    terraform workspace select dev
    terraform destroy -var-file=environments/dev.tfvars

Pour détruire les ressources de TEST :

    terraform workspace select test
    terraform destroy -var-file=environments/test.tfvars

Ces commandes doivent être exécutées uniquement après avoir conservé les preuves nécessaires.

## 13. Utilisation de l'intelligence artificielle

Outil utilisé : ChatGPT, modèle GPT-6, via l'interface web.

Périmètre d'utilisation :

- Analyse des exigences du sujet EC04.
- Identification des livrables attendus.
- Adaptation du TP existant au projet UrbanHub.
- Assistance sur les fichiers Terraform, Ansible et Bash.
- Préparation des tests DEV et TEST.
- Analyse des erreurs rencontrées.
- Aide à la rédaction du README et à l'organisation des preuves.

Principaux prompts et contexte :

- Analyse du sujet UrbanHub et des livrables.
- Vérification de la structure du projet existant.
- Adaptation du déploiement à deux environnements.
- Démonstration d'un échec bloquant et de sa correction.
- Vérification des outils de supervision disponibles.
- Préparation du dépôt Git et de la documentation.

Relecture critique et validation :

Les propositions ont été confrontées aux sorties des commandes réellement exécutées.

Les configurations Terraform ont été vérifiées avec terraform validate.

Les déploiements ont été contrôlés avec Ansible, docker ps et curl.

Les fichiers sensibles ont été exclus du dépôt Git.

Les fonctionnalités non réalisées, notamment la supervision, sont signalées explicitement.

## 14. Organisation du livrable

L'archive finale doit contenir :

- 01_depot_git/ : dépôt Git avec son historique et les fichiers du projet.
- 02_preuves/ : captures d'écran et sorties de commandes.
- 03_README.md : copie identique du README principal.

Les preuves comprennent notamment :

- Le déploiement automatisé.
- La configuration Ansible.
- La réponse HTTP du service.
- L'exécution DEV.
- L'exécution TEST.
- La vérification HTTP simultanée.
- L'échec bloquant B1.
- La correction et la nouvelle exécution réussie.

Les informations personnelles doivent être anonymisées conformément aux consignes de l'épreuve.
