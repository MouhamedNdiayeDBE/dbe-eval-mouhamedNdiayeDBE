# État de l'archive de rendu

L'archive publiée `rendus/linux_mouhamedNdiayeDBE.tar.gz` est une archive de validation technique construite dans un environnement Linux isolé. Elle contient le code source, les scripts, la documentation et des sorties de tests reproductibles.

Elle ne contient pas les journaux de session personnels `docs/preuves/linux.log`, `linux.tm`, `git.log`, `git.tm`, ni les exports locaux `historique_linux.txt`, `historique_git.txt` et `reflog.txt`. Les journaux originaux disponibles dans le dépôt ne sont pas copiés dans cette archive provisoire.

Pour le rendu officiel, exécuter L1 à L6 et G1 à G10 sur le poste WSL personnel, conserver les sessions `script`, produire les historiques réels, puis recréer l'archive avec :

~~~bash
tar czf "rendus/linux_${MATRICULE}.tar.gz" src scripts docs rapports
sha256sum "rendus/linux_${MATRICULE}.tar.gz"
~~~

Recopier les 16 premiers caractères de cette empreinte sur la fiche de contrôle papier. Le hash n'est pas à enregistrer dans l'archive. Ne pas remettre l'archive de validation provisoire comme archive finale.
