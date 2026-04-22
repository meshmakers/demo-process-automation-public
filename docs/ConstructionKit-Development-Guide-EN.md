# OctoMesh Construction Kit - Development Guide

## Overview
This document captures the knowledge for creating OctoMesh Construction Kits, based on analysis of existing implementations and the development of the ProjectManagement Construction Kit.

## 1. Basic structure of a Construction Kit

### Directory structure
```
ConstructionKit/
├── ckModel.yaml           # model metadata and dependencies
├── types/                 # entity type definitions
│   └── *.yaml
├── attributes/            # attribute definitions
│   └── *.yaml
├── enums/                # enumeration definitions  
│   └── *.yaml
├── associations/         # association definitions
│   └── *.yaml
├── records/              # record (complex types) definitions
│   └── *.yaml
└── AI/                   # optional: AI agent implementations
    └── *.cs
```

## 2. Schema definitions

### 2.1 ckModel.yaml
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-meta.schema.json
modelId: [ModelName]-1.0.0          # by convention modelId includes the version
dependencies:
  - Basic-[2.0,3.0)                 # NuGet version range; transitively pulls in System
  # - additional dependencies as needed
```

### 2.2 Types (Entities)
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
types:
  - typeId: [TypeName]
    derivedFromCkTypeId: ${Basic}/NamedEntity   # or ${System}/Entity
    isAbstract: false                           # true for abstract base classes
    description: "Entity description"
    attributes:
      - id: ${this}/[AttributeName]             # own attributes
        name: [DisplayName]
        isOptional: true                        # optional, default: false
        autoIncrementReference: "[SequenceName]" # for auto IDs
      - id: ${Basic}/[BasicAttribute]           # reuse from Basic
        name: [DisplayName]
    associations:
      - id: ${this}/[AssociationName]           # references an associationRole
        targetCkTypeId: ${this}/[TargetType]
      - id: ${System}/ParentChild               # predefined hierarchical relationship
        targetCkTypeId: ${this}/[ParentType]
```

> Note: There is no `cardinality` field on an association inside a type.
> Multiplicity is defined exclusively at the referenced `associationRole`
> (see 2.5).

### 2.3 Attributes
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
attributes:
  - id: [AttributeName]
    valueType: String                          # see list of allowed values below
    valueCkEnumId: ${this}/[EnumName]          # only for valueType Enum
    valueCkRecordId: ${this}/[RecordName]      # only for valueType Record / RecordArray
    description: "Attribute description"
    defaultValues:
      - [DefaultValue]
    metaData:
      - key: Unit
        value: "EUR/h"                         # unit
      - key: MinValue
        value: "0"
      - key: MaxValue
        value: "100"
      - key: semanticId
        value: "0173-1#02-AAO127#003"          # industry standards
```

**Allowed `valueType` values** (enum in the schema, exact spelling):

`String`, `Boolean`, `Int`, `Int64`, `Double`, `DateTime`, `DateTimeOffset`,
`TimeSpan`, `Binary`, `BinaryLinked`, `GeospatialPoint`, `Enum`, `Record`,
`StringArray`, `IntArray`, `RecordArray`.

> There is no `Integer`, no `Decimal` and no `Guid`. For multi-valued
> attributes there is no `isMultiValue` flag — instead the array variants
> (`StringArray`, `IntArray`, `RecordArray`) are used.

### 2.4 Enums
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
enums:
  - enumId: [EnumName]
    description: "Enum description"
    values:
      - key: 0  # numeric key
        name: [ValueName]
        description: "Value description"
      - key: 1
        name: [NextValue]
        # ...
```

### 2.5 Associations
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
associationRoles:
  - id: [AssociationName]
    description: "Relationship description"
    inboundName: [PluralName]      # e.g. "Tasks"
    inboundMultiplicity: N         # allowed: One, ZeroOrOne, N
    outboundName: [SingularName]   # e.g. "Project"
    outboundMultiplicity: One      # allowed: One, ZeroOrOne, N
```

> There are only three multiplicities: `One`, `ZeroOrOne`, `N`. `Many` and
> `ZeroOrMany` are not valid values.

### 2.6 Records (Complex Data Types)
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
records:
  - recordId: [RecordName]
    description: "Record description"
    attributes:
      - id: ${this}/[AttributeName]
        name: [DisplayName]
        isOptional: true            # optional, default: false
      - id: ${Basic}/[BasicAttribute]
        name: [DisplayName]
```

> For lists of records inside a record, use an attribute with
> `valueType: RecordArray` and `valueCkRecordId`. There is no `KeyValuePair`
> type in the System CK model.

## 3. Best Practices

### 3.1 Use of Basic types
**Always check whether Basic types can be used:**

#### Frequently used Basic types:
- `${Basic}/NamedEntity` — abstract; Name + Description
- `${Basic}/Document` — abstract; base for documents (DocumentNumber, DocumentDate)
- `${Basic}/Employee` — employee (FirstName, LastName, EmployeeId, EmployeeExternalId)
- `${Basic}/Asset` — asset/resource (derives from TreeNode)
- `${Basic}/Tree`, `${Basic}/TreeNode` — hierarchies

#### Frequently used Basic Attributes/Records:
- `${Basic}/From`, `${Basic}/To` — start/end timestamp (attribute, DateTime)
- `${Basic}/TimeRange` — record consisting of From/To
- `${Basic}/Time` — single timestamp (attribute, DateTime)
- `${Basic}/Comment` — comment/note
- `${Basic}/Contact` — contact data record
- `${Basic}/Address` — address record
- `${Basic}/File` — file attachment (BinaryLinked)
- `${Basic}/CompanyName` — company name
- `${Basic}/EMailAddress` — email address (attribute); record counterpart: `${Basic}/EMail`
- `${Basic}/TelephoneNumber` — phone number (attribute); record counterpart: `${Basic}/PhoneNumber`

### 3.2 Naming conventions

#### TypeIds:
- PascalCase: `ProjectDocument`, `Employee`
- No prefixes or suffixes

#### Attributes:
- PascalCase for IDs: `ProjectCode`, `TaskStatus`
- camelCase for names in types: `name: projectCode`

#### Enums:
- PascalCase for EnumIds: `ProjectStatus`, `TaskPriority`
- PascalCase for enum values: `InProgress`, `OnHold`

#### Associations:
- Descriptive names: `ProjectTasks`, `TaskAssignee`
- Plural for collections: `Tasks`, `TeamMembers`
- Singular for single relationships: `Manager`, `Client`

### 3.3 Inheritance hierarchy

```
${System}/Entity (abstract base of all entities)
    ├── ${Basic}/NamedEntity (abstract; Name + Description)
    │   ├── Project
    │   ├── Task
    │   ├── Sprint
    │   └── Risk
    ├── ${Basic}/Document (abstract; DocumentNumber + DocumentDate)
    │   └── ProjectDocument
    └── Employee (own type, directly from ${System}/Entity)
```

### 3.4 Association patterns

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

#### Self-Referencing (e.g. Task Dependencies):
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

### 3.5 AI Integration

#### AI fields in entities:
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
      - key: AIGenerated     # own convention for marking AI-generated fields
        value: "true"
```

#### AI agent integration:
- AI agents as separate C# classes in the AI/ directory
- Use the Mesh API for data access
- Write computed values back into AI fields

## 4. Development Process

### Step 1: Analyze the requirements
- Which entities are needed?
- Which relationships exist?
- Which attributes are required?

### Step 2: Check existing Basic components
```bash
# Analyze Basic ConstructionKit
ls /octo-construction-kit/src/ConstructionKits/Octo.Sdk.Packages.Basic/ConstructionKit/
```

### Step 3: Model definition
1. Create `ckModel.yaml` with dependencies
2. Create the directory structure

### Step 4: Type definitions
1. Define abstract base types (if necessary)
2. Create concrete types with inheritance
3. Reuse Basic types where possible

### Step 5: Attribute definitions
1. Define project-specific attributes
2. MetaData for units and value ranges
3. Enums for status values

### Step 6: Associations
1. Define relationships between types
2. Specify cardinalities
3. Assign bidirectional names

### Step 7: Records for complex data types
1. Identify reusable structures
2. Define records with their own attributes

### Step 8: Validation
```yaml
# every YAML file must start with $schema
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
```

## 5. Common Errors and Solutions

### Error 1: Circular dependencies
**Problem**: Type A references Type B, Type B references Type A
**Solution**: Define one direction as an association

### Error 2: Missing Basic dependencies
**Problem**: Basic attributes used without Basic in dependencies
**Solution**: Add it in ckModel.yaml with version range:
```yaml
dependencies:
  - Basic-[2.0,3.0)
```

### Error 3: Duplicate attributes
**Problem**: The same attributes in multiple types
**Solution**: Define as a shared attribute and reuse it

### Error 4: Wrong multiplicities
**Problem**: `Many` or `ZeroOrMany` used on an `associationRole`
**Solution**: Only `One`, `ZeroOrOne` and `N` are allowed. Inside a type
there is no `cardinality` field — multiplicity lives only on the `associationRole`.

## 6. Testing and Deployment

### Local validation:
```bash
# Check YAML syntax (optional, generic)
yamllint ConstructionKit/

# Full schema validation and compilation happen during the .NET build:
dotnet build -c DebugL
```

During the build, all CK YAML files are validated against the JSON schemas
and translated by the ConstructionKit compiler into a compiled CK library
(`bin/.../octo-ck-libraries/<Project>/out/ck-<name>.yaml`).

### Deployment:
```bash
# Preparation: context and login
octo-cli -c UseContext -n <name>
octo-cli -c LogIn -i

# Import the compiled CK YAML into the current tenant (wait with -w)
octo-cli -c ImportCk -f ./bin/DebugL/net10.0/octo-ck-libraries/<Project>/out/ck-<name>.yaml -w
```

## 7. Example Implementation

The complete ProjectManagement ConstructionKit demonstrates:
- Inheritance from Basic types
- Use of Basic attributes
- Complex associations (M:N, self-references)
- AI integration with computed fields
- Records for structured data
- Proper use of MetaData

Path: `/demo-process-automation/src/ProcessAutomationDemo/ConstructionKit/`

## 8. Further Resources

- OctoMesh documentation: https://docs.meshmakers.cloud
- Schema definitions: https://schemas.meshmakers.cloud/
- Basic ConstructionKit: `/octo-construction-kit/src/ConstructionKits/Octo.Sdk.Packages.Basic/`
- Energy Community example: `/octo-construction-kit/src/ConstructionKits/Octo.Sdk.Packages.EnergyCommunity/`

## 9. Checklist for new Construction Kits

- [ ] ckModel.yaml with correct dependencies
- [ ] All types derive from Basic/System
- [ ] Use Basic attributes where possible
- [ ] Enums for all status fields
- [ ] Associations defined bidirectionally
- [ ] Records for complex structures
- [ ] MetaData for numeric values
- [ ] Descriptions for all elements
- [ ] YAML schema in every file
- [ ] No circular dependencies
- [ ] AI fields marked and documented
- [ ] README.md with usage examples
