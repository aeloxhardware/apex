# Prompt pour la session « UX Manager » (apex-ui) : afficher « Généré par Apex Slicer V… »

Destinataire : la session qui développe `apex-ui`. À donner telle quelle. Complète
`integration/PROMPT_UX_reconnaitre_apex.md` (détection et lecture du bloc chiffré) et la demande R-025
(`integration/REQUESTS.md`). Écrit par la session moteur, le 2026-10-29.

---

## Ce que tu dois faire

Reprogramme l'aperçu pour que, quand un G-code porte la signature Apex, le panneau d'informations affiche
**« Généré par Apex Slicer V… »** avec le numéro de version exact, à la place de
**« Généré le plus probablement par : … (déduit du format) »**.

### 1. Détecter la signature

- Cherche, dans les 40 premières lignes, la ligne EXACTE `; 85Ejj-sV6dI-NXTGl-JiodA-0b8aZ` (retirer un `\r`
  final). Constante unique côté interface (par exemple `src/utils/apexSignature.ts`), commentaire renvoyant à
  `apex-engine/file_io/apex_signature.py`.
- Ce repère ne prouve rien (le dépôt est public) : ne jamais l'afficher comme une garantie d'authenticité.

### 2. Lire la version dans le bloc chiffré

- Signature trouvée : localise le bloc `; apex_block_begin v1` … `; apex_block_end`, déchiffre-le avec
  `readApexHeader` / `apexCipher.ts` (existants) et lis `payload.meta.apex_version`
  (ex. `alpha-0.2.3.0.3.0.0.221`).
- Format du numéro (`apex/integration/RULES.md`, §9.2) :
  `<préversion>-<public>.<global>.<majeur>.<moyen>.<mineur>.<add-ins>.<correctif>.<builds>`.
- La lecture doit se faire AVANT `parseGCode` quand elle sert au classement (voir le prompt de détection) ; ici
  elle sert à l'affichage et peut rester asynchrone, mais un seul déchiffrement par fichier.

### 3. Afficher

Dans `GCodeInfoPanel.tsx` (lignes ~46-51, étiquette `'Généré le plus probablement par'`), dans
`ClassicApp.tsx` (~ligne 245, ligne « Générateur ») et partout où `fileInfo.generator` est montré :

| Situation | Étiquette | Valeur |
|---|---|---|
| Signature + `apex_version` lue | **Généré par** | `Apex Slicer V0.2.3.0.3.0.0.221 (alpha)` : `V` + la partie numérique, puis la préversion entre parenthèses |
| Signature présente, bloc absent ou illisible | **Généré par** | `Apex Slicer (version illisible)` |
| Signature présente, `apex_version` = `unknown` ou absent | **Généré par** | `Apex Slicer (version inconnue)` |
| Pas de signature | inchangé (`Généré le plus probablement par`) | inchangé, y compris `Générateur Apex 4 axes (déduit du format)` pour un ancien fichier polaire |

Dans les trois premiers cas : jamais « le plus probablement », jamais « (déduit) » ; `inferred = false`. Une
préversion absente (`1.2.3…` sans `alpha-`) : afficher seulement `V` + les nombres. Ne pas raccourcir ni arrondir
les nombres, les afficher tels que le moteur les écrit.

### 4. Modèle de données

- Étends `GCodeGenerator` (`gcodeGenerator.ts`) : `{ name, inferred, apex?: { version?: string; prerelease?: string } }`.
  La mise en forme du texte est faite dans UNE fonction (par exemple `formatGeneratorLabel(generator)`), utilisée
  par les deux écrans, pour que le panneau et la vue classique ne divergent jamais.
- `gcodeParse.ts` (~lignes 870-873) : l'ordre de priorité devient signature Apex > signature d'un autre slicer >
  déduction par le format. Aujourd'hui `generator` vient du texte `signature` d'un autre slicer ; la signature Apex
  ne doit pas être prise pour ce texte.

### 5. Recette (tests unitaires, parseur seul)

Génère des exemples avec le moteur (`python scripts/gen_header_samples.py <dossier>`) :

1. `sample_apex_nonplanar_cartesian.gcode` → « Généré par Apex Slicer V<version lue> (alpha) ».
2. `sample_apex_polar_4axis.gcode` → idem.
3. Le même fichier, première ligne supprimée → ancien affichage (`Générateur Apex 4 axes (déduit du format)` pour le
   polaire ; pour le cartésien, la déduction habituelle ou « Inconnu »).
4. Signature conservée, bloc tronqué → « Généré par Apex Slicer (version illisible) », sans erreur.
5. Un G-code de PrusaSlicer ou d'Orca → inchangé.

Les tests couvrent aussi `formatGeneratorLabel` seul (préversion présente ou absente, version `unknown`).

## Ce que tu ne dois pas faire

- Ne modifie ni le moteur, ni `apex` (sauf `integration/REQUESTS.md` pour répondre à R-025, et le numéro de
  version, RULES §2 et §9). Un besoin côté moteur devient une demande.
- Ne change pas le format du bloc chiffré ni `apexCipher.ts` (vecteurs : `docs/apex_cipher_vectors.json`).
- Ne mets pas « Apex Slicer » devant un fichier qui n'a pas la signature, même s'il ressemble à du G-code d'Apex.

## Rendu

Mets à jour R-025 (état, ce qui est fait côté interface), monte le numéro de version (`apex/VERSION`,
`VERSIONS.md`, `apexVersion`), et dis combien de tests ont été ajoutés.
