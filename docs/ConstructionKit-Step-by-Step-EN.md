# Construction Kit Creation Process - Step by Step

## Context
This guide documents the exact process for creating an OctoMesh Construction Kit, based on the development of the ProjectManagement Construction Kit for an AI agent course.

## Prerequisites
- Access to Basic ConstructionKit: `/octo-construction-kit/src/ConstructionKits/Octo.Sdk.Packages.Basic/`
- Understanding of YAML syntax
- Knowledge of the domain (e.g. project management)

## Step-by-Step Instructions

### Phase 1: Preparation and Analysis

#### 1.1 Analyze the Basic ConstructionKit
```bash
# Understand the structure
ls octo-construction-kit/src/ConstructionKits/Octo.Sdk.Packages.Basic/ConstructionKit/

# Identify important Basic types
cat types/NamedEntity.yaml  # abstract base for named entities
cat types/Document.yaml     # abstract base for documents
cat types/Employee.yaml     # employee with FirstName/LastName/EmployeeId

# Find reusable attributes and records
cat attributes/Basics.yaml
cat attributes/Contact.yaml
cat records/TimeRange.yaml
cat records/Address.yaml
cat records/Contact.yaml
```

#### 1.2 Domain Analysis
Answer these questions:
- Which main entities exist? (e.g. Project, Task, Employee)
- Which relationships exist? (e.g. Project has Tasks)
- Which states/statuses exist? (e.g. TaskStatus: ToDo, InProgress, Done)
- Which AI fields are needed? (e.g. RiskScore, ComplexityScore)

### Phase 2: Create the Basic Structure

#### 2.1 Create the directory structure
```bash
mkdir -p ConstructionKit/{types,attributes,enums,associations,records}
```

#### 2.2 Model definition (ckModel.yaml)
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-meta.schema.json
modelId: ProjectManagement-1.0.0   # modelId includes the model version
dependencies:
  - Basic-[2.0,3.0)                # Basic transitively pulls in System
```

**Important**:
- By convention, `modelId` includes the version (`Name-Major.Minor.Patch`).
- Dependencies use NuGet version ranges (e.g. `[2.0,3.0)` = from 2.0, less than 3.0).
- `System` does not need to be specified explicitly when `Basic` is referenced.

### Phase 3: Define Enumerations

#### 3.1 Create status enums
File: `enums/ProjectEnums.yaml`
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
enums:
  - enumId: ProjectStatus
    description: "Project status values"
    values:
      - key: 0
        name: Planning
        description: "Project is in planning phase"
      - key: 1
        name: InProgress
        description: "Project is actively being worked on"
      # more...
```

**Important**: 
- Keys are numeric (0, 1, 2...)
- Names in PascalCase
- Descriptions are helpful for the UI

### Phase 4: Define Attributes

#### 4.1 Categorization
Split attributes into logical groups:
- ProjectAttributes.yaml
- TaskAttributes.yaml
- EmployeeAttributes.yaml
- CommonAttributes.yaml

#### 4.2 Attributes with MetaData
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
attributes:
  - id: Budget
    valueType: Double                # numeric monetary amounts
    description: "Total project budget"
    metaData:
      - key: Unit
        value: "EUR"
      - key: MinValue
        value: "0"
```

**Best Practices**:
- Specify units for numeric values
- Min/Max values where it makes sense
- Default values for enums
- There is no `Decimal` or `Integer` type — use `Double` or `Int`/`Int64` instead.

### Phase 5: Define Types (Entities)

#### 5.1 Plan the inheritance hierarchy
```
${Basic}/NamedEntity (has Name + Description)
  ├── Project
  ├── Task
  └── Sprint

${System}/Entity (base)
  ├── Employee (own type; uses e.g. ${Basic}/Contact as a record attribute)
  └── Client
```

#### 5.2 Type with Basic attributes
File: `types/Project.yaml`
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
types:
  - typeId: Project
    derivedFromCkTypeId: ${Basic}/NamedEntity   # inherits Name + Description
    description: "Represents a project in the system"
    attributes:
      - id: ${this}/ProjectCode
        name: ProjectCode
        autoIncrementReference: "ProjectCode"   # Auto-ID
      - id: ${Basic}/From                       # reuse!
        name: StartDate
      - id: ${Basic}/To
        name: Deadline
      - id: ${this}/Budget
        name: Budget
      # AI fields
      - id: ${this}/RiskScore
        name: RiskScore
        isOptional: true
    associations:
      - id: ${this}/ProjectTasks
        targetCkTypeId: ${this}/Task
      # more...
```

**Important patterns**:
- `${this}/` for references to your own model
- `${Basic}/` for Basic attributes, records and types
- `${System}/` for System attributes, types and predefined association roles
  (e.g. `${System}/ParentChild`, `${System}/Related`)

### Phase 6: Define Associations

#### 6.1 Association Roles
File: `associations/ProjectAssociations.yaml`
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
associationRoles:
  - id: ProjectTasks
    description: "Tasks belonging to a project"
    inboundName: Tasks          # plural on the project side
    inboundMultiplicity: N       # many tasks
    outboundName: Project        # singular on the task side
    outboundMultiplicity: One    # one project
```

#### 6.2 Reference in Types
```yaml
# In Project.yaml
associations:
  - id: ${this}/ProjectTasks
    targetCkTypeId: ${this}/Task

# In Task.yaml
associations:
  - id: ${System}/ParentChild   # predefined parent-child relationship
    targetCkTypeId: ${this}/Project
```

> Multiplicity (1:N etc.) is defined exclusively at the `associationRole`.
> Within a type there is no `cardinality` field — the relationship is bound
> to the role only via `id` and `targetCkTypeId`.

### Phase 7: Records (Complex Types)

#### 7.1 Define a Record
File: `records/ProjectRecords.yaml`
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
records:
  - recordId: SkillRecord
    description: "Record type for skill assessment"
    attributes:
      - id: ${this}/SkillName
        name: SkillName
      - id: ${this}/SkillLevel
        name: Level
      - id: ${Basic}/Time          # reuse a Basic attribute
        name: LastUsed
```

### Phase 8: Integration of Basic Components

#### 8.1 Checklist for Basic usage
Before creating your own attributes, check:

**Time information**:
- ❌ NOT: `StartDate: DateTime`
- ✅ BETTER: `${Basic}/From` and `${Basic}/To`
- ✅ OR: `${Basic}/TimeRange` (Record)

**Contact data**:
- ❌ NOT: your own FirstName, LastName, Email
- ✅ BETTER: `${Basic}/Contact` (Record with everything)
  or `${Basic}/EMailAddress`, `${Basic}/TelephoneNumber` as individual attributes

**General fields**:
- ❌ NOT: `Notes: String`
- ✅ BETTER: `${Basic}/Comment`

### Phase 9: AI Integration

#### 9.1 Mark AI fields
```yaml
attributes:
  - id: RiskScore
    valueType: Double
    description: "AI-calculated risk score (0-100)"
    metaData:
      - key: Unit
        value: "%"
      - key: AIGenerated  # own convention for marking
        value: "true"
      - key: UpdateFrequency
        value: "hourly"
```

> `AIGenerated` and `UpdateFrequency` are not keys enforced by the schema —
> they are conventions of this Construction Kit that AI agents and UIs
> can evaluate.

#### 9.2 AI agent folder
```bash
mkdir ConstructionKit/AI
# place C# agent classes here
```

### Phase 10: Validation and Cleanup

#### 10.1 Schema check
Every YAML file MUST start with:
```yaml
$schema: https://schemas.meshmakers.cloud/construction-kit-elements.schema.json
```

#### 10.2 Reference check
- Do all `valueCkEnumId` reference existing enums?
- Do all `targetCkTypeId` reference existing types?
- Are all attributes used in types defined?

#### 10.3 Cleanup
```bash
# Remove old/temporary files
rm *.bak
rm sample*.yaml
```

### Phase 11: Documentation

#### 11.1 Create README.md
Contents:
- Overview of the Construction Kit
- Main entities and their purpose
- AI features
- API examples
- Deployment instructions

## Common Pitfalls

### Problem 1: "Attribute not found"
**Cause**: Attribute is used but not defined
**Solution**: Define it in attributes/*.yaml or use a Basic attribute

### Problem 2: "Circular dependency"
**Cause**: A → B → A relationship
**Solution**: One direction as an association, the other via API

### Problem 3: "Invalid multiplicity"
**Cause**: Use of `Many` or `ZeroOrMany`
**Solution**: Multiplicities only exist on `associationRoles` and are
restricted to `One`, `ZeroOrOne` and `N`. On an association inside a type
there is no `cardinality` field.

### Problem 4: "Missing dependency"
**Cause**: Basic attributes used without Basic listed in dependencies
**Solution**: Add it in ckModel.yaml (with version range):
```yaml
dependencies:
  - Basic-[2.0,3.0)
```

## Deployment

### Test locally:
```bash
# YAML syntax (optional)
yamllint ConstructionKit/

# Schema validation and compilation happen during the .NET build:
dotnet build -c DebugL
```

During the build, YAML files are validated against the JSON schemas and
translated by the ConstructionKit compiler into a compiled CK library
(`bin/.../octo-ck-libraries/.../out/ck-<name>.yaml`).

### Deploy to OctoMesh:
```bash
# Import the compiled CK YAML file into the current tenant
octo-cli -c ImportCk -f ./bin/DebugL/net10.0/octo-ck-libraries/<Project>/out/ck-<name>.yaml -w
```

With `-w` the CLI waits until the Hangfire job has finished and reports
success or failure. Beforehand, the tenant context must be set up
(`octo-cli -c UseContext -n <name>`) and a valid token must be available
(`octo-cli -c LogIn -i`).

## Summary

The most important rules:
1. **Always check Basic** before creating your own attributes
2. **Schema declaration** in every YAML file
3. **MetaData** for all numeric attributes
4. **Consistent naming** (PascalCase for IDs)
5. **Use inheritance** (NamedEntity for named objects)
6. **Mark AI fields** with MetaData
7. **Define associations bidirectionally**
8. **Records for reuse** of complex structures

## Result
A complete, Basic-compatible ConstructionKit that:
- Follows OctoMesh standards
- Reuses Basic components
- Enables AI integration
- Is extensible and maintainable
