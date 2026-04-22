# OctoMesh Construction Kit - Quick Reference

## Dateistruktur-Templates

### 1. ckModel.yaml Template
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-meta.schema.json
modelId: [YourModelName]-1.0.0   # modelId enthält per Konvention die Version
dependencies:
  - Basic-[2.0,3.0)              # offene Versionsbereiche in NuGet-Notation
  - System-[2.0,3.0)             # System wird durch Basic transitiv mitgeladen
  # weitere bei Bedarf
```

> Eine Abhängigkeit auf `Basic` zieht `System` automatisch mit; `System` muss
> nicht explizit aufgeführt werden. Die Liste oben zeigt nur, dass beide
> Bereichsangaben gültig sind.

### 2. Type Definition Template
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
types:
  - typeId: [TypeName]
    derivedFromCkTypeId: ${Basic}/NamedEntity  # or ${System}/Entity
    isAbstract: false
    description: "Type description"
    attributes:
      - id: ${this}/[AttributeName]
        name: [DisplayName]
        isOptional: true
        autoIncrementReference: "[SequenceName]"
      - id: ${Basic}/[ReusedAttribute]
        name: [DisplayName]
    associations:
      - id: ${this}/[AssociationName]      # verweist auf einen associationRole
        targetCkTypeId: ${this}/[TargetType]
```

> Hinweis: Die Multiplizität (Kardinalität) wird ausschließlich am `associationRole`
> definiert (siehe Punkt 5), nicht an der Association innerhalb des Types.

### 3. Attribute Definition Template
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
attributes:
  - id: [AttributeName]
    valueType: String  # siehe Liste unter "Value Types Reference"
    valueCkEnumId: ${this}/[EnumName]      # bei valueType Enum
    valueCkRecordId: ${this}/[RecordName]  # bei valueType Record
    description: "Attribute description"
    defaultValues:
      - [value]
    metaData:
      - key: Unit
        value: "EUR"
      - key: MinValue
        value: "0"
      - key: MaxValue
        value: "100"
```

> Für Mehrfachwerte gibt es kein `isMultiValue`-Flag, sondern eigene
> Array-`valueType`-Werte: `StringArray`, `IntArray`, `RecordArray`.

### 4. Enum Definition Template
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
enums:
  - enumId: [EnumName]
    description: "Enum description"
    values:
      - key: 0
        name: [Value1]
        description: "Value description"
      - key: 1
        name: [Value2]
        description: "Value description"
```

### 5. Association Definition Template
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
associationRoles:
  - id: [AssociationName]
    description: "Association description"
    inboundName: [PluralName]      # z.B. "Tasks"
    inboundMultiplicity: N         # N/One/ZeroOrOne
    outboundName: [SingularName]   # z.B. "Project"
    outboundMultiplicity: One      # N/One/ZeroOrOne
```

> Hinweis: Die einzigen erlaubten Multiplizitäten sind `One`, `ZeroOrOne` und `N`.
> `Many` oder `ZeroOrMany` existieren im Schema nicht.

### 6. Record Definition Template
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
records:
  - recordId: [RecordName]
    description: "Record description"
    attributes:
      - id: ${this}/[AttributeName]
        name: [DisplayName]
        isOptional: false
      - id: ${Basic}/[BasicAttribute]
        name: [DisplayName]
```

> Für Wörterbuch- bzw. Listen-ähnliche Strukturen wird das Attribut mit einem
> Array-`valueType` definiert (z.B. `RecordArray`); ein `KeyValuePair`-Typ
> existiert nicht im System CK Modell.

## Commonly Used Basic Types & Attributes

### Basic Types to Inherit From:
- `${Basic}/NamedEntity` - abstrakt; bringt `Name` (Pflicht) und `Description` (optional) mit
- `${Basic}/Document` - abstrakt; Basis für Dokumente, mit `DocumentNumber` und `DocumentDate`
- `${Basic}/Employee` - Mitarbeiter mit `FirstName`, `LastName`, `EmployeeId`, `EmployeeExternalId`
- `${Basic}/Tree` / `${Basic}/TreeNode` - für hierarchische Strukturen
- `${Basic}/Asset` - leitet von `TreeNode` ab; für Assets/Ressourcen
- `${System}/Entity` - abstrakte Basis aller Entitäten

### Basic Attributes to Reuse:

#### Time-Related:
- `${Basic}/From` - Startzeitpunkt (DateTime)
- `${Basic}/To` - Endzeitpunkt (DateTime)
- `${Basic}/Time` - einzelner Zeitpunkt (DateTime)
- `${Basic}/TimeRange` - Record bestehend aus `From` und `To`

#### Contact-Related:
- `${Basic}/Contact` - Record mit kompletten Kontaktdaten
- `${Basic}/FirstName`, `${Basic}/LastName` - Vor-/Nachname
- `${Basic}/CompanyName` - Firmenname
- `${Basic}/EMailAddress` - E-Mail-Adresse (Attribut); Record-Pendant: `${Basic}/EMail`
- `${Basic}/TelephoneNumber` - Telefonnummer (Attribut); Record-Pendants: `${Basic}/PhoneNumber`, `${Basic}/FaxNumber`
- `${Basic}/Address` - Adress-Record

#### General:
- `${Basic}/Comment` - für Notizen/Kommentare
- `${Basic}/File` - für Dateianhänge (BinaryLinked)
- `${Basic}/Temperature`, `${Basic}/MinTemperature`, `${Basic}/MaxTemperature`, `${Basic}/AvgTemperature`
- `${Basic}/Quantity`, `${Basic}/Amount` - Mengen-/Betrags-Records
- `${System}/Name` - Pflicht-Name (String)
- `${System}/DisplayName` - Anzeigename (String)
- `${System}/Description` - Beschreibung (String)
- `${System}/Enabled` - Aktivierungs-Flag (Boolean)

## Value Types Reference

Erlaubte Werte für `valueType` (Enum im Schema, exakte Schreibweise):

### Primitive Typen:
- `String` - Text
- `Boolean` - true/false
- `Int` - 32-Bit Ganzzahl (NICHT `Integer`)
- `Int64` - 64-Bit Ganzzahl
- `Double` - Fließkommazahl (es gibt keinen `Decimal`-Typ)
- `DateTime` - Datum und Uhrzeit
- `DateTimeOffset` - Datum/Uhrzeit mit Zeitzonen-Offset
- `TimeSpan` - Zeitdauer
- `Binary` - Binärdaten (inline)
- `BinaryLinked` - Referenz auf eine binäre Datei (z.B. Anhang)
- `GeospatialPoint` - Geokoordinate

### Komplexe Typen:
- `Enum` - Enumeration (erfordert `valueCkEnumId`)
- `Record` - Strukturierter Wert (erfordert `valueCkRecordId`)

### Array-Typen (anstelle eines `isMultiValue`-Flags):
- `StringArray` - Liste von Strings
- `IntArray` - Liste von Int-Werten
- `RecordArray` - Liste von Records (erfordert `valueCkRecordId`)

## Multiplicity (Association Roles)

Multiplizitäten werden ausschließlich an `associationRoles` gesetzt – nicht
an einer Association innerhalb eines Types. Erlaubte Werte:

- `One` - genau eins (Pflicht)
- `ZeroOrOne` - null oder eins (optional)
- `N` - beliebig viele (0..n)

## Common Patterns

### Parent-Child Relationship:
```yaml
# Vordefinierter associationRole im System-Modell
associations:
  - id: ${System}/ParentChild
    targetCkTypeId: ${this}/ParentType
```

### Self-Referencing (z.B. Dependencies):
```yaml
# associationRoles/Dependencies.yaml
associationRoles:
  - id: Dependencies
    inboundName: DependsOn
    inboundMultiplicity: N
    outboundName: Predecessors
    outboundMultiplicity: N

# In types/Task.yaml
associations:
  - id: ${this}/Dependencies
    targetCkTypeId: ${this}/Task
```

### Many-to-Many:
```yaml
# In associationRoles file:
- id: ProjectTeam
  inboundName: TeamMembers
  inboundMultiplicity: N
  outboundName: Projects
  outboundMultiplicity: N
```

### Auto-Increment Field:
```yaml
attributes:
  - id: ${this}/DocumentNumber
    name: DocumentNumber
    autoIncrementReference: "DocumentNumber"
```

## File Naming Conventions

- Types: `[TypeName].yaml` (e.g., `Project.yaml`)
- Attributes: `[Category]Attributes.yaml` (e.g., `ProjectAttributes.yaml`)
- Enums: `[Category]Enums.yaml` (e.g., `ProjectEnums.yaml`)
- Associations: `[Category]Associations.yaml` (e.g., `ProjectAssociations.yaml`)
- Records: `[Category]Records.yaml` (e.g., `ProjectRecords.yaml`)

## Validation Checklist

Before deployment:
- [ ] All files start with `$schema` declaration
- [ ] No circular dependencies
- [ ] All referenced types/attributes/enums exist
- [ ] Dependencies in ckModel.yaml are complete
- [ ] All required fields have values
- [ ] Descriptions provided for all elements
- [ ] MetaData added for numeric fields
- [ ] Default values set where appropriate
- [ ] Cardinalities correctly specified
- [ ] Basic types used where possible