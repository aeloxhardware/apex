# Versions d'Apex

Journal de tous les changements de version de l'application, qu'ils viennent du moteur
(`apex-engine`) ou de l'interface (`apex-ui`). Le numéro courant est dans [`VERSION`](VERSION).
Format et règles : [`integration/RULES.md`](integration/RULES.md), §9.

Une ligne par version, la plus récente en haut :
`<version> — <date> — <dépôt> @ <commit> — <ce qui change>`

- `alpha-0.2.3.0.0.0.0.221` — 2026-10-29 — apex-engine @ 720754f1 — second algorithme de tranchage : non planaire « surface en hauteur » (`nonplanar/`, v0, non exposé dans le contrat, R-024) ; plancher et plafond d'épaisseur de couche du profil (0,1 et 0,25 mm par défaut) et inter-couches locales activées par défaut.
- `alpha-0.2.2.0.3.0.0.221` — 2026-10-28 — apex-engine @ 4389a561 — lissage non-planaire sur la voie chaleur (`params.skin`, opt-in, désactivé par défaut) : zones accessibles, creusement du corps, trajectoires de surface, ordre et collisions ; mesuré de bout en bout sur l-triple, Benchy et death (turkish en cours).
- `alpha-0.2.2.0.2.1.0.221` — 2026-10-28 — apex-engine @ 62b4698b — étape 1 scindée en « import » et « tetrahedralization » (R-022, contrat C3, ajout compatible).
- `alpha-0.2.2.0.2.0.0.221` — 2026-10-27 — apex-engine @ 83bf565c — progression réelle à l'intérieur des étapes (R-017, contrat C3, ajout compatible).
- `alpha-0.2.2.0.1.0.0.221` — 2026-10-27 — apex-engine @ c66b57d4 — en-tête chiffré Apex et ligne de cinématique dans le G-code (R-007, R-010), vecteurs de cinématique (R-008), plusieurs pièces par défaut (R-013), tête de l'interface (R-009, R-020), diagnostic du refus de surface (R-016).
- `alpha-0.2.2.0.0.0.0.221` — 2026-10-27 — apex-engine @ 11a5e798 — voie unique de la chaleur (FEM et Bird retirés, contrat 2). **Niveau « majeur » à confirmer par l'utilisateur (R-019).**
- `alpha-0.2.1.4.3.11.1.221` — 2026-10-21 — apex-ui @ b57fb2b — version de départ, reprise de
  `apex-ui/RELEASES.md` (détail de l'historique antérieur dans ce fichier).
