# 🐙 OctoMesh Treasure Hunt Challenge 🏆

## Win an exclusive OctoMesh mug!

Welcome to the **OctoMesh Treasure Hunt Challenge** - an exciting pipeline competition where you can prove your skills in data processing, AI integration and creative problem-solving!

## 🎯 The Goal

Build clever OctoMesh pipelines to find hidden clues in documents, detect anomalies, and ultimately generate a secret key. The first to submit the correct key wins a limited-edition **OctoMesh mug** with logo!

## 📋 Prerequisites

- OctoMesh access (test environment will be provided)
- Basic knowledge of YAML and JSON
- Enjoyment of tricky puzzles and data analysis
- The Process Automation Demo repository

## 🗺️ The Challenge - 4 Stages to the Treasure

### 🔍 Stage 1: Data Discovery (25 Points)
**"The search for hidden patterns"**

In this folder you will find 10 PDF invoices: `data/testFiles/2_treasure_hunt/stage1/`

**Your task:**
1. Build a pipeline that loads all AccountingDocuments with status "NEW"
2. Find the following hidden clues:
   - All IBANs starting with "AT42"
   - Invoice numbers matching the pattern "2024-XXXX-MM" (MM = Meshmakers)
   - Net amounts (NetTotal) that are divisible by 13
3. Sum the last 4 digits of all found IBANs → **Code A**

**Pipeline design tips**
* Create a new pipeline for this stage, e.g. `treasure_hunt_stage1`
* Use these transformers:
```yaml
- GetRtEntitiesByType@1
- ForEach@1
- If@1 # (conditional logic, e.g. with regex)
- Math@1
- ExecuteCSharp@1
- SetPrimitiveValue@1
- Flatten@1
- Project@1
- SumAggregation@1
- CreateUpdateInfo@1
- ApplyChanges@2
```

For more information and examples see [OctoMesh Docs](https://docs.meshmakers.cloud/docs/technologyGuide/communication/dataPipelines/nodes/transformation/math_1) for details on the nodes.

### 🎲 Stage 2: Anomaly Hunter (25 Points)
**"Find the treasures in the data"**

Upload directory: `data/testFiles/2_treasure_hunt/stage2/`
Contains 20 invoices from 3 different companies.

**Your task:**
1. Use the `detect_anomalies_amount_spike_estimation` pipeline as a template
2. Modify the parameters so that exactly 3 documents are detected as anomalies:
   - These have net amounts that are prime numbers > 1000
3. The sum of the 3 anomaly amounts divided by 100 → **Code B**

### 🔧 Stage 3: Pipeline Engineering (30 Points)
**"The transformation master"**

**Your task:**
1. Build a pipeline that:
   - Loads all documents with status "REVIEW" from Stage 2
   - Takes their `NetTotal` values and performs the following calculation:
     ```
     Result = (Sum of all NetTotal) * (Number of documents) / 42
     ```
   - Rounds the result to 2 decimal places
   - Encodes it with Base64 → **Code C**

2. Use at least the following transformers:
   - `GetRtEntitiesByType@1`
   - `ForEach@1`
   - `Math@1` or `ExecuteCSharp@1`
   - `Base64Encode@1`

### 🏗️ Stage 4: Construction Kit Master (20 Points)
**"Extend the data model"**

**Your task:**
1. Extend the AccountingDemo Construction Kit with a new type `TreasureHunt` with the attributes `HunterName` (String), `StageCompleted` (Int) and `CodeFragment` (String). Pseudocode sketch:
   ```yaml
   TreasureHunt:
     attributes:
       - HunterName: String
       - StageCompleted: Int
       - CodeFragment: String
   ```
   The real CK YAML syntax (with `typeId`, `derivedFromCkTypeId`, separate `attributes/*.yaml` files etc.) can be found in `docs/ConstructionKit-Quick-Reference-EN.md` and in the existing files under `src/ProcessAutomationDemo/ConstructionKit/`. You then have to build the CK (`dotnet build -c DebugL`) and re-import it (`om_importck.ps1`).

2. Build a pipeline that:
   - Creates a `TreasureHunt` entity for each completed stage
   - Stores codes A, B, C as `CodeFragment`
   - Queries all entities and concatenates the codes

### 🔑 The final key

Generate the final key with the following formula:
```
OCTO-2025-{MD5(Code_A + "-" + Code_B + "-" + Code_C).substring(0,8).toUpperCase()}
```

**Example:**
- Code A: 4289
- Code B: 171.50  
- Code C: MTIzNC41Ng==
- Key: `OCTO-2025-A7F3B2C8`

## 📊 Scoring & Bonus Points

### Main Prize
- First correct key: **OctoMesh mug with logo**

### Bonus Categories (10 extra points each)
- **🎨 Elegance Award**: Cleanest, best-documented pipeline
- **⚡ Speed Runner**: Fastest solution (timestamp of submission)
- **🚀 Innovation Prize**: Most creative use of OctoMesh features
- **📝 Documentation Star**: Best documentation of the solution

## 🛠️ Helpful Resources

### Pipeline Transformers Cheat Sheet
```yaml
# OCR & AI
PdfOcrExtraction@1       # PDF text extraction
AnthropicAiQuery@1       # AI-based data extraction

# Anomaly detection
MachineLearningAnomalyDetection@1  # ML.NET spike detection
StatisticalAnomalyDetection@1      # Statistical methods

# Data manipulation  
ForEach@1                # Iteration over arrays
Project@1                # Select fields
Flatten@1                # Flatten arrays
If@1                     # Conditional processing
SetPrimitiveValue@1      # Set primitive values
CreateUpdateInfo@1       # Create update information
ApplyChanges@2           # Apply changes
GetRtEntitiesByType@1    # Retrieve entities of a type
ExecuteCSharp@1          # Execute C# code
FormatString@1           # Format strings
TransformString@1        # Transform strings
SumAggregation@1         # Summation

# Calculations
Math@1                   # Mathematical operations
Base64Encode@1           # Base64 encoding
Hash@1                   # Hashing (e.g. MD5, SHA256)
```

For more information and examples see [OctoMesh Docs](https://docs.meshmakers.cloud/docs/technologyGuide/communication/dataPipelines/nodes/transformation/math_1) for details on the nodes.

### Useful Queries
```graphql
# All AccountingDocuments with status REVIEW
{
  AccountingDocument(where: {DocumentState: {eq: "REVIEW"}}) {
    RtId
    GrossTotal
    TransactionNumber
  }
}
```

### Test Commands

```powershell
# Upload of test files for Stage 1
.\uploadDirectoryv3.ps1 -directory "../data/testFiles/2_treasure_hunt/stage1/"

# Upload of test files for Stage 2
.\uploadDirectoryv3.ps1 -directory "../data/testFiles/2_treasure_hunt/stage2/"
```

The default values (`-tenant processautomationdemo`, `-baseUrl https://localhost:5020`) work for the local demo. If you are working against a different environment or a different tenant, specify `-tenant` and `-baseUrl` explicitly.

## 📤 Submission

1. **Document your solution** in a `SOLUTION.md` file with:
   - All created pipelines (YAML)
   - Construction Kit extensions
   - Intermediate results (Code A, B, C)
   - Final key

2. **Send your solution** to: `treasurehunt@meshmakers.io`
   - Subject: "OctoMesh Treasure Hunt - [Your Name]"
   - Attachments: SOLUTION.md, pipeline YAMLs

3. **Deadline**: [To be announced]

## 💡 Tips

- Start with the provided demo pipelines as a template
- Test each stage individually before moving on to the next
- Document your thought process - this helps with bonus scoring
- If you have problems: check the `README.md` and the pipeline examples

## 🤝 Fair Play

- Collaboration is allowed and encouraged!
- Share tips and tricks (but not the final codes 😉)
- Fun and learning come first
- For technical issues: support in the Teams channel #octomesh-treasure-hunt

## 🎉 Good Luck!

May the best pipeline win! Show us what you can do with OctoMesh!

---

*PS: The mug is not just a collector's item, but also the perfect companion for long coding sessions with OctoMesh!*

**#OctoMeshTreasureHunt #DataMesh #PipelineChallenge**
