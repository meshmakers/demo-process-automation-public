# OctoMesh Construction Kit - Quick Reference

## File-structure Templates

### 1. ckModel.yaml Template
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-meta.schema.json
modelId: [YourModelName]-1.0.0   # by convention modelId includes the version
dependencies:
  - Basic-[2.0,3.0)              # open version ranges in NuGet notation
  - System-[2.0,3.0)             # System is loaded transitively via Basic
  # additional ones if needed
```

> A dependency on `Basic` automatically pulls in `System`; `System` does
> not have to be listed explicitly. The list above just shows that both
> range expressions are valid.

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
      - id: ${this}/[AssociationName]      # references an associationRole
        targetCkTypeId: ${this}/[TargetType]
```

> Note: Multiplicity (cardinality) is defined exclusively at the `associationRole`
> (see point 5), not on the association inside the type.

### 3. Attribute Definition Template
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
attributes:
  - id: [AttributeName]
    valueType: String  # see list under "Value Types Reference"
    valueCkEnumId: ${this}/[EnumName]      # for valueType Enum
    valueCkRecordId: ${this}/[RecordName]  # for valueType Record
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

> For multi-valued attributes there is no `isMultiValue` flag — instead
> there are dedicated array `valueType` values: `StringArray`, `IntArray`,
> `RecordArray`.

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
    inboundName: [PluralName]      # e.g. "Tasks"
    inboundMultiplicity: N         # N/One/ZeroOrOne
    outboundName: [SingularName]   # e.g. "Project"
    outboundMultiplicity: One      # N/One/ZeroOrOne
```

> Note: The only allowed multiplicities are `One`, `ZeroOrOne` and `N`.
> `Many` or `ZeroOrMany` do not exist in the schema.

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

> For dictionary- or list-like structures, the attribute is defined with
> an array `valueType` (e.g. `RecordArray`); a `KeyValuePair` type does not
> exist in the System CK model.

## Commonly Used Basic Types & Attributes

### Basic Types to Inherit From:
- `${Basic}/NamedEntity` - abstract; provides `Name` (mandatory) and `Description` (optional)
- `${Basic}/Document` - abstract; base for documents, with `DocumentNumber` and `DocumentDate`
- `${Basic}/Employee` - employee with `FirstName`, `LastName`, `EmployeeId`, `EmployeeExternalId`
- `${Basic}/Tree` / `${Basic}/TreeNode` - for hierarchical structures
- `${Basic}/Asset` - derives from `TreeNode`; for assets/resources
- `${System}/Entity` - abstract base of all entities

### Basic Attributes to Reuse:

#### Time-Related:
- `${Basic}/From` - start timestamp (DateTime)
- `${Basic}/To` - end timestamp (DateTime)
- `${Basic}/Time` - single timestamp (DateTime)
- `${Basic}/TimeRange` - record consisting of `From` and `To`

#### Contact-Related:
- `${Basic}/Contact` - record with full contact data
- `${Basic}/FirstName`, `${Basic}/LastName` - first/last name
- `${Basic}/CompanyName` - company name
- `${Basic}/EMailAddress` - email address (attribute); record counterpart: `${Basic}/EMail`
- `${Basic}/TelephoneNumber` - phone number (attribute); record counterparts: `${Basic}/PhoneNumber`, `${Basic}/FaxNumber`
- `${Basic}/Address` - address record

#### General:
- `${Basic}/Comment` - for notes/comments
- `${Basic}/File` - for file attachments (BinaryLinked)
- `${Basic}/Temperature`, `${Basic}/MinTemperature`, `${Basic}/MaxTemperature`, `${Basic}/AvgTemperature`
- `${Basic}/Quantity`, `${Basic}/Amount` - quantity/amount records
- `${System}/Name` - mandatory name (String)
- `${System}/DisplayName` - display name (String)
- `${System}/Description` - description (String)
- `${System}/Enabled` - enable flag (Boolean)

## Value Types Reference

Allowed values for `valueType` (enum in the schema, exact spelling):

### Primitive types:
- `String` - text
- `Boolean` - true/false
- `Int` - 32-bit integer (NOT `Integer`)
- `Int64` - 64-bit integer
- `Double` - floating point (there is no `Decimal` type)
- `DateTime` - date and time
- `DateTimeOffset` - date/time with timezone offset
- `TimeSpan` - duration
- `Binary` - binary data (inline)
- `BinaryLinked` - reference to a binary file (e.g. attachment)
- `GeospatialPoint` - geo coordinate

### Complex types:
- `Enum` - enumeration (requires `valueCkEnumId`)
- `Record` - structured value (requires `valueCkRecordId`)

### Array types (instead of an `isMultiValue` flag):
- `StringArray` - list of strings
- `IntArray` - list of Int values
- `RecordArray` - list of records (requires `valueCkRecordId`)

## Multiplicity (Association Roles)

Multiplicities are set exclusively on `associationRoles` — not on an
association inside a type. Allowed values:

- `One` - exactly one (mandatory)
- `ZeroOrOne` - zero or one (optional)
- `N` - any number (0..n)

## Common Patterns

### Parent-Child Relationship:
```yaml
# predefined associationRole in the System model
associations:
  - id: ${System}/ParentChild
    targetCkTypeId: ${this}/ParentType
```

### Self-Referencing (e.g. Dependencies):
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
