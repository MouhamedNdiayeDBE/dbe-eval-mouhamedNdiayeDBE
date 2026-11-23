# État de l'archive de rendu

L'archive de validation rendus/linux_mouhamedNdiayeDBE.tar.gz contient le code, les scripts, les documentations, les rapports et les sorties de validation technique générées dans un environnement Linux isolé.

Elle ne contient pas encore les traces personnelles originales stockées sur la branche GitHub (docs/preuves/linux.log, linux.tm, git.log, git.tm, .bashrc) ni les fichiers historique_linux.txt, historique_git.txt et reflog.txt à produire depuis le WSL de l'étudiant.

Pour la remise officielle, récupérer la branche de correction dans le WSL, compléter les historiques pendant les sessions script, puis régénérer l'archive avec la commande L6 :

~~~bash
tar czf "rendus/linux_${MATRICULE}.tar.gz" src scripts docs rapports
sha256sum "rendus/linux_${MATRICULE}.tar.gz"
~~~

Ne pas utiliser l'empreinte de l'archive de validation comme empreinte finale de remise.
