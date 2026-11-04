# Références macOS Tahoe — Control Center et menus

Captures reçues de Yohan le 4 novembre 2026. Elles servent de références visuelles pour le nouvel objectif de reproduction. Les chemins et empreintes permettent de retrouver et vérifier les sources sans confondre ces captures avec des instructions.

## Control Center — « Modifier les commandes »

| Source | Dimensions | Empreinte SHA-256 | Contenu et éléments à reproduire |
| --- | ---: | --- | --- |
| `/mnt/windata/C/Users/Yohan/Images/image5.png` | 820 × 937 | `ec1a940159066c3a0e3377402a0309d2ca9e33dc07f2c4393e64f27613a32cb7` | Vue haute de l’éditeur : recherche, barre latérale de catégories, suggestions, sections Battery, Clock et Connectivity, contrôles glissables, pied de fenêtre fixe avec « Done ». |
| `/mnt/windata/C/Users/Yohan/Images/image6.png` | 482 × 902 | `c7f06b0e3129c1e78dbebfc79dc8068c49d85d15cb05dab33137c99060910599` | Vue défilée de l’éditeur : AirDrop/Bluetooth/Wi‑Fi, Desktop & Finder, Display & Brightness, Fast User Switching. Le bas et la droite sont recadrés : ne pas déduire de contenu invisible. |

Les catégories lisibles dans la capture haute sont : All Controls, Battery, Clock, Connectivity, Desktop & Finder, Display & Brightness, Fast User Switching, Focus, Home, Keyboards, Lock Screen, Microsoft Teams, Notes, Now Playing, Screenshot, Shortcuts, Sounds et Utilities. Garder cet ordre et permettre le défilement pour les catégories hors écran.

Les tuiles ont plusieurs formes : capsules Wi‑Fi/Bluetooth/AirDrop, boutons circulaires, tuiles larges avec état/curseur. Les contrôles doivent pouvoir être recherchés, glissés vers Control Center ou Menu Bar, puis validés avec « Done ». Le panneau d’édition est une grande surface vitrée unique avec barre latérale, deux zones défilantes, séparateur central, barres de défilement et pied fixe.

## Menus Wi‑Fi et Bluetooth

| Source | Dimensions | Empreinte SHA-256 | Contenu et éléments à reproduire |
| --- | ---: | --- | --- |
| `/mnt/windata/C/Users/Yohan/Images/image3.png` | 1919 × 1080 | `b3c4ef01b94eb04f7b7a786385720e86367133356587bb4cd5040a00cf8dc782` | Bureau complet et sous-menu Wi‑Fi ouvert en haut à droite. En-tête avec interrupteur, réseau connu SannWifi‑Freebox avec cadenas, rangée « Other Networks » avec chevron, lien « Wi‑Fi Settings… ». |
| `/mnt/windata/C/Users/Yohan/Images/image4.png` | 1920 × 1080 | `31ae8f0c012f7ed8976039f9021783d80b245e98e3ff2fcdc2b2c29efd09f829` | Bureau complet et sous-menu Bluetooth ouvert au même emplacement. En-tête avec interrupteur, appareils BV5300 Pro, Fresh ’n Rebel 3ATW3001R, MUSIC SOUND FLOW et MX Master, puis « Bluetooth Settings… ». L’état atténué de MX Master est à conserver comme exemple visuel d’appareil indisponible. |

Les deux menus sont des panneaux étroits, séparés du Control Center, placés près de l’icône de barre de menus correspondante. Réutiliser les informations de NetworkManager et BlueZ existantes ; afficher les vrais noms/états et un état indisponible clair au lieu de données inventées.

## État hover du contrôle Wi‑Fi

| Source | Dimensions | Empreinte SHA-256 | Contenu et éléments à reproduire |
| --- | ---: | --- | --- |
| [`wifi-hover-chevron.png`](reference-assets/macos-tahoe-control-center/wifi-hover-chevron.png) (copie conservée de la capture fournie) | 101 × 67 | `56ae543d0d5ba04d90bcd576a48a042c520589a02b4211207464517389917ec6` | Capsule Wi‑Fi survolée : fond de capsule éclairci, petit chevron pointant à droite visible à l’extrémité. Le chevron ouvre le sous-menu Wi‑Fi. |

Le survol doit éclaircir la capsule sans changer sa taille, son texte ou son alignement. Le même retour doit fonctionner au focus clavier ; l’ouverture reste possible au clic/Entrée.

## Menu contextuel du bureau

| Source | Dimensions | Empreinte SHA-256 | Contenu et éléments à reproduire |
| --- | ---: | --- | --- |
| `/mnt/windata/C/Users/Yohan/Images/image2.png` | 1920 × 1080 | `fb5f60acde10cb194c2f3a82e0e574d1e2e33ab07cb0e8725c360b4edaefb0a1` | Bureau avec widgets, Dock et menu contextuel ouvert au centre. Lignes : New Folder, Get Info, Change Wallpaper…, Edit Widgets…, Use Stacks, Sort By ›, Clean Up, Clean Up By ›, Show View Options. Conserver séparateurs, colonne d’icônes, chevrons et surbrillance. |

Cette dernière référence relève de `macos-tahoe-liquid-kde`, tandis que l’éditeur et les sous-menus réseau relèvent de `macos-tahoe-contro-center-kde`. La capture est une référence de rendu et de contenu ; chaque entrée doit garder une action KDE correspondante.

## Provenance et usage

- Les cinq captures originales restent dans le dossier utilisateur `Images`; seules leurs empreintes, chemins et descriptions sont catalogués ici.
- La petite capture de survol reçue dans `/tmp` a été copiée dans `docs/reference-assets/macos-tahoe-control-center/wifi-hover-chevron.png` pour préserver le détail de la flèche.
- Ces captures servent de références de travail. Ne pas les intégrer comme illustrations produit ou captures publiques du thème sans décision distincte de Yohan.
- Les images montrent des détails variables du bureau (fond, widgets, applications et date/heure). Utiliser les menus et contrôles décrits ci-dessus comme critères pertinents; ne pas recopier ces détails personnels dans les interfaces.
