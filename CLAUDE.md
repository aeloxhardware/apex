# Apex — l'application complète

Ce dépôt combine le moteur (`aeloxhardware/apex-engine`) et l'interface
(`aeloxhardware/apex-ui`), copiés dans `slicer-engine/` et `slicer-ux/` à des commits
épinglés (`integration/sources.json`), et publie les releases de l'application.

**Ne jamais modifier `slicer-engine/` ni `slicer-ux/` ici** : ce sont des copies, refaites par
`integration/sync.sh`. Les changements se font dans le dépôt d'origine.

**Numéro de version** : `VERSION` (source de vérité) et `VERSIONS.md` (journal), mis à jour à
chaque changement de version du moteur comme de l'interface (`integration/RULES.md`, §9).

Toute session qui travaille sur l'un des trois dépôts lit d'abord :
- [`integration/RULES.md`](integration/RULES.md) : règles de développement séparé, contrat,
  releases ;
- [`integration/REQUESTS.md`](integration/REQUESTS.md) : demandes ouvertes entre dépôts.
- [`ROADMAP.md`](ROADMAP.md) : ce qui est prévu pour l'application complète.
