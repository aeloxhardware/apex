# Feuille de route d'Apex

Ce qui est prévu pour l'application complète (moteur et interface). Les demandes précises entre
dépôts sont dans [`integration/REQUESTS.md`](integration/REQUESTS.md) ; les règles dans
[`integration/RULES.md`](integration/RULES.md). Une entrée dit ce qui est prévu, qui s'en charge et
où elle en est ; elle n'est retirée qu'une fois faite des deux côtés.

## Messages d'erreur de l'utilisateur

### Erreur de tétraédralisation : surface du modèle incohérente
- **Pour** : moteur (`apex-engine`) et interface (`apex-ui`). Demande : R-016.
- **Quand** : le mailleur volumique ne peut pas distinguer l'intérieur de l'extérieur parce que
  la surface du modèle est trop abîmée (trous, faces retournées, auto-intersections…). Modèle refusé :
  code de sortie 3 du protocole de tranchage (RULES §5.2), message lisible par l'utilisateur.
- **Texte validé par l'utilisateur (2026-10-26)** :

  > Erreur de tétraédralisation : la surface du modèle présente [un trou | des trous], [une face
  > retournée | des faces retournées], [une auto-intersection | des auto-intersections]… au-delà du
  > seuil de tolérance, pour un total de x points incohérents, et un maillage volumique d'environ x %
  > du volume calculé sur la surface. Lancez les procédures de réparation automatique du maillage
  > triangulé et assurez-vous que le fichier est complet et fermé.

- **Règles de rédaction** (l'utilisateur est pointilleux sur la langue) :
  - chaque défaut cité s'accorde en nombre, au singulier (« un trou », « une face retournée »,
    « une auto-intersection », « une arête partagée par plus de deux faces », « une face en double »)
    ou au pluriel, selon le nombre réel constaté ;
  - « point incohérent » est au singulier pour 0 et 1, au pluriel à partir de 2 ;
  - la liste suit l'ordre de gravité (trous, faces retournées, auto-intersections, arêtes partagées,
    faces en double), séparée par des virgules et « et » avant le dernier ;
  - un nombre de plus de trois chiffres prend une espace insécable (« 24 689 ») ;
  - si aucun défaut précis n'est identifié : « un défaut de surface » ;
  - seuls les défauts réellement constatés sont cités.
- **Répartition** : le mailleur renvoie des **nombres** (trous, faces retournées, arêtes partagées,
  faces en double, points incohérents, rapport de volume) et un statut ; le **texte français** est
  construit dans le moteur et l'interface, pour pouvoir être traduit. Le nombre d'auto-intersections
  vient de l'étape 1 du moteur. Modèle de code : `apex-engine/tetranet/tools/diagnosis_message.py` et
  ses tests.
- **Seuils** (premières valeurs, mesurées sur le Benchy aux défauts volontaires, à confirmer) :
  avertissement quand les points incohérents dépassent 0,1 % des sommets de la bande de surface ;
  refus au-delà de 5 %.
- **État** : texte validé ; diagnostic chiffré et message accordé écrits dans le prototype
  `apex-engine/tetranet/` ; reste le branchement dans le moteur (code de sortie 3, comptage des
  auto-intersections) et l'affichage dans l'interface.
