# Règles d'intégration : moteur ↔ interface

Ces règles permettent de développer le moteur et l'interface **séparément**, chacun dans sa
propre session Claude, et de les assembler **à la compilation** sans que l'un casse l'autre.
Elles s'appliquent à toute session qui travaille sur `apex-engine`, `apex-ui` ou `apex`.

Le fichier compagnon [`REQUESTS.md`](REQUESTS.md) est le tableau des demandes entre dépôts. Il
contient aussi l'inventaire des écarts constatés le 2026-10-25.

---

## 1. Les trois dépôts

| Dépôt | Rôle | Ce qu'on y développe |
|---|---|---|
| `apex-engine` | **le moteur** | Python (`pipeline/`, `core/`, `file_io/`, `main.py`) et noyau C++ (`cpp/`). Tranchage, export G-code, paramètres. |
| `apex-ui` | **l'expérience utilisateur** | React, Babylon.js, Electron, noyau natif d'édition (`native/`). |
| `apex` | **l'application complète** | Rien de nouveau : il combine le moteur et l'interface à des commits épinglés, les contrôle ensemble et publie les releases. Il porte aussi ces règles et le tableau des demandes. |

`apex` contient une **copie** des deux autres dépôts : `slicer-engine/` (`apex-engine`) et
`slicer-ux/` (`apex-ui`). La copie est faite par `integration/sync.sh` : fichiers suivis par
git, moins les sorties, artefacts de compilation et journaux de session listés dans
`integration/exclude-engine.txt` et `integration/exclude-ux.txt`. Les commits copiés sont
écrits dans `integration/sources.json` : c'est l'épingle (§4.3). **On ne modifie jamais un
fichier de `slicer-engine/` ou `slicer-ux/` dans `apex`** : la copie suivante l'effacerait.
Un changement se fait dans le dépôt d'origine, puis on relance la copie. Les releases de l'application (exe, dmg, msi, AppImage) se
construisent et se publient depuis `apex`, jamais depuis `apex-ui` ou `apex-engine`.

Le dépôt qui portait autrefois le nom `apex` a été renommé `apex-engine` : c'est le moteur.
GitHub redirigeait encore l'ancien nom vers lui le 2026-10-25, d'où une erreur d'attribution
(§2, point 6).

---

## 2. Une session, un dépôt

C'est la règle qui évite de saturer une seule session.

1. **Une session Claude écrit dans un seul dépôt.** Elle peut LIRE les deux autres, jamais y
   écrire, même pour « une ligne ». Précédents : une session interface a modifié
   `gcode_export.py` pendant qu'une session moteur lançait ses tests (limite #74 du moteur),
   et le marqueur `; apex_sliced = 1` a été ajouté au moteur depuis l'interface sans y être
   commité (décision D4 de l'interface).
2. **Un besoin dans l'autre dépôt devient une demande** dans `apex/integration/REQUESTS.md`
   (format en §8). La session de l'autre dépôt la traite à son prochain passage.
3. **Une session d'intégration** travaille dans `apex`. Elle relance la copie (`sync.sh`), lance
   les essais de bout en bout, construit et publie les releases. Elle ne développe aucune
   fonctionnalité. Quand un essai
   échoue, elle ouvre une demande au dépôt responsable au lieu de corriger elle-même.
4. **Ce qu'une session lit de l'autre côté** : seulement le contrat (§3) et les fichiers qu'il
   désigne. Elle ne charge pas le `CLAUDE.md` complet de l'autre dépôt : c'est ce qui sature.
5. **En début de session** : lire ce fichier, puis les demandes ouvertes adressées à son dépôt
   dans `REQUESTS.md`. **En fin de session** : mettre à jour l'état des demandes traitées, et
   ouvrir celles que la session a découvertes.

6. **Vérifier le dépôt avant d'écrire.** `git remote -v` et `git log` doivent désigner le
   dépôt attendu : un clone fait avant un renommage pousse ailleurs sans erreur. Le
   2026-10-25, deux commits destinés à `apex` sont partis dans `apex-engine` de cette façon.

---

## 3. Le contrat : ce qui traverse la frontière

Tout ce qui passe d'un dépôt à l'autre fait partie du contrat. Chaque élément a **un seul
producteur**, qui en est la source de vérité. Le consommateur ne le modifie jamais : il le
reçoit, généré ou copié par un outil.

| Id | Élément | Producteur (source de vérité) | Consommateur | État au 2026-10-25 |
|---|---|---|---|---|
| **C1** | Paramètres de tranchage et profil machine (`PipelineParams`, `GcodeParams`, dont `MachineProfile`) | moteur : dataclasses → `config/params.schema.json` et `cpp/include/apex/params.hpp` (`scripts/gen_params.py`) | interface : formulaires, types TypeScript | Schéma écrit et testé ; l'interface ne le lit pas encore. |
| **C2** | Appel du tranchage (requête, progression, résultat) | moteur : interface en ligne de commande (§5) | interface : `electron/` | N'existe pas. Le tranchage de l'interface est simulé (minuterie de `SlicingProgressModal.tsx`). |
| **C3** | Liste des étapes affichées pendant le tranchage | moteur (§5.3) | interface : `slicingSteps.ts` | La liste de l'interface est inventée ; elle décrit encore la voie Bird, retirée le 2026-10-25. |
| **C4** | Fichier G-code Apex : axes, cinématique pivot/pointe, signe de B, Y déroulé, commentaires de type de ligne, marqueur `; apex_sliced = 1` | moteur : `file_io/gcode_export.py` | interface : `gcodeParse.ts`, `gcodeWriter.ts`, noyau `native/` | Écrit par le moteur, lu et réécrit par l'interface. Cinématique implémentée trois fois (§6). |
| **C5** | Bloc d'en-tête chiffré (format, chiffrement, vecteurs de test) | interface : `docs/APEX_HEADER_FORMAT.md`, `docs/apex_cipher_vectors.json` | moteur : écrit la partie `meta` | Le moteur n'écrit pas encore le bloc. |
| **C6** | Modèle 3D de la tête (`aetheris-4.glb`) | moteur : `res/3d/toolheads/` | interface : `src/assets/models/` | Les deux copies **diffèrent** (empreintes SHA-256 différentes). |
| **C7** | Profils d'imprimantes | interface : `profiles/`, `docs/PRINTER_PROFILE_FORMAT.md` | moteur : `MachineProfile` | Aucun lien : les valeurs de la machine actuelle sont recopiées à la main (§6). |

Un nouvel élément partagé entre dans ce tableau **avant** d'être utilisé des deux côtés, avec
son producteur. S'il n'a pas de producteur évident, c'est une question pour l'utilisateur.

---

## 4. Comment les deux côtés se rejoignent à la compilation

### 4.1 Version du contrat

- Le contrat porte un **numéro entier**, `contract_version`. Le moteur l'écrit dans
  `config/params.schema.json` (clé `x-apex-contract`), par `scripts/gen_params.py`.
- **Changement compatible** (champ ajouté avec une valeur par défaut, nouvelle étape, nouvelle
  donnée facultative dans un résultat) : le numéro ne change pas.
- **Changement incompatible** (champ retiré, renommé, unité ou sens changé, valeur par défaut
  qui change le G-code produit, format de fichier modifié) : le producteur incrémente le numéro.
- L'interface déclare la version qu'elle sait lire (`APEX_CONTRACT_VERSION`, dans un seul
  fichier de `src/`). **La construction de l'interface échoue** si la version du contrat
  importé est différente. C'est le point où les deux côtés « communiquent à la compilation ».

### 4.2 Fichiers générés, copiés dans le consommateur

- Le consommateur **commite** une copie générée de ce qu'il consomme, pour se construire seul,
  sans l'autre dépôt sur la machine. Exemple côté interface : le schéma C1, les types
  TypeScript qui en sont générés, la liste des étapes C3, le GLB de la tête C6.
- Chaque fichier copié commence par l'origine : `Généré depuis apex-engine@<commit> — ne pas
  éditer.` (en commentaire, ou dans une clé `x-apex-source` pour du JSON).
- La copie se fait **par un script** du consommateur, jamais à la main. Il lit l'autre dépôt
  dans un dossier voisin (variable `APEX_ENGINE_DIR`, défaut `../apex-engine` ; idem
  `APEX_UI_DIR`). Le script a un mode `--check` qui échoue si la copie n'est plus à jour,
  sur le modèle de `gen_params.py --check`.
- **Un fichier généré ne s'édite jamais à la main.** Une erreur dedans se corrige chez le
  producteur.
- **Une constante de l'autre côté ne se recopie jamais à la main** (une limite de B, une longueur
  de pivot, un rayon de plateau). Si l'interface en a besoin, elle demande au producteur de
  l'ajouter au contrat (§8).

### 4.3 Épinglage et releases

- Les épingles sont les commits copiés, écrits par `sync.sh` dans `integration/sources.json`.
  Un commit d'`apex` qui les avance ne contient que la copie et ce fichier, et dit dans son
  message les deux commits et le numéro du contrat.
- Une release se construit **depuis `apex`**, à partir de `slicer-engine/` et `slicer-ux/`, et seulement si
  les contrôles du §7 passent. Elle porte la version de l'interface (`apexVersion`), et est
  étiquetée dans `apex` avec cette version (`git tag <apexVersion>`).
- `apex/RELEASES.md` donne, pour chaque release : la version, la date, le commit
  d'`apex-engine`, celui d'`apex-ui` et le numéro du contrat. L'historique des fonctions
  reste dans `apex-ui/RELEASES.md`.
- Les épingles n'avancent que si les deux côtés passent les contrôles avec le même numéro de
  contrat. Un côté peut être en avance sur l'autre en développement ; jamais dans une
  release.
- Le compteur « Builds » de la version Apex se remet à zéro à une version compilée rendue
  publique : c'est désormais une release d'`apex`.

---

## 5. Protocole d'appel du tranchage (C2, C3)

C'est la cible : les deux côtés peuvent le développer chacun de leur côté dès maintenant. Les
détails (noms exacts des champs) sont fixés par le moteur, qui les publie dans le schéma.

### 5.1 Processus séparé, fichiers échangés

- L'interface lance le moteur dans un **sous-processus**, comme `electron/python-runner.cjs`
  le fait déjà pour la conversion polaire. Le moteur n'est jamais lié dans Electron. Cela
  isole les plantages natifs (TetGen) et garde le moteur et l'interface comme des programmes
  distincts (voir la décision de licence, limite #56 du moteur).
- Les échanges passent par des **fichiers** et des **lignes de texte**, jamais par de la
  mémoire partagée.
- Commande : `<moteur> slice --request <requete.json>`. `<moteur>` est aujourd'hui
  `python main.py` ; plus tard un exécutable natif. L'interface ne dépend que de la commande,
  pas de ce qui l'exécute.

### 5.2 Requête et résultat

- `requete.json` : numéro du contrat, chemin(s) du maillage, `PipelineParams` et `GcodeParams`
  sérialisés selon le schéma C1, dossier de sortie. **Un champ inconnu est une erreur**, comme
  dans `config/schema.py` : une faute de frappe côté interface ne passe jamais en silence.
- Le moteur écrit le G-code sous un nom temporaire puis le renomme à la fin : un G-code présent
  est toujours complet.
- **Dernière ligne de la sortie standard** : un objet JSON de résultat (statut, chemin du
  G-code, rapport d'export, diagnostics comptés, `placement_offset_z`, avertissements).
- **Codes de sortie** : `0` réussi ; `2` requête invalide (version, champ inconnu, valeur hors
  bornes) ; `3` modèle refusé (trop grand, irréparable) ; tout autre code = plantage. Un
  refus porte un message lisible par l'utilisateur.

### 5.3 Progression et étapes

- Le moteur écrit sa progression sur la **sortie d'erreur**, une ligne JSON par événement :
  `{"type": "step", "slug": "...", "fraction": 0.42}`, `{"type": "log", "level": "...",
  "message": "..."}`. Les autres lignes de la sortie d'erreur sont des journaux libres.
- `<moteur> steps` rend la liste des étapes (`slug`, libellé) du chemin par défaut. C'est C3 :
  l'interface l'affiche, elle n'invente pas d'étape.
- Annuler = arrêter le processus. Le moteur ne laisse alors aucun G-code incomplet.

### 5.4 Unités et repères

Millimètres, degrés, secondes. Plateau à z = 0, Z vers le haut. B dans la convention d'Apex
(B = 0 tête vers le bas, jamais négatif). Toute autre unité est un changement incompatible.

---

## 6. Les calculs faits des deux côtés

Certaines choses sont calculées dans les deux dépôts parce que l'interface en a besoin en temps
réel : la cinématique pivot/pointe (moteur `gcode_export.py`, interface `gcodeParse.ts`
`nozzleTip`, noyau `native/` `update_point_geometry`), les limites de B, les épaisseurs de couche.

1. Le producteur publie, pour chaque calcul partagé, des **vecteurs de test** (entrées et
   sorties attendues, en JSON) dans son dépôt, à côté du code de référence. Exemple : quelques
   points (R, C, Z, B) → (X, Y, Z, B) firmware, avec la longueur pivot-pointe et le signe de B.
2. Chaque implémentation de l'autre côté a un test qui rejoue ces vecteurs, sur le modèle du
   chiffrement (`apex_cipher_vectors.json`, partagé entre le moteur et l'interface).
3. Une **valeur** partagée (pivot de 46 mm, B de 0 à 185°, 1666,7 °/s, plateau de 150 mm de
   rayon) passe par le contrat (C1, et C4 pour ce que le G-code doit porter), jamais par une
   constante recopiée. En particulier, la longueur pivot-pointe est réglable côté moteur
   (`config/pivot_to_tip.json`) : l'interface doit la lire dans le G-code, pas la supposer.
4. Changer une convention (signe de B, référence de Z) se fait dans le producteur, avec
   nouveaux vecteurs et incrément du contrat, puis dans le consommateur. Jamais l'inverse.
5. Les deux noyaux C++ (`apex-engine/cpp`, `apex-ui/native`) ne s'échangent pas de code par
   copier-coller. Si un même calcul natif doit servir aux deux, il devient un en-tête public
   du moteur, copié dans l'interface par le script du §4.2 et reconnu par ses vecteurs.

---

## 7. Contrôles

**Dans chaque dépôt, à chaque session qui touche le contrat :**

- moteur : `pytest` dans les deux positions de `APEX_USE_CPP`, `scripts/gen_params.py --check`,
  et les vecteurs de test qu'il publie ;
- interface : `pnpm lint`, `pnpm build` (qui vérifie la version du contrat, §4.1), le
  `--check` du script de copie, et le rejeu des vecteurs du moteur.

**Dans `apex`, avant de relancer la copie ou de publier une release** (session
d'intégration) :

1. le schéma copié dans l'interface est celui du commit moteur épinglé ;
2. un tranchage réel par le protocole du §5, sur les quatre modèles de référence du moteur ;
3. le G-code produit est relu par le parseur de l'interface, et les positions de la pointe
   relues concordent avec celles du moteur (tolérance déclarée) ;
4. l'en-tête chiffré écrit par le moteur se déchiffre avec le code de l'interface.

Un contrôle sauté ou impossible est dit dans le compte rendu, jamais passé sous silence.

---

## 8. Demandes entre dépôts

Une demande s'écrit dans `REQUESTS.md`, une entrée par besoin :

```
### R-NNN — titre court
- De : apex-ui | À : apex-engine | Contrat : C1 | Ouverte : AAAA-MM-JJ
- Besoin : ce qui manque, et pourquoi.
- Constat : fichiers et faits vérifiés (chemins, chiffres).
- État : ouverte | acceptée | faite (commit) | refusée (raison) | question à l'utilisateur
```

- Une demande dit un **besoin**, pas un correctif à recopier : le dépôt qui la reçoit choisit
  comment la satisfaire.
- Elle n'est « faite » qu'avec le commit qui la satisfait, des deux côtés si le consommateur
  doit suivre.
- Une décision qui revient à l'utilisateur (choix de producteur, suppression de code, format)
  porte l'état « question à l'utilisateur » ; aucune session ne la tranche seule.
- Les demandes faites restent dans le fichier (historique) ; elles descendent dans la section
  « Fermées ».

---

## 9. Commits et versions

- Chaque dépôt garde ses conventions : versionnage `apexVersion` et `RELEASES.md` dans
  l'interface, DT et limites numérotées dans le moteur.
- Un commit qui change un élément du contrat le dit dans son message : `[contrat C1] …`, et,
  s'il est incompatible, `[contrat C1, v<N>]`.
- Le moteur tient le journal des changements du contrat (numéro, date, élément, ce qui change
  pour le consommateur) dans un `CONTRACT_CHANGES.md` à sa racine.
- Une release porte la version de l'interface ; `apex/RELEASES.md` dit quel moteur et quelle
  interface elle contient (§4.3).

---

## 10. Ce que ces règles ne changent pas

Les règles propres à chaque dépôt restent en vigueur : mesurer avant de conclure, ne jamais
activer par défaut un mécanisme non mesuré sur les quatre modèles, ne jamais compiler en
`/fp:fast` (moteur) ; un seul curseur `ApexSlider`, les infobulles, l'interface classique
(interface). Ces règles-ci ne règlent que la frontière.
