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
- État : **faite côté moteur le 2026-10-26** (`apex-engine`) : `APEX_CONTRACT_VERSION = 1` dans
  `config/schema.py`, clé `x-apex-contract` écrite par `scripts/gen_params.py`, `CONTRACT_CHANGES.md`
  créé. Reste : `apex` copie le schéma (sync) et l'interface lit le numéro (R-005).

### R-003 — Interface en ligne de commande du tranchage
- De : apex-ui | À : apex-engine | Contrat : C2, C3 | Ouverte : 2026-10-25
- Besoin : `<moteur> slice --request <requete.json>` et `<moteur> steps` (RULES §5).
- Constat : `main.py` ne prend que des options de ligne de commande isolées (`--resolution`,
  `--layer-height`, `--output-gcode`…), sans requête JSON, sans progression ni résultat
  structurés.
- État : **faite côté moteur le 2026-10-26**, à valider par l'interface (R-004). `python main.py steps` et
  `python main.py slice --request <requete.json>` (`apex-engine/slice_cli.py`, tests
  `tests/test_slice_cli.py`) :
  - requête : `contract`, `mesh`, `output_dir`, `output_name` (facultatif), `params` (`PipelineParams`
    partiel), `gcode_params` (`GcodeParams` partiel) ; un champ inconnu à n'importe quel niveau, ou un
    numéro de contrat différent, donne le code 2 ;
  - sortie d'erreur : lignes JSON `{"type":"step","slug","fraction"}` (0 au début, 1 à la fin de
    chacune des 11 étapes, `export` comprise) et `{"type":"log","level","code","message"}` ; le journal
    libre du pipeline y est aussi envoyé ;
  - sortie standard : une seule ligne, l'objet résultat (`status` : `ok`, `invalid_request`,
    `model_refused`, `surface_inconsistent`, `export_refused`, `error` ; `gcode`, `report`,
    `placement_offset_z`, comptes, `warnings`) ;
  - codes : 0 réussi, 2 requête invalide, 3 modèle refusé (dont R-016 et le refus de l'export strict),
    1 plantage ; G-code écrit en `.part` puis renommé.
  - **Limites connues** : (1) pas de fraction intermédiaire à l'intérieur d'une étape (le moteur ne
    rend pas la main avant d'avoir fini) : la barre avance par étape, sans estimation ; (2) la
    commande est `python main.py` tant que l'exécutable natif sans Python n'existe pas (R-014).

### R-004 — Brancher le vrai tranchage dans l'interface
- De : apex | À : apex-ui | Contrat : C2, C3 | Ouverte : 2026-10-25
- Besoin : remplacer la simulation par l'appel du §5, une fois R-003 fait. **La barre de
  progression suit les lignes de progression du moteur et ne doit plus du tout être une
  minuterie** (décision de l'utilisateur, 2026-10-26 ; RULES §5.3) ; les étapes affichées
  viennent de `<moteur> steps`.
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
- Constat du 2026-10-27 (`apex-engine@11a5e798`) : inchangé. `GcodeParams` porte bien `pivot_to_tip`,
  `tilt_sign`, `b_sign`, `z_reference`, mais l'en-tête écrit (`gcode_export.py`) ne contient que
  `; apex_sliced = 1` ; `GcodeReport.pivot_to_tip` n'est que dans le résultat JSON, pas dans le fichier.
- Proposition (le moteur choisit) : lignes d'en-tête `; apex_kinematics pivot_to_tip=… b_sign=…
  tilt_sign=… z_reference=…`, ou ces quatre valeurs dans le bloc `meta` de R-010. Les deux demandes
  se traitent ensemble. Côté interface, ne plus lire `NOZZLE_PIVOT_MM` en dur : lire l'en-tête,
  refuser un fichier qui n'en a pas (sauf marqueur d'ancienne version).
- État : ouverte.

### R-008 — Vecteurs de test de la cinématique
- De : apex | À : apex-engine, puis apex-ui | Contrat : C4 | Ouverte : 2026-10-25
- Besoin : le moteur publie des vecteurs (pointe + B d'Apex → X, Y, Z, B firmware et retour)
  tirés de `machine_to_firmware` / `firmware_to_machine` ; l'interface les rejoue contre
  `nozzleTip` (`gcodeParse.ts`) et le noyau `native/` (RULES §6).
- Constat : la même formule existe trois fois, sans test commun.
- Constat du 2026-10-27 : `tests/test_gcode_export.py` teste déjà `machine_to_firmware` /
  `firmware_to_machine` (aller-retour), mais aucun fichier de vecteurs JSON n'est publié ; l'interface
  n'a donc rien à rejouer. Besoin précisé : un fichier `tests/vectors/kinematics_vectors.json`
  (pivot, `b_sign`, `tilt_sign`, `z_reference`, entrées, sorties, tolérance) généré par un script du
  moteur avec `--check`, copié dans `apex` par `sync.sh`.
- État : ouverte. Dépend de R-007 pour les paramètres à inclure.

### R-009 — Deux modèles de tête différents
- De : apex | À : apex-engine, apex-ui | Contrat : C6 | Ouverte : 2026-10-25
- Besoin : un seul `aetheris-4.glb`, copié par script dans l'interface.
- Constat : SHA-256 `8f9a854d…` (`apex-engine/res/3d/toolheads/aetheris-4/aetheris-4.glb`)
  contre `511c0807…` (`apex-ui/src/assets/models/aetheris-4.glb`). Non vérifié : si la
  géométrie diffère ou seulement l'encodage. Les collisions de l'édition (interface) et de
  l'étape 9 (moteur) peuvent donc ne pas porter sur la même tête.
- Mesuré le 2026-10-27 (`trimesh`, `to_geometry()`, mm) : **les géométries diffèrent**, ce n'est pas
  un simple réencodage.

  | | moteur | interface |
  |---|---|---|
  | sommets / faces | 377 / 372 | 16 237 / 21 538 |
  | boîte (mm) | x −29,1…46,9 ; y 0,1…77,25 ; z −18,9…16,1 | x −29,1…46,9 ; y 0…76,55 ; z −17,5…17,5 |
  | aire (mm²) | 15 729 | 31 502 |

  Même étendue en X et même hauteur en Z (35 mm), mais la boîte du moteur est décalée de ~1,4 mm
  en Z, et son extrémité en Y est 0,7 mm plus haute. La copie de l'interface compte 43 fois plus
  de sommets : elle semble une version plus détaillée, recentrée en Z. L'étape 9 teste des points de
  la surface : un autre échantillonnage et un décalage de 1,4 mm donnent des distances différentes.
  Non vérifié : si le décalage est une retouche voulue ou un changement d'origine.
- Question à l'utilisateur : quelle est la bonne tête (origine = pointe de buse, convention du moteur) ?
  Sans réponse, le moteur ne peut pas la remplacer : l'étape 9 est mesurée avec la sienne.
- État : question à l'utilisateur. Dès qu'une des deux est désignée, copie par script (C6, `--check`).

### R-010 — Le moteur écrit le bloc d'en-tête chiffré
- De : apex-ui | À : apex-engine | Contrat : C5 | Ouverte : 2026-10-25
- Besoin : le moteur écrit `sliced` et `meta` dans le bloc défini par
  `apex-ui/docs/APEX_HEADER_FORMAT.md`, et passe `apex_cipher_vectors.json`.
- Constat : le moteur n'écrit que le marqueur en clair `; apex_sliced = 1`.
- Constat du 2026-10-27 : le moteur n'écrit toujours que `; apex_sliced = 1` (`gcode_export.py`) ;
  aucun fichier du moteur ne référence `APEX_HEADER_FORMAT` ou `apex_cipher_vectors.json`.
- Question ouverte pour le moteur (C++ à terme, R-014) : le chiffrement doit être implémenté en C++
  dans l'exécutable ; l'interface publie les vecteurs, le moteur les rejoue en test.
- État : ouverte. Traiter avec R-007 (mêmes lignes d'en-tête).

### R-012 — Monter `apex` : copie des deux dépôts et première release
- De : apex | À : apex | Contrat : — | Ouverte : 2026-10-25
- Fait :
  - 2026-10-25 : première copie par `integration/sync.sh` (`apex-engine@6e0081e`,
    `apex-ui@b57fb2b`, `integration/sources.json`). Exclus : sorties, artefacts de
    compilation, journaux de session, `research/`, `icons-main/`.
  - 2026-10-26 : fichiers de contexte des sessions (`CLAUDE.md`, `DT.md`, `LAST_SESSION.md`,
    `AI_RULES.md`) exclus de la copie : ils restent dans leurs dépôts, où l'on développe ;
    crédits réunis dans le README d'`apex` ; numéro de version commun (`VERSION`,
    `VERSIONS.md`, RULES §9.1).
- Décisions de l'utilisateur (2026-10-26) : copie sans historique, mise à jour à la main avant
  chaque release puis automatisée ; dépôts rendus publics au fur et à mesure ; première
  release Windows 64 bits seulement ; binaires natifs compilés sur une machine Windows de
  GitHub Actions, jamais commités.
- Décisions sur la barrière de qualité (2026-10-26, RULES §4.3 et §7) : version du contrat
  vérifiée, moteur en sous-processus (exécutable séparé), Python gardé comme référence
  jusqu'à la fin du portage, relectures croisées automatiques, test d'installation sur une
  machine Windows propre ; sans impression réelle, **pré-release** seulement, **release**
  après impression. L'historique git se lit dans les dépôts d'origine.
- Reste : `RELEASES.md` ; la construction Windows sur GitHub Actions (moteur natif + noyau
  d'édition + Electron) ; les contrôles du §7 ; R-015.
- État : en cours, release bloquée par R-014.

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
- Vérifié le 2026-10-27 (`apex-engine@11a5e798`, `trimesh`) : `main.py:179` vaut toujours `False`.
  **La perte des transformations est CONFIRMÉE** : une scène de deux cubes, le second placé en x = 50,
  donne par `concatenate(list(geometry.values()))` une boîte de −5…5 (les deux cubes superposés à
  l'origine) contre −5…52,5 par `scene.to_geometry()`. Un 3MF dont les objets sont positionnés par
  transformation de nœud serait donc empilé à l'origine, sans erreur. Correctif de principe :
  `loaded.to_geometry()` à la place de `concatenate(...geometry.values())`.
  Non vérifié : la perte d'une petite pièce par `_extract_dominant_shell` (modèle à deux pièces à
  construire).
- Reste côté interface : placer le réglage dans « Réglages avancés… » (C1, schéma).
- État : ouverte (moteur : défaut + `to_geometry()` + deux tests ; interface ensuite).

### R-014 — Moteur 100 % C++ avant toute release
- De : utilisateur | À : apex-engine | Contrat : C2 | Ouverte : 2026-10-26
- Besoin (décision de l'utilisateur) : la release n'est faite que lorsque le moteur, voie de
  la chaleur comprise, tourne entièrement en C++, sans Python.
- Constat du 2026-10-26 (rescan), branche `apex-engine` `ccr-25ac6a07-1v5ulx`
  (`4dcc8ac3`, **pas encore fusionnée dans `main`** ; `main` reste à `6e0081e`) : gros
  progrès, mais le moteur n'est toujours **PAS 100 % C++**.
  - Devenus natifs (test d'équivalence chacun, limite #82 du moteur) : méthode de la chaleur
    et CG de Jacobi parallèle (death 6,5 → 2,6 s) ; couches de l'étape 5 en un appel ; tri
    de 5b ; remplissage de couches entières avec ponts (Clipper2, **actif par défaut**) ;
    assemblage, normale par point et filtre médian de l'étape 8 ; contrôle de collision par
    lots (étapes 9 et 10) ; réorientations de l'étape 10 ; en-tête et pied du G-code ;
    **TetGen compilé depuis sa source, dans un exécutable C++ séparé** (`apex_tetgen_worker`,
    maillage identique au module Python).
  - Reste en Python (d'après la limite #82, à confirmer à la fusion) :
    - l'enchaînement des étapes (`main.py`) et le contrat entre étapes en objets Python
      (`Layer`, `ToolpathPoint` : 360 000 objets sur death) ; un orchestrateur natif demande
      de passer ce contrat en tableaux (étapes 8, 8b, 9, 9b, 10, export) ;
    - étape 1 : chargement et réparation du maillage (trimesh, pymeshfix, manifold3d,
      shapely, networkx) ; seul TetGen est natif ;
    - repli par grille de la cinématique inverse (0,14 % des points), échantillonnage de la
      tête (étape 9, trimesh), boucle `run` et journal de l'étape 10, enveloppe de l'étape 7,
      motif `OSCILLATING_SPIRAL`, préparation du contrôle des dégagements de l'export ;
    - voies FEM directionnelle, multibranche, parties planes : vouées au retrait.
  - Mesure : death @ 0,8, 42 → 33 s (TetGen ~14 s).
  - Il manque aussi un point d'entrée exécutable natif (R-003).
- Mise à jour du 2026-10-27 : `apex-engine` a retiré la voie FEM et Bird (contrat 2,
  `CONTRACT_CHANGES.md`), ce qui réduit le périmètre : il ne reste plus à porter ni champ FEM, ni
  multibranche, ni parties planes. Reste à porter : enchaînement des étapes et contrat en tableaux,
  étape 1 (trimesh, pymeshfix, manifold3d), points listés ci-dessus. Le moteur doit confirmer la liste à
  jour (elle date du 2026-10-26).
- Question à l'utilisateur pour borner le chantier : l'étape 1 (réparation du maillage) doit-elle être
  portée en C++, ou remplacée par `tetranet/` (prototype de mailleur, qui renvoie déjà
  `InconsistentSurface`) ? Les deux sont compatibles avec R-016.
- État : ouverte. Bloque R-012.

### R-015 — Barrière « pas de recul des résultats »
- De : apex | À : utilisateur | Contrat : — | Ouverte : 2026-10-26
- Besoin : décider si une version peut sortir quand elle tranche moins bien que la
  précédente (RULES §7, contrôle 6).
- Proposition : avant chaque version, trancher les quatre modèles de référence et comparer
  quatre chiffres à la version publiée précédente — matière déposée sans appui, matière
  flottante, collisions de la tête, temps d'impression. Si l'un se dégrade au-delà d'un
  seuil (par exemple +10 %), la version est bloquée, sauf si la dégradation est voulue et
  écrite dans `VERSIONS.md`. Le but : qu'une optimisation ou un portage ne dégrade pas les
  pièces sans que personne le voie.
- État : question à l'utilisateur (oui / non, et le seuil).

### R-016 — Message d'erreur : surface du modèle incohérente
- De : utilisateur | À : apex-engine, apex-ui | Contrat : C2 | Ouverte : 2026-10-26
- Besoin : quand la surface du modèle est trop abîmée pour que le maillage volumique distingue
  l'intérieur de l'extérieur, le moteur refuse le modèle (code de sortie 3, RULES §5.2) avec un
  résultat structuré, et l'interface affiche le message validé par l'utilisateur (texte, règles
  d'accord en nombre et seuils : `ROADMAP.md`, « Messages d'erreur de l'utilisateur »).
- Constat : le prototype de mailleur (`apex-engine/tetranet/`) renvoie déjà un statut
  `InconsistentSurface` et le diagnostic chiffré (trous, faces retournées, arêtes partagées, faces
  en double, points incohérents) ; le message français accordé est dans
  `tetranet/tools/diagnosis_message.py`. Les auto-intersections viennent de l'étape 1 du moteur.
- À faire : moteur — champ de résultat (type de défaut + nombres) et refus avec ce statut ;
  interface — afficher le texte, le même dans les deux langues prévues, accords compris.
- État : ouverte.

### R-017 — Progression réelle à l'intérieur de chaque étape
- De : apex-ui | À : apex-engine | Contrat : C3 | Ouverte : 2026-10-27
- Besoin : l'interface montre une barre par étape (11 barres, une par étape de `main.py steps`) ;
  pour qu'elles avancent progressivement au lieu de sauter de 0 à 100 %, le moteur doit rapporter
  des fractions intermédiaires pendant chaque étape, calculées sur du travail réellement fait
  (RULES §5.3 : jamais une durée estimée).
- Constat : `run_pipeline` n'appelle `progress(slug, fraction)` qu'à 0,0 et 1,0 par étape
  (`main.py`, docstring : « pas de fraction intermédiaire pour l'instant ») ; le journal
  `out/benchy_tilted_tf3000/stderr.log` ne contient que ces deux valeurs par étape, alors que
  l'étape 8 traite 241 944 points et l'étape 5 extrait 310 couches. Le format C3 (ligne
  `{"type":"step","slug","fraction"}` sur la sortie d'erreur) permet déjà des valeurs
  intermédiaires : aucun changement de contrat. L'interface lit déjà `fraction` et l'affiche.
- À faire : moteur — transmettre le rappel de progression aux boucles de chaque étape, avec une
  unité de travail par étape (par exemple couches extraites, couches remplies, passes
  ordonnancées, points de la cinématique inverse, points testés en collision, itérations de
  l'ajustement, lignes de G-code écrites) ; limiter le débit (au plus un message par pas de 1 %
  ou par 100 ms) ; pour le noyau C++, appeler par lots ou rappeler rarement, sans le ralentir ;
  garder la fraction croissante dans une étape. Interface — rien d'obligatoire (au besoin,
  refuser qu'une barre recule).
- Constat du 2026-10-27 (`apex-engine@11a5e798`) : toujours deux valeurs par étape (`main.py` :
  `progress(slug, 0.0)` puis `1.0`). Étapes les plus longues à instrumenter d'abord (mesure de
  death @ 0,8, limite #82/#73) : étape 1 (TetGen, sous-processus : le worker peut journaliser ses
  phases, voir `APEX_TETGEN_LOG`), étape 4 (itérations du CG), étape 8, étape 9. Le noyau natif doit
  accepter un rappel appelé par lots (le GIL est libéré dans les points d'entrée).
- État : ouverte.

### R-018 — R-002 et R-003 : faites côté moteur, à fermer côté interface
- De : apex | À : apex | Contrat : — | Ouverte : 2026-10-27
- Besoin : `REQUESTS.md` garde R-002 et R-003 « ouvertes » alors que le moteur les a faites ;
  elles ne se ferment qu'avec le commit de l'interface (RULES §8). Les lister ici pour ne pas les
  perdre : R-002 attend R-005 (interface), R-003 attend R-004 (interface).
- Constat : contrat à la version 2 depuis le 2026-10-27 (`CONTRACT_CHANGES.md`) : l'interface qui
  lirait le schéma en version 1 serait refusée par la requête (code 2).
- État : ouverte, suivi seulement ; se ferme avec R-004 et R-005.

### R-019 — `VERSIONS.md` ne mentionne pas le changement de méthode du moteur
- De : apex-engine | À : apex | Contrat : — | Ouverte : 2026-10-27
- Besoin : `VERSION` vaut `alpha-0.2.1.4.3.11.1.221` (2026-10-21, interface) ; le moteur a changé de
  méthode de tranchage (voie unique de la chaleur, contrat 2, majeur) sans que la ligne existe dans
  `VERSIONS.md` (RULES §9.1).
- À faire (session moteur, à la prochaine montée de version) : un niveau **majeur** (« nouvelle
  méthode de tranchage ») : `alpha-0.2.2.0.0.0.0.221` (majeur +1, niveaux à droite remis à zéro, Builds inchangé) ; `git pull` d'`apex` d'abord, message de
  commit préfixé du numéro complet. **Question à l'utilisateur** : confirmer que le retrait FEM/Bird
  est bien un niveau majeur et non moyen.
- État : question à l'utilisateur.

## Fermées

### R-011 — Python embarqué et dépendances du moteur
- De : apex | À : utilisateur | Contrat : C2 | Ouverte : 2026-10-25
- Besoin : l'application publiée doit pouvoir lancer le moteur sans installation.
- État : faite (2026-10-26, décision de l'utilisateur) — pas de Python embarqué ni
  figé : le moteur livré sera entièrement en C++, et **aucune release avant** (R-014).

### R-001 — Sort de la copie du moteur dans `apex`
- De : apex | À : utilisateur | Contrat : — | Ouverte : 2026-10-25
- Besoin : savoir ce que contient `apex`.
- État : faite (2026-10-25, réponse de l'utilisateur) — `apex` est la combinaison du moteur et
  de l'interface, avec les releases ; l'ancien `apex` est devenu `apex-engine`.
