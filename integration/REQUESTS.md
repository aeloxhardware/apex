# Demandes entre dépôts

Format et règles : [`RULES.md`](RULES.md), §8. Les demandes ouvertes sont en haut ; une session
lit celles qui sont adressées à son dépôt en début de session.

Les demandes R-001 à R-011 viennent de l'inventaire du 2026-10-25 (`apex-engine@6e0081e4`,
`apex-ui@b57fb2b`). Chaque constat a été vérifié dans le code à cette date.

## Ouvertes

### R-002 — Numéro de contrat dans le schéma
- De : apex | À : apex-engine | Contrat : C1 | Ouverte : 2026-10-25
- Besoin : `scripts/gen_params.py` écrit `x-apex-contract` (entier) dans
  `config/params.schema.json` ; le moteur crée `CONTRACT_CHANGES.md` (RULES §4.1, §9).
- État : ouverte.

### R-003 — Interface en ligne de commande du tranchage
- De : apex-ui | À : apex-engine | Contrat : C2, C3 | Ouverte : 2026-10-25
- Besoin : `<moteur> slice --request <requete.json>` et `<moteur> steps` (RULES §5).
- Constat : `main.py` ne prend que des options de ligne de commande isolées (`--resolution`,
  `--layer-height`, `--output-gcode`…), sans requête JSON, sans progression ni résultat
  structurés.
- État : ouverte.

### R-004 — Brancher le vrai tranchage dans l'interface
- De : apex | À : apex-ui | Contrat : C2, C3 | Ouverte : 2026-10-25
- Besoin : remplacer la simulation par l'appel du §5, une fois R-003 fait.
- Constat : `SlicingProgressModal.tsx` avance d'une étape toutes les 1 200 ms
  (`STEP_DURATION_MS`) ; `slicingSteps.ts` liste des étapes de la voie Bird (« Déformation du
  maillage tétraédrique »…), retirée du moteur le 2026-10-25.
- État : ouverte, dépend de R-003.

### R-005 — L'interface lit le schéma des paramètres
- De : apex | À : apex-ui | Contrat : C1 | Ouverte : 2026-10-25
- Besoin : script de copie du schéma depuis `apex-engine` (avec `--check`), types TypeScript
  générés, `APEX_CONTRACT_VERSION` vérifié à la construction (RULES §4).
- Constat : aucun fichier de `apex-ui` ne lit `params.schema.json`.
- État : ouverte, dépend de R-002.

### R-006 — Limites de la machine recopiées à la main
- De : apex | À : apex-ui, apex-engine | Contrat : C1, C7 | Ouverte : 2026-10-25
- Besoin : une seule source pour les limites de la machine actuelle.
- Constat : `apex-ui/src/utils/machineLimits.ts` recopie `_default_machine_profile` du moteur
  (B 0 à 185°, 1666,7 °/s, 1300 °/s², plateau de 150 mm) ;
  `apex-ui/src/utils/layerLimits.ts` fixe 0,06 à 0,3 mm sans équivalent moteur ; les profils
  d'imprimante de l'interface (`apex.rotary_axes`, `pivot_distance_mm`) ne sont pas reliés à
  `MachineProfile`.
- État : question à l'utilisateur — qui produit la description de la machine : le moteur
  (`MachineProfile`, déjà dans le schéma) ou les profils d'imprimante de l'interface (C7) ?

### R-007 — Longueur pivot-pointe portée par le G-code
- De : apex-ui | À : apex-engine | Contrat : C4, C5 | Ouverte : 2026-10-25
- Besoin : le G-code dit avec quelle longueur pivot-pointe, quel `b_sign`, quel `tilt_sign` et
  quelle référence de Z il a été écrit, pour que l'aperçu et le noyau d'édition relisent la
  pointe exactement.
- Constat : l'interface suppose `NOZZLE_PIVOT_MM = 46` (`gcodeParse.ts`) ; le moteur rend cette
  longueur réglable (`config/pivot_to_tip.json`, `GcodeParams.pivot_to_tip`). Un G-code exporté
  avec une autre longueur serait mal relu, sans erreur.
- État : ouverte.

### R-008 — Vecteurs de test de la cinématique
- De : apex | À : apex-engine, puis apex-ui | Contrat : C4 | Ouverte : 2026-10-25
- Besoin : le moteur publie des vecteurs (pointe + B d'Apex → X, Y, Z, B firmware et retour)
  tirés de `machine_to_firmware` / `firmware_to_machine` ; l'interface les rejoue contre
  `nozzleTip` (`gcodeParse.ts`) et le noyau `native/` (RULES §6).
- Constat : la même formule existe trois fois, sans test commun.
- État : ouverte.

### R-009 — Deux modèles de tête différents
- De : apex | À : apex-engine, apex-ui | Contrat : C6 | Ouverte : 2026-10-25
- Besoin : un seul `aetheris-4.glb`, copié par script dans l'interface.
- Constat : SHA-256 `8f9a854d…` (`apex-engine/res/3d/toolheads/aetheris-4/aetheris-4.glb`)
  contre `511c0807…` (`apex-ui/src/assets/models/aetheris-4.glb`). Non vérifié : si la
  géométrie diffère ou seulement l'encodage. Les collisions de l'édition (interface) et de
  l'étape 9 (moteur) peuvent donc ne pas porter sur la même tête.
- État : ouverte — l'interface vérifie d'abord si sa copie a été retouchée exprès.

### R-010 — Le moteur écrit le bloc d'en-tête chiffré
- De : apex-ui | À : apex-engine | Contrat : C5 | Ouverte : 2026-10-25
- Besoin : le moteur écrit `sliced` et `meta` dans le bloc défini par
  `apex-ui/docs/APEX_HEADER_FORMAT.md`, et passe `apex_cipher_vectors.json`.
- Constat : le moteur n'écrit que le marqueur en clair `; apex_sliced = 1`.
- État : ouverte.

### R-011 — Python embarqué et dépendances du moteur
- De : apex | À : utilisateur | Contrat : C2 | Ouverte : 2026-10-25
- Besoin : l'application publiée doit pouvoir lancer le moteur sans installation.
- Constat : l'interface embarque Python 3.12 « embeddable », bibliothèque standard seule
  (`scripts/fetch-python-embed.cjs`), pour `gcode_to_polar.py`. Le moteur tourne sous
  Python 3.14 avec trimesh, scipy, tetgen, rtree, manifold3d, networkx, shapely et son module
  natif.
- État : question à l'utilisateur — embarquer un Python complet avec le moteur, ou attendre un
  exécutable natif du moteur.

### R-012 — Monter `apex` : copie des deux dépôts et première release
- De : apex | À : apex | Contrat : — | Ouverte : 2026-10-25
- Besoin : copier le moteur et l'interface dans `slicer-engine/` et `slicer-ux/`, créer
  `apex/RELEASES.md`, et déplacer la construction des exécutables (`electron:build`) vers
  `apex` (RULES §1, §4.3).
- Fait (2026-10-25) : première copie par `integration/sync.sh`, `apex-engine@6e0081e` et
  `apex-ui@b57fb2b` (`integration/sources.json`), 1 910 fichiers, 61 Mo. Exclus : sorties
  (`out/`, GLB et GIF de la racine), artefacts de compilation (`build/`, `cpp/build/`,
  `cpp/lib/`), journaux de session (`claude_context/`), et les dossiers que les deux dépôts
  déclarent ignorés mais contiennent quand même (`research/`, `icons-main/`).
- Reste : `RELEASES.md` ; construire les exécutables depuis `slicer-ux/` en y joignant le
  moteur (dépend de R-011) ; lancer la suite de tests du moteur dans la copie.
- État : en cours.

### R-013 — Plusieurs pièces sur le plateau, par défaut
- De : utilisateur | À : apex-engine, puis apex-ui | Contrat : C1 | Ouverte : 2026-10-25
- Besoin (décision de l'utilisateur) : `PipelineParams.allow_multi_mesh` passe à vrai par
  défaut, car l'interface assemble le plateau en un seul maillage et un slicer doit accepter
  plusieurs pièces. Dans l'interface, ce réglage va dans « Réglages avancés de l'algorithme
  pour développeur », pas dans « Paramètres de tranchage ».
- Constat (`apex-engine@6e0081e`) :
  - `main.py` : `allow_multi_mesh: bool = False` ; `step1_ingest._load_raw_mesh` refuse
    alors un fichier à plusieurs objets.
  - Avec le réglage actif, `_load_raw_mesh` concatène `loaded.geometry.values()` : les
    transformations de la scène (placement des objets d'un 3MF) sont perdues. À vérifier,
    et à remplacer par `loaded.to_geometry()` si c'est le cas.
  - `_extract_dominant_shell` garde la plus grosse coque et jette les autres quand elle fait
    au moins 95 % du volume et que le maillage combiné n'est pas étanche : une petite pièce
    posée à côté d'une grande pourrait disparaître sans erreur. À vérifier sur un plateau à
    deux pièces de tailles très différentes.
  - Les fichiers à un seul objet donnent le même résultat dans les deux positions.
- État : ouverte.

## Fermées

### R-001 — Sort de la copie du moteur dans `apex`
- De : apex | À : utilisateur | Contrat : — | Ouverte : 2026-10-25
- Besoin : savoir ce que contient `apex`.
- État : faite (2026-10-25, réponse de l'utilisateur) — `apex` est la combinaison du moteur et
  de l'interface, avec les releases ; l'ancien `apex` est devenu `apex-engine`.
