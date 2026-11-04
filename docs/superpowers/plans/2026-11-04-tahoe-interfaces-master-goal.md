# Interfaces macOS Tahoe — plan maître de réalisation

> **Pour l’exécution :** suivre les sous-plans dédiés indiqués plus bas, lot par lot, avec vérification isolée et checkpoint ciblé après validation.

**Goal :** terminer rapidement une reproduction KDE convaincante et fonctionnelle des interfaces Tahoe documentées ici, sans viser un calque pixel par pixel.

**Architecture :** l’application autonome Control Center porte l’éditeur, les capsules indépendantes et les popovers réseau. Le dépôt du thème porte le menu contextuel natif du bureau. Les références sont centralisées dans une carte commune ; chaque dépôt garde son plan technique et ses changements isolés.

**Tech stack :** Qt 6 / Qt Quick QML, C++17, NetworkManager, BlueZ, Plasma/KWin et composants Kvantum déjà présents dans les dépôts.

## Contraintes globales

- L’objectif Codex est déjà actif ; ce document le rend vérifiable et centralise les références et plans associés.
- Protéger toutes les modifications locales préexistantes ; limiter chaque commit aux fichiers relus de son lot.
- Garder le bureau actif utilisable : pas de redémarrage ni reconfiguration globale KWin/Plasma pour les essais.
- Comparer aux captures listées dans la carte ; ne pas introduire de 1:1 comme critère de sortie.
- Aucun screenshot pré-calculé en arrière-plan du rendu de verre ; l’arrière-plan montré doit être le contenu de fenêtre réellement présent.

---

**État :** actif. Ce plan coordonne les sous-plans détaillés ci-dessous et les dépôts concernés.

## Résultat attendu

Le Control Center KDE doit présenter des surfaces de verre indépendantes, lisibles et cohérentes avec les références, ouvrir ses panneaux de détails près des icônes concernées et proposer un éditeur de commandes utilisable. Le menu contextuel du bureau KDE doit reprendre le langage visuel Tahoe tout en gardant les actions natives KDE. Les captures originales et les décisions de référence doivent rester retrouvables pendant tout le travail.

## Références faisant autorité

La carte complète, avec chemins, dimensions, SHA-256, descriptions et limites de cadrage, est [`../../macos-tahoe-reference-map.md`](../../macos-tahoe-reference-map.md). Elle catalogne les cinq captures originales et le crop de survol :

| Référence | Cible | Critères à conserver |
| --- | --- | --- |
| `image5.png` (820 × 937) | Éditeur, vue haute | Grande surface vitrée unique, recherche, catégories ordonnées, suggestions, tuiles de formes et tailles différentes, sections et pied fixe « Done ». |
| `image6.png` (482 × 902) | Éditeur, vue défilée | Connectivité, capsules AirDrop/Bluetooth/Wi‑Fi, Desktop & Finder, Display & Brightness, Fast User Switching. Ne rien inventer dans les zones recadrées. |
| `image3.png` (1919 × 1080) | Menu Wi‑Fi | Petit panneau autonome en haut à droite, interrupteur, réseau connu et verrou, « Other Networks » avec chevron, « Wi‑Fi Settings… ». |
| `image4.png` (1920 × 1080) | Menu Bluetooth | Même famille de panneau, interrupteur, vrais noms d’appareils, état indisponible atténué, « Bluetooth Settings… ». |
| `image2.png` (1920 × 1080) | Menu contextuel du bureau | Panneau flottant, lignes et séparateurs, icônes alignées, survol, chevrons des sous-menus et actions KDE correspondantes. Travail côté dépôt du thème. |
| `wifi-hover-chevron.png` (101 × 67) | Survol de capsule Wi‑Fi | Légère éclaircie au survol, petit chevron vers la droite visible seulement au survol/focus, contenu centré sans déplacement ni changement de géométrie. |

Les noms et valeurs SHA-256 sont ceux du registre : ne pas renommer, remplacer ou modifier les originaux. Recalculer les empreintes avant une comparaison de référence. Ne pas inclure les captures personnelles dans les illustrations publiques du produit.

## Portée et critères d’acceptation

### A. Fenêtre « Modifier les commandes » — dépôt Control Center

- Reproduire la hiérarchie et le contenu visibles dans les deux captures : rail de catégories, recherche, suggestions, sections, catalogue à tuiles rondes/capsules/format large, et bouton « Done » fixe.
- Garder les zones de catégories et de catalogue défilables indépendamment ; respecter l’ordre visible des catégories et ne pas déduire le contenu masqué par le recadrage.
- Permettre recherche, ajout par glisser-déposer vers Control Center ou Menu Bar, retrait et réordonnancement ; appliquer avec « Done » et restaurer l’agencement après redémarrage.
- Utiliser des icônes sous licence appropriée ou des SVG du projet ; conserver les notices et ne pas redistribuer les ressources Apple/SF Symbols.

### B. Control Center et détails réseau — dépôt Control Center

- Conserver le placement de conception et des capsules visuellement séparées, sans plaque d’arrière-plan commune.
- Garder le contenu réellement présent derrière le panneau visible à travers le verre. Aucun fond d’écran ni screenshot pré-calculé comme arrière-plan de réfraction ; ne pas activer l’effet Acrylic Glass derrière les surfaces si cela altère ce rendu.
- Utiliser un flou léger et progressif pour la lisibilité, avec transition douce hors des capsules ; la réfraction et les couleurs doivent suivre les fenêtres réellement visibles derrière, sans teinte rose ajoutée.
- Le survol/focus Wi‑Fi éclaire légèrement la capsule et révèle le petit chevron de la référence. La position des icônes, libellés et capsule ne bouge pas ; clic et Entrée ouvrent le panneau.
- Les popovers Wi‑Fi et Bluetooth sont des panneaux autonomes ancrés aux icônes. Utiliser NetworkManager et BlueZ pour les états réels ; signaler clairement les fonctions indisponibles plutôt que simuler des valeurs.
- Échap et clic extérieur ferment le popover. L’ouverture d’un autre ferme le précédent.

### C. Menu contextuel du bureau — dépôt du thème

- Modifier le vrai menu contextuel du bureau, pas celui du gestionnaire de tâches.
- Garder les actions et sous-menus KDE fonctionnels ; reprendre surface flottante, transparence, arrondis, espacements, colonne d’icônes, séparateurs, chevrons et retour visuel de survol de `image2.png`.
- Vérifier le rendu isolément avec un fond comparable, sans redémarrer ni reconfigurer la session Plasma utilisée.

## Étapes et points de contrôle

1. [ ] **Références** — conserver la carte et ses empreintes ; pour toute nouvelle capture, consigner source, dimensions, hash, détails visibles et limites du cadrage.
2. [ ] **Éditeur et interactions** — suivre [`2026-11-04-control-center-editor-and-menus.md`](2026-11-04-control-center-editor-and-menus.md) ; comparer vue haute, vue défilée, hover et focus en session isolée ; vérifier édition et persistance.
3. [ ] **Verre et menus réseau** — comparer aux références Wi‑Fi/Bluetooth ; vérifier états réels et indisponibles, ouverture/fermeture et rendu sur contenu live ; éviter les balayages longs de paramètres.
4. [ ] **Menu contextuel du bureau** — suivre [`2026-11-04-desktop-context-menu.md`](2026-11-04-desktop-context-menu.md) ; comparer repos, survol et sous-menu en session isolée.
5. [ ] **Vérification et checkpoints** — compiler les cibles utiles, contrôler les erreurs QML, produire une planche de comparaison concise, relire les diffs et statuts des deux dépôts. Faire un checkpoint ciblé après chaque lot validé. Aucune pull request avant la fin de l’objectif global.

## Garde-fous d’exécution

- Ne pas arrêter, redémarrer ou changer les paramètres globaux de KWin/Plasma pendant que Yohan utilise le PC. Préférer compilation, capture et interaction via Xvfb/session D-Bus isolée.
- Inspecter l’état Git avant chaque édition ; préserver tous les fichiers et modifications préexistants. Ne stage/committer que les fichiers relus et associés au lot validé.
- Ne pas appeler une inspection visuelle « validation live » si elle provient d’un rendu isolé. Décrire les écarts encore visibles avec les captures plutôt que prétendre au 1:1.
- Prioriser fonctionnement clair et ressemblance convaincante. Ne pas retarder le résultat pour des micro-ajustements imperceptibles.

## Plans techniques associés

- [`2026-11-04-control-center-editor-and-menus.md`](2026-11-04-control-center-editor-and-menus.md) — éditeur, persistance, hover et détails Wi‑Fi/Bluetooth.
- [`2026-11-04-desktop-context-menu.md`](2026-11-04-desktop-context-menu.md) — menu contextuel natif du bureau dans le dépôt du thème.
- [`../../macos-tahoe-reference-map.md`](../../macos-tahoe-reference-map.md) — registre source des captures.
