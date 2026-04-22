# OctoMesh Construction Kit - Entwicklungshandbuch

## Übersicht
Dieses Dokument dokumentiert das Wissen zur Erstellung von OctoMesh Construction Kits basierend auf der Analyse der bestehenden Implementierungen und der Entwicklung des ProjectManagement Construction Kits.

## 1. Grundstruktur eines Construction Kits

### Verzeichnisstruktur
```
ConstructionKit/
├── ckModel.yaml           # Model-Metadaten und Dependencies
├── types/                 # Entity-Type Definitionen
│   └── *.yaml
├── attributes/            # Attribut-Definitionen
│   └── *.yaml
├── enums/                # Enumeration-Definitionen  
│   └── *.yaml
├── associations/         # Association-Definitionen
│   └── *.yaml
├── records/              # Record (komplexe Typen) Definitionen
│   └── *.yaml
└── AI/                   # Optional: AI-Agent Implementierungen
    └── *.cs
```

## 2. Schema-Definitionen

### 2.1 ckModel.yaml
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-meta.schema.json
modelId: [ModelName]-1.0.0          # modelId enthält per Konvention die Version
dependencies:
  - Basic-[2.0,3.0)                 # NuGet-Versionsbereich; zieht System transitiv mit
  # - weitere Dependencies nach Bedarf
```

### 2.2 Types (Entitäten)
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
types:
  - typeId: [TypeName]
    derivedFromCkTypeId: ${Basic}/NamedEntity   # oder ${System}/Entity
    isAbstract: false                           # true für abstrakte Basisklassen
    description: "Beschreibung der Entität"
    attributes:
      - id: ${this}/[AttributeName]             # Eigene Attribute
        name: [DisplayName]
        isOptional: true                        # optional, default: false
        autoIncrementReference: "[SequenceName]" # Für Auto-IDs
      - id: ${Basic}/[BasicAttribute]           # Wiederverwendung aus Basic
        name: [DisplayName]
    associations:
      - id: ${this}/[AssociationName]           # verweist auf einen associationRole
        targetCkTypeId: ${this}/[TargetType]
      - id: ${System}/ParentChild               # Vordefinierte hierarchische Beziehung
        targetCkTypeId: ${this}/[ParentType]
```

> Hinweis: An einer Association innerhalb eines Types gibt es kein
> `cardinality`-Feld. Die Multiplizität wird ausschließlich am referenzierten
> `associationRole` definiert (siehe 2.5).

### 2.3 Attributes
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
attributes:
  - id: [AttributeName]
    valueType: String                          # siehe Liste der erlaubten Werte unten
    valueCkEnumId: ${this}/[EnumName]          # nur bei valueType Enum
    valueCkRecordId: ${this}/[RecordName]      # nur bei valueType Record / RecordArray
    description: "Attribut-Beschreibung"
    defaultValues:
      - [DefaultValue]
    metaData:
      - key: Unit
        value: "EUR/h"                         # Einheit
      - key: MinValue
        value: "0"
      - key: MaxValue
        value: "100"
      - key: semanticId
        value: "0173-1#02-AAO127#003"          # Industrie-Standards
```

**Erlaubte `valueType`-Werte** (Enum im Schema, exakte Schreibweise):

`String`, `Boolean`, `Int`, `Int64`, `Double`, `DateTime`, `DateTimeOffset`,
`TimeSpan`, `Binary`, `BinaryLinked`, `GeospatialPoint`, `Enum`, `Record`,
`StringArray`, `IntArray`, `RecordArray`.

> Es gibt weder `Integer` noch `Decimal` noch `Guid`. Für Mehrfachwerte
> existiert kein `isMultiValue`-Flag — stattdessen werden die Array-Varianten
> (`StringArray`, `IntArray`, `RecordArray`) verwendet.

### 2.4 Enums
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
enums:
  - enumId: [EnumName]
    description: "Enum-Beschreibung"
    values:
      - key: 0  # Numerischer Schlüssel
        name: [ValueName]
        description: "Wert-Beschreibung"
      - key: 1
        name: [NextValue]
        # ...
```

### 2.5 Associations
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
associationRoles:
  - id: [AssociationName]
    description: "Beziehungsbeschreibung"
    inboundName: [PluralName]      # z.B. "Tasks"
    inboundMultiplicity: N         # erlaubt: One, ZeroOrOne, N
    outboundName: [SingularName]   # z.B. "Project"
    outboundMultiplicity: One      # erlaubt: One, ZeroOrOne, N
```

> Es gibt nur drei Multiplizitäten: `One`, `ZeroOrOne`, `N`. `Many` und
> `ZeroOrMany` sind keine gültigen Werte.

### 2.6 Records (Komplexe Datentypen)
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
records:
  - recordId: [RecordName]
    description: "Record-Beschreibung"
    attributes:
      - id: ${this}/[AttributeName]
        name: [DisplayName]
        isOptional: true            # optional, default: false
      - id: ${Basic}/[BasicAttribute]
        name: [DisplayName]
```

> Für Listen von Records innerhalb eines Records nutzen Sie ein Attribut mit
> `valueType: RecordArray` und `valueCkRecordId`. Einen `KeyValuePair`-Typ
> gibt es im System CK Modell nicht.

## 3. Best Practices

### 3.1 Verwendung von Basic-Typen
**Immer prüfen ob Basic-Typen verwendet werden können:**

#### Häufig verwendete Basic-Types:
- `${Basic}/NamedEntity` — abstrakt; Name + Description
- `${Basic}/Document` — abstrakt; Basis für Dokumente (DocumentNumber, DocumentDate)
- `${Basic}/Employee` — Mitarbeiter (FirstName, LastName, EmployeeId, EmployeeExternalId)
- `${Basic}/Asset` — Asset/Ressource (leitet von TreeNode ab)
- `${Basic}/Tree`, `${Basic}/TreeNode` — Hierarchien

#### Häufig verwendete Basic-Attributes/Records:
- `${Basic}/From`, `${Basic}/To` — Start-/Endzeitpunkt (Attribut, DateTime)
- `${Basic}/TimeRange` — Record bestehend aus From/To
- `${Basic}/Time` — einzelner Zeitpunkt (Attribut, DateTime)
- `${Basic}/Comment` — Kommentar/Notiz
- `${Basic}/Contact` — Kontaktdaten-Record
- `${Basic}/Address` — Adress-Record
- `${Basic}/File` — Dateianhang (BinaryLinked)
- `${Basic}/CompanyName` — Firmenname
- `${Basic}/EMailAddress` — E-Mail-Adresse (Attribut); Record-Pendant: `${Basic}/EMail`
- `${Basic}/TelephoneNumber` — Telefonnummer (Attribut); Record-Pendant: `${Basic}/PhoneNumber`

### 3.2 Namenskonventionen

#### TypeIds:
- PascalCase: `ProjectDocument`, `Employee`
- Keine Präfixe oder Suffixe

#### Attribute:
- PascalCase für IDs: `ProjectCode`, `TaskStatus`
- camelCase für names in types: `name: projectCode`

#### Enums:
- PascalCase für EnumIds: `ProjectStatus`, `TaskPriority`
- PascalCase für Enum-Values: `InProgress`, `OnHold`

#### Associations:
- Beschreibende Namen: `ProjectTasks`, `TaskAssignee`
- Plural für Collections: `Tasks`, `TeamMembers`
- Singular für Einzelbeziehungen: `Manager`, `Client`

### 3.3 Vererbungshierarchie

```
${System}/Entity (abstrakte Basis aller Entitäten)
    ├── ${Basic}/NamedEntity (abstrakt; Name + Description)
    │   ├── Project
    │   ├── Task
    │   ├── Sprint
    │   └── Risk
    ├── ${Basic}/Document (abstrakt; DocumentNumber + DocumentDate)
    │   └── ProjectDocument
    └── Employee (eigener Typ direkt von ${System}/Entity)
```

### 3.4 Association-Patterns

#### One-to-Many (Parent-Child):
```yaml
associations:
  - id: ${System}/ParentChild
    targetCkTypeId: ${this}/ParentType
```

#### Many-to-Many:
```yaml
associationRoles:
  - id: ProjectTeam
    inboundName: TeamMembers
    inboundMultiplicity: N
    outboundName: AssignedProjects
    outboundMultiplicity: N
```

#### Self-Referencing (z.B. Task Dependencies):
```yaml
# associationRoles/TaskDependencies.yaml
associationRoles:
  - id: TaskDependencies
    inboundName: DependsOn
    inboundMultiplicity: N
    outboundName: Predecessors
    outboundMultiplicity: N

# In types/Task.yaml
associations:
  - id: ${this}/TaskDependencies
    targetCkTypeId: ${this}/Task
```

### 3.5 AI-Integration

#### AI-Felder in Entities:
```yaml
attributes:
  - id: RiskScore
    valueType: Double
    description: "AI-calculated risk score (0-100)"
    metaData:
      - key: Unit
        value: "%"
      - key: MinValue
        value: "0"
      - key: MaxValue
        value: "100"
      - key: AIGenerated     # Eigene Konvention zur Markierung KI-generierter Felder
        value: "true"
```

#### AI-Agent Integration:
- AI-Agents als separate C#-Klassen im AI/ Verzeichnis
- Nutzen die Mesh-API für Datenzugriff
- Schreiben berechnete Werte zurück in AI-Felder

## 4. Entwicklungsprozess

### Schritt 1: Analyse der Anforderungen
- Welche Entities werden benötigt?
- Welche Beziehungen existieren?
- Welche Attribute sind erforderlich?

### Schritt 2: Prüfung vorhandener Basic-Komponenten
```bash
# Basic ConstructionKit analysieren
ls /octo-construction-kit/src/ConstructionKits/Octo.Sdk.Packages.Basic/ConstructionKit/
```

### Schritt 3: Model-Definition
1. `ckModel.yaml` erstellen mit Dependencies
2. Verzeichnisstruktur anlegen

### Schritt 4: Type-Definitionen
1. Abstrakte Basistypen definieren (falls nötig)
2. Konkrete Types mit Vererbung erstellen
3. Basic-Types wiederverwenden wo möglich

### Schritt 5: Attribute-Definitionen
1. Projekt-spezifische Attribute definieren
2. MetaData für Einheiten und Wertebereiche
3. Enums für Status-Werte

### Schritt 6: Associations
1. Beziehungen zwischen Types definieren
2. Kardinalitäten festlegen
3. Bidirektionale Namen vergeben

### Schritt 7: Records für komplexe Datentypen
1. Wiederverwendbare Strukturen identifizieren
2. Records mit eigenen Attributen definieren

### Schritt 8: Validierung
```yaml
# Jede YAML-Datei muss mit $schema beginnen
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
```

## 5. Häufige Fehler und Lösungen

### Fehler 1: Zirkuläre Dependencies
**Problem**: Type A referenziert Type B, Type B referenziert Type A
**Lösung**: Eine Richtung als Association definieren

### Fehler 2: Fehlende Basic-Dependencies
**Problem**: Basic-Attribute verwendet ohne Basic in Dependencies
**Lösung**: In ckModel.yaml mit Versionsbereich hinzufügen:
```yaml
dependencies:
  - Basic-[2.0,3.0)
```

### Fehler 3: Doppelte Attribute
**Problem**: Gleiche Attribute in mehreren Types
**Lösung**: Als gemeinsames Attribut definieren und wiederverwenden

### Fehler 4: Falsche Multiplizitäten
**Problem**: `Many` oder `ZeroOrMany` an einem `associationRole` verwendet
**Lösung**: Erlaubt sind nur `One`, `ZeroOrOne` und `N`. Innerhalb eines Types
gibt es kein `cardinality`-Feld – die Multiplizität lebt allein am `associationRole`.

## 6. Testing und Deployment

### Lokale Validierung:
```bash
# YAML-Syntax prüfen (optional, generisch)
yamllint ConstructionKit/

# Vollständige Schema-Validierung und Kompilierung erfolgen beim .NET-Build:
dotnet build -c DebugL
```

Beim Build werden alle CK-YAML-Dateien gegen die JSON-Schemas validiert und
durch den ConstructionKit-Compiler in eine kompilierte CK-Bibliothek
(`bin/.../octo-ck-libraries/<Project>/out/ck-<name>.yaml`) übersetzt.

### Deployment:
```bash
# Vorbereitung: Kontext und Login
octo-cli -c UseContext -n <name>
octo-cli -c LogIn -i

# Kompilierte CK-YAML in den aktuellen Tenant importieren (mit -w warten)
octo-cli -c ImportCk -f ./bin/DebugL/net10.0/octo-ck-libraries/<Project>/out/ck-<name>.yaml -w
```

## 7. Beispiel-Implementierung

Das vollständige ProjectManagement ConstructionKit zeigt:
- Vererbung von Basic-Types
- Verwendung von Basic-Attributes
- Komplexe Associations (M:N, Self-References)
- AI-Integration mit berechneten Feldern
- Records für strukturierte Daten
- Proper use of MetaData

Pfad: `/demo-process-automation/src/ProcessAutomationDemo/ConstructionKit/`

## 8. Weiterführende Ressourcen

- OctoMesh Dokumentation: https://docs.meshmakers.cloud
- Schema-Definitionen: https://schemas.meshmakers.cloud/
- Basic ConstructionKit: `/octo-construction-kit/src/ConstructionKits/Octo.Sdk.Packages.Basic/`
- Energy Community Beispiel: `/octo-construction-kit/src/ConstructionKits/Octo.Sdk.Packages.EnergyCommunity/`

## 9. Checkliste für neue Construction Kits

- [ ] ckModel.yaml mit korrekten Dependencies
- [ ] Alle Types von Basic/System ableiten
- [ ] Basic-Attributes wo möglich verwenden
- [ ] Enums für alle Status-Felder
- [ ] Associations bidirektional definiert
- [ ] Records für komplexe Strukturen
- [ ] MetaData für numerische Werte
- [ ] Beschreibungen für alle Elemente
- [ ] YAML-Schema in jeder Datei
- [ ] Keine zirkulären Dependencies
- [ ] AI-Felder markiert und dokumentiert
- [ ] README.md mit Verwendungsbeispielen