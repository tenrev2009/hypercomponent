# HyperComponents
HyperComponents est un runtime de composants paramétriques pour SketchUp, conçu pour dépasser les limitations des Composants Dynamiques natifs. Il offre un moteur de résolution performant, une gestion des données robuste et une architecture extensible basée sur des comportements (Behaviors).

🚀 Fonctionnalités Clés
Stockage de Données Optimisé : Les données des composants sont sérialisées en JSON, compressées (Zlib) et encodées en Base64 dans des AttributeDictionaries (smart_component), garantissant intégrité et performance.

Moteur d'Expressions Sécurisé : Un parseur et évaluateur d'expressions mathématiques et logiques personnalisé (AST), évitant l'utilisation dangereuse de eval() Ruby.

Résolveur de Contraintes : Système de résolution incrémental avec détection de cycles et tri topologique des dépendances.

Système de Comportements (Behaviors) : Architecture modulaire permettant d'attacher des logiques spécifiques (SmartSize, Transform, Materials, etc.) aux composants.

Moteur de Règles (Rules Engine) : Logique "When/Then" pour l'automatisation et les contraintes de validation.

📂 Architecture du Projet
Le projet est structuré de manière modulaire :

Plaintext

hypercomponents/
├── behaviors/          # Logique métier (Builtins : SmartSize, Transform, etc.)
├── core/               # Cycle de vie, Observateurs, Transactions
├── data/               # Couche d'accès aux données (Storage v2, Schema, Intégrité)
├── diagnostics/        # Logging, Benchmarking, SafeMode
├── expressions/        # Tokenizer, Parser, Evaluateur, Cache de compilation
├── geometry/           # Moteurs géométriques (SmartSizeEngine, etc.)
├── interop/            # Import/Export (BOM, Cutlist, JSON)
├── library/            # Presets et templates de règles
├── manufacturing/      # (Phase 4) Opérations d'usinage
├── params/             # Gestion des types de paramètres et unités
├── rules/              # Moteurs de contraintes et d'automatisation
├── solver/             # Résolution du graphe de dépendances
├── tools/              # Outils SketchUp (Manipulator, Debug)
└── ui/                 # Interface HtmlDialog et pont JS/Ruby
🛠 Installation et Démarrage
Copiez le dossier hypercomponents et le fichier hypercomponents.rb dans votre dossier Plugins SketchUp.

Lancez SketchUp. L'extension se charge automatiquement via HyperComponents::Core::Lifecycle.start.

Accédez au panneau via le menu : Plugins > HyperComponents: Panel.

🧩 Développement de Comportements (Behaviors)
HyperComponents utilise un système de registre pour étendre les fonctionnalités. Voici comment déclarer un nouveau comportement :

Ruby

module HyperComponents
  module Behaviors
    class MonComportement < Base
      ID = 'mon_comportement'

      def apply(instance, ctx)
        # Logique d'application
        settings = ctx[:behavior_settings]
        value_store = ctx[:value_store]
        
        # Manipulation de l'instance...
      end
    end
  end
end

# Enregistrement
HyperComponents::Behaviors::Registry.register(
  HyperComponents::Behaviors::MonComportement::ID,
  HyperComponents::Behaviors::MonComportement
)
📅 Roadmap et Phases
Le développement suit une progression par phases (visible dans les commentaires du code) :

Phase 1 (MVP) : Runtime Core, Stockage V1/V2, SmartSize basique, UI Inspector, Moteur d'expressions.

Phase 2 (UI & Tools) : Éditeurs visuels (Formules, Règles), Outils de manipulation, Comportement "Arrays", Style CSS complet.

Phase 3 (Interop & Audit) : Exports (BOM, Cutlist, ERP), Imports (CSV, Excel), Logs d'audit et tracking de révision.

Phase 4 (Manufacturing) : Modèle de pièces, opérations d'usinage (Perçage, Rainurage), Nesting.

⚠️ Notes Techniques
Sécurité : Le module Security::Sandbox et le SafeMode empêchent l'exécution de code arbitraire depuis les définitions de composants.

Unités : Le stockage interne se fait en unités natives (pouces) ou millimètres selon la configuration, géré par Params::Units.

Transactions : Toutes les modifications sont encapsulées via Core::Transactions.wrap pour garantir l'annulabilité (Undo).
