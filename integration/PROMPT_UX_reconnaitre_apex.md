# Prompt pour la session « UX Manager » (apex-ui) : reconnaître un G-code Apex et lire son en-tête

Destinataire : la session qui développe `apex-ui`. À donner telle quelle. Demande liée : R-025
(`integration/REQUESTS.md`). Écrit par la session moteur (apex-engine), le 2026-10-29.

---

## Contexte

Le moteur Apex écrit maintenant, dans TOUS ses G-code (polaire 4 axes et non planaire cartésien) :

1. **en première ligne, une signature en clair qui ne signifie rien** :
   `; 85Ejj-sV6dI-NXTGl-JiodA-0b8aZ`
2. les six axes `X Y Z A B C` sur chaque mouvement (A et C valent toujours 0 aujourd'hui ; B vaut 0
   en cartésien) ;
3. quelques lignes de commentaire en clair (`; kinematics …`, `; apex_kinematics_json {…}`) ;
4. le **bloc d'en-tête chiffré** (`; apex_block_begin v1` … `; apex_block_end`, format
   `slicer-ux/docs/APEX_HEADER_FORMAT.md`, que ton `apexHeader.ts` lit déjà) qui contient `meta`.

**Le problème actuel** : l'aperçu classe un fichier d'après les mots qu'il contient. Tout fichier avec un
mot `C` est traité comme « multi-axes à orientation d'outil » (`gcodeParse.ts`, lignes ~409-410 et
~662-663 : `B = -90` = outil vertical, inclinaison = `B + 90`). Résultat : un G-code Apex cartésien
avec `B0.000 C0.000` s'affiche à B = 90°, et un G-code polaire Apex (qui porte aussi `C0`) n'est plus
reconnu polaire. De plus `readApexHeader` s'exécute APRÈS `parseGCode` (`use-gcode-preview.ts`, ~ligne 279),
donc trop tard pour classer le fichier.

## Ce que tu dois faire

### 1. Reconnaître Apex par la signature

- Dans les 40 premières lignes, chercher la ligne EXACTE `; 85Ejj-sV6dI-NXTGl-JiodA-0b8aZ` (retirer un
  éventuel `\r` final). Constante partagée : définis-la UNE fois côté interface (par exemple
  `src/utils/apexSignature.ts`), avec un commentaire qui renvoie à `file_io/apex_signature.py` du moteur.
- Absente : le fichier n'est pas d'Apex (ou vient d'une version antérieure) → comportement actuel,
  heuristiques comprises, sans changement.
- C'est un repère, pas une protection : ne jamais le présenter comme une sécurité.

### 2. Lire et déchiffrer l'en-tête AVANT de classer

- Signature trouvée : localiser le bloc (`; apex_block_begin v1` … `; apex_block_end`, dans l'en-tête, avant
  le premier mouvement `G0`/`G1`), le déchiffrer avec `apexCipher.ts` (via `readApexHeader`), analyser le JSON.
- **Réordonner** : cette lecture doit se faire avant `parseGCode`, qui reçoit un indice
  (`hint: { machine?: string }` ou équivalent) et ne retombe sur les heuristiques B/C que s'il n'y en a pas.

### 3. Recueillir les informations (`meta`)

Champs écrits par le moteur dans `payload.meta` (tous facultatifs côté lecture : ignorer ce qui manque,
tolérer des champs inconnus) :

| Champ | Type | Sens |
|---|---|---|
| `generator` | texte | `"Apex engine"` (polaire) ou `"Apex engine (Element Aeolis)"` (algorithme non planaire ; famille « Element », décision du 2026-10-29) |
| `apex_version` | texte | version de l'application, ex. `alpha-0.2.3.0.3.0.0.221` (`unknown` si le moteur ne la connaît pas) |
| `contract` | entier | numéro de contrat moteur ↔ interface (aujourd'hui 2) |
| `machine` | texte | `"cartesian"` ou `"apex-polar-4axis"` ; **c'est la clé de classement** |
| `kinematics_description` | objet | description `apex-kinematics/1` : axes `X Y Z A B C`, type (`linear`, `rotary`, `unused`), côté (`tool`, `bed`), vecteur, plage, sens positif, décalage outil, `part_origin`, conventions. Spécification : `apex-engine/file_io/kinematics_description.py` |
| `algorithm`, `algorithm_name` | texte | non planaire seulement : `"nonplanar-heightfield/1"` et `"Element Aeolis"` (nom à afficher ; futurs : « Element Aequor » hybride, « Element Arva » planaire) |
| `min_layer_height`, `max_layer_height`, `intermediate_layers` | nombres, booléen | non planaire : bornes d'épaisseur de couche du profil et option d'inter-couches |
| `kinematics` | objet | polaire : `pivot_to_tip`, `b_sign`, `tilt_sign`, `z_reference` |
| `layer_height`, `line_width`, `print_speed`, `travel_speed`, `nozzle_temp` | nombres | polaire : réglages d'écriture |

Le payload porte aussi `sliced` (booléen, vrai pour tout fichier du moteur) et, écrit par toi, `journal`.

### 4. Règles de classement

1. `meta.machine === "cartesian"` → cartésien. Les mots A, B, C (axes `unused`, toujours 0) sont IGNORÉS :
   B = 0 est une tête verticale, jamais « orientation d'outil ».
2. `meta.machine === "apex-polar-4axis"` → polaire (X = R, Y = angle du plateau, B = tête), même si le fichier
   porte des mots A et C à 0.
3. `machine` inconnue (version plus récente du moteur) → heuristiques actuelles + un avertissement visible.
4. Signature présente mais bloc absent ou illisible (paquet `cryptography` manquant côté moteur, fichier
   modifié, déchiffrement qui échoue) → ne pas planter : lire la ligne en clair
   `; apex_kinematics_json {…}` si elle est là (même objet que `kinematics_description`, champ `machine`),
   sinon heuristiques ; afficher « en-tête Apex illisible ».
5. Un mot `A`, `B` ou `C` à 0 d'un axe déclaré `unused` ne classe JAMAIS un fichier.

### 5. Afficher

Dans le panneau d'informations du fichier (`GCodeInfoPanel.tsx`) : « Tranché par Apex `<apex_version>` »,
générateur, algorithme, machine, contrat. Avertir si `contract` est supérieur à celui que l'interface
connaît, ou si `apex_version` est plus récente que l'interface. Ne rien inventer quand un champ manque.

### 6. Recette

Génère deux exemples (dossier au choix, dans le dépôt moteur) :

```bash
python scripts/gen_header_samples.py /tmp/apex_samples
```

- `sample_apex_nonplanar_cartesian.gcode` → doit s'afficher cartésien, B = 0°, version et machine lues.
- `sample_apex_polar_4axis.gcode` → doit s'afficher polaire (même avec `A0` et `C0`).
- Un G-code d'Orca ou de Prusa (sans signature) → inchangé.
- Le même exemple avec la première ligne supprimée → retombe sur les heuristiques, sans erreur.
- Le même exemple avec le bloc tronqué → « en-tête illisible », repli sur la ligne en clair, sans erreur.

Écris des tests unitaires pour ces cinq cas (parseur seul, sans interface).

## Ce que tu ne dois pas faire

- Ne modifie pas le moteur ni `apex` (sauf `integration/REQUESTS.md` pour répondre à R-025 et le numéro de
  version, RULES §2). Un besoin côté moteur devient une demande.
- Ne change pas le format du bloc chiffré ni `apexCipher.ts` (vecteurs : `docs/apex_cipher_vectors.json`).
- Ne déduis pas la machine de la présence d'un mot B ou C quand la signature et le bloc sont là.

## Rendu

Mets à jour R-025 (état, ce qui est fait côté interface), monte le numéro de version selon RULES §9
(`apex/VERSION`, `VERSIONS.md`, `apexVersion`), et dis combien de tests ont été ajoutés.
