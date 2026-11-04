# Versions d'Apex

Journal de tous les changements de version de l'application, qu'ils viennent du moteur
(`apex-engine`) ou de l'interface (`apex-ui`). Le numéro courant est dans [`VERSION`](VERSION).
Format et règles : [`integration/RULES.md`](integration/RULES.md), §9.

Une ligne par version, la plus récente en haut :
`<version> — <date> — <dépôt> @ <commit> — <ce qui change>`

- `alpha-0.2.3.1.4.0.0.221` — 2026-11-04 — apex-engine + apex-ui — contrat moteur 3 : les défauts de buse d'Element Aeolis (10° / 2 mm) sont gardés et changent le G-code (R-027) ; libellé « Angle maximum buse-paroi » ; échéances par jalons (RULES §11.3). Moteur et interface à fusionner dans cet ordre.
- `alpha-0.2.3.1.3.17.0.221` — 2026-11-04 — apex-engine @ 9599cc0 — R-030 : prototypes (14 `prototype_local_retriangulation*.py`) et anciens modules archivés dans la branche `archives` du moteur, retirés de `main`.
- `alpha-0.2.3.1.3.16.0.221` — 2026-11-04 — apex-engine @ 61e23fe — R-029/R-030 : `scripts/check_limits.py` avec cliquet (dette de départ : 14 fichiers, 49 fonctions, 15 signatures), `out/` ignoré (608 Mo retirés de l'index), `out/oldmods/` supprimé. Le numéro le plus élevé s'applique (RULES §9.1).
- `alpha-0.2.3.1.3.15.0.221` — 2026-11-04 — apex-ui @ 02eb2ad — R-031 : rayon du plateau lu dans le profil d'imprimante (150 mm, décision de l'utilisateur).
- `alpha-0.2.3.1.3.14.0.221` — 2026-11-04 — apex-ui @ f48220a — R-031 : tests du client du noyau d'édition (vérifiés par mutation).
- `alpha-0.2.3.1.3.13.0.221` — 2026-11-04 — apex-ui @ b7eb9c0 — R-031 : `CLAUDE.md` ramené à 160 lignes, conception détaillée dans `docs/`.
- `alpha-0.2.3.1.3.12.0.221` — 2026-11-04 — apex-ui @ b7defa2 — CI : version de pnpm fixée (`packageManager`), dossier `slicer_engine/` exclu d'ESLint.
- `alpha-0.2.3.1.3.11.0.221` — 2026-11-03 — apex-ui @ 3e53dc2 — un seul gestionnaire de paquets côté interface : pnpm (`package-lock.json` supprimé).
- `alpha-0.2.3.1.3.10.0.221` — 2026-11-03 — apex-ui @ bfa2dcb — Qualité sans compromis (R-031) : contrôle des limites avec cliquet, CI, TypeScript strict, 9 fichiers ramenés sous 800 lignes (détail et étapes `.3.2` à `.3.10` : `RELEASES.md` d'apex-ui). Le numéro de l'interface, plus élevé, s'applique (RULES §9.1) ; il rattrape aussi les versions de l'interface du 2026-10-31 (`.3.1.0`) non reportées ici.
- `alpha-0.2.3.0.6.1.0.221` — 2026-11-01 — apex-engine @ e8cb91ed — Element Aeolis écrit le type de chaque ligne (`;TYPE:WALL-OUTER`, `WALL-INNER`, `FILL`, `SKIN`) pour colorer l'aperçu (R-028).
- `alpha-0.2.3.0.6.0.0.221` — 2026-10-31 — apex-engine @ 6f879069 — Element Aeolis tranche toute géométrie (moteur général par sections planaires déformées) ; réglages de buse « Angle de la buse » (10°) et « Longueur maximale atteignable par la buse » (2 mm), défauts très bas (R-027).
- `alpha-0.2.3.0.5.0.0.221` — 2026-10-30 — apex-engine @ 712ca806 — `main.py slice` appelle Element Aeolis (champ `algorithm`, racine `AeolisSliceParams` du schéma, refus `not_a_heightfield`) ; moteur de R-024 fait.
- `alpha-0.2.3.0.4.0.0.221` — 2026-10-30 — apex-engine @ b8aee165 — Element Aeolis : progression réelle par étape (6 étapes, `steps --algorithm element-aeolis`) et tranchage 3 à 5 fois plus rapide (R-026).
- `alpha-0.2.3.0.3.5.0.221` — 2026-10-29 — apex-engine @ a237fc12 — logos des Elements : coins arrondis (style Apex), Aequor = couches courbes sur un socle plan.
- `alpha-0.2.3.0.3.4.0.221` — 2026-10-29 — apex-engine @ 873cf230 — logos des quatre Elements redessinés dans le style du logo Apex.
- `alpha-0.2.3.0.3.3.0.221` — 2026-10-29 — apex-engine @ e38b7e5a — un dossier `element-xxxx/` par algorithme de tranchage (`element-ardor` = ancien `pipeline/`, `element-aeolis` = ancien `nonplanar/`, `element-aequor` et `element-arva` à venir), alias d'import `pipeline` et `nonplanar` conservés ; logos SVG des quatre Elements.
- `alpha-0.2.3.0.3.2.0.221` — 2026-10-29 — apex-engine @ 22829213 — famille de noms « Element » : Element Aeolis (non planaire), Element Aequor (hybride, à venir), Element Arva (planaire, à venir) ; `meta.algorithm_name` = `Element Aeolis`.
- `alpha-0.2.3.0.3.1.0.221` — 2026-10-29 — apex-engine @ bf929456 — le second algorithme de tranchage (non planaire, surface en hauteur) s'appelle **Aeolis** : `meta.algorithm_name`, `generator` = `Apex engine (Aeolis)`.
- `alpha-0.2.3.0.3.0.0.221` — 2026-10-29 — apex-engine @ 20d8c28c — signature Apex en première ligne des G-code (polaire et non planaire) et `meta.apex_version` dans le bloc chiffré ; prompt de la session interface (`integration/PROMPT_UX_reconnaitre_apex.md`, R-025).
- `alpha-0.2.3.0.2.2.0.221` — 2026-10-29 — apex-engine @ 96ef099f — bloc d'en-tête chiffré : `meta.machine` et `meta.kinematics_description` pour les deux transcripteurs (R-025).
- `alpha-0.2.3.0.2.1.1.221` — 2026-10-29 — apex-engine @ 7d319926 — tranchage non planaire : plus d'anneaux de parois aux frontières internes des couches (parois sur le seul contour de la pièce), angle du dessus uniforme.
- `alpha-0.2.3.0.2.1.0.221` — 2026-10-29 — apex-engine @ ddfc53ab — format `apex-kinematics/1` : `part_origin`, règle de rotation unique, validation, exemple CoreXY à plateau inclinable.
- `alpha-0.2.3.0.2.0.0.221` — 2026-10-29 — apex-engine @ 02049a64 — G-code : les six axes XYZABC sur chaque mouvement (tous les tranchages) et description de la cinématique en tête (`apex-kinematics/1`, R-025).
- `alpha-0.2.3.0.1.0.0.221` — 2026-10-29 — apex-engine @ 94d6ec43 — tranchage non planaire : contrôle de collision de la vraie tête (enveloppe inférieure, rapport `head` et ligne `; head_collisions` dans le G-code).
- `alpha-0.2.3.0.0.0.0.221` — 2026-10-29 — apex-engine @ 720754f1 — second algorithme de tranchage : non planaire « surface en hauteur » (`nonplanar/`, v0, non exposé dans le contrat, R-024) ; plancher et plafond d'épaisseur de couche du profil (0,1 et 0,25 mm par défaut) et inter-couches locales activées par défaut.
- `alpha-0.2.2.0.3.0.0.221` — 2026-10-28 — apex-engine @ 4389a561 — lissage non-planaire sur la voie chaleur (`params.skin`, opt-in, désactivé par défaut) : zones accessibles, creusement du corps, trajectoires de surface, ordre et collisions ; mesuré de bout en bout sur l-triple, Benchy et death (turkish en cours).
- `alpha-0.2.2.0.2.1.0.221` — 2026-10-28 — apex-engine @ 62b4698b — étape 1 scindée en « import » et « tetrahedralization » (R-022, contrat C3, ajout compatible).
- `alpha-0.2.2.0.2.0.0.221` — 2026-10-27 — apex-engine @ 83bf565c — progression réelle à l'intérieur des étapes (R-017, contrat C3, ajout compatible).
- `alpha-0.2.2.0.1.0.0.221` — 2026-10-27 — apex-engine @ c66b57d4 — en-tête chiffré Apex et ligne de cinématique dans le G-code (R-007, R-010), vecteurs de cinématique (R-008), plusieurs pièces par défaut (R-013), tête de l'interface (R-009, R-020), diagnostic du refus de surface (R-016).
- `alpha-0.2.2.0.0.0.0.221` — 2026-10-27 — apex-engine @ 11a5e798 — voie unique de la chaleur (FEM et Bird retirés, contrat 2). **Niveau « majeur » à confirmer par l'utilisateur (R-019).**
- `alpha-0.2.1.4.3.11.1.221` — 2026-10-21 — apex-ui @ b57fb2b — version de départ, reprise de
  `apex-ui/RELEASES.md` (détail de l'historique antérieur dans ce fichier).
