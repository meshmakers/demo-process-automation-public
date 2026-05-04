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
1. Build a pipeline that loads all `AccountingDocument` entities with
   `DocumentState == NEW`.
2. Find the following hidden clues among the loaded documents (the first
   bullet is what feeds Code A; the other two are independent easter eggs
   that you should *also* be able to surface with your pipeline, but they
   are not part of the Code A calculation):
   - All IBANs starting with `AT42`.
   - Invoice numbers matching the regex `^2024-\d{4}-MM$` (MM = Meshmakers).
   - Net amounts (`NetTotal`) that are divisible by 13.
3. **Code A — per-digit sum of the AT42 IBAN suffixes.** For every matching
   IBAN take its last 4 characters (which are digits), add those four digits
   together, then sum that per-IBAN digit-sum across all matching IBANs.
   Example: IBAN `AT42 1234 5678 9012 3456` contributes `3 + 4 + 5 + 6 = 18`;
   if that were the only AT42 match Code A would be `18`. This is **not** the
   same as concatenating the last 4 digits and treating them as one integer.
   → **Code A**

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
1. Use the `detect_anomalies_amount_spike_estimation` pipeline as a
   **structural template** (same `GetRtEntitiesByType → ForEach → flag → update`
   shape) - but swap the ML.NET spike detector for a primality predicate,
   because the spec requires flagging by a mathematical property
   (primality), not a statistical outlier.
2. Exactly 3 of the 21 invoices must end up flagged as anomalies. An invoice
   is an anomaly iff its `NetTotal` is an integer, is **greater than 1000**,
   and is **prime** (e.g. a trial-division test in an `ExecuteCSharp@1`).
   Flip those 3 documents to `DocumentState = REVIEW` so Stage 3 can pick
   them up.
3. **Code B** = (sum of those 3 `NetTotal` values) / 100, formatted with a
   period decimal separator and two decimal places (e.g. `30.41`). → **Code B**

### 🔧 Stage 3: Pipeline Engineering (30 Points)
**"The transformation master"**

**Your task:**
1. Build a pipeline that:
   - Loads all `AccountingDocument` entities with `DocumentState == REVIEW`
     (those are the 3 prime-NetTotal invoices from Stage 2).
   - Takes their `NetTotal` values and computes:
     ```
     Result = (Sum of all NetTotals) * (Number of documents) / 42
     ```
   - Rounds the result to exactly 2 decimal places (half-to-even), and
     formats it with a period decimal separator in a culture-invariant
     way (e.g. `217.21`, never `217,21`).
   - UTF-8-encodes that formatted string and Base64-encodes the bytes
     (`Base64Encode@1` handles both steps in one node). → **Code C**

2. Use at least the following transformers:
   - `GetRtEntitiesByType@1` (with a `documentState == REVIEW` field filter)
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
   - Creates a `TreasureHunt` entity for each completed stage: one per
     stage, with `HunterName` identifying the stage (e.g. `Stage1/2/3`),
     `StageCompleted` ∈ {1, 2, 3}, and `CodeFragment` set to the stage's
     code (A, B, or C respectively, as a string).
   - Queries those entities back (order by `StageCompleted` ascending so
     you always get A, B, C in that order), then concatenates the three
     `CodeFragment` values with `-` separators - i.e. feeds them into the
     final-key formula below.

### 🔑 The final key

Generate the final key with the following formula:
```
OCTO-2025-{MD5(Code_A + "-" + Code_B + "-" + Code_C).substring(0,8).toUpperCase()}
```

`MD5(...)` is the 32-char lowercase hexadecimal digest of the UTF-8 bytes
of the concatenation. `substring(0,8).toUpperCase()` yields 8 uppercase
hex characters; prefix that with `OCTO-2025-`. Use `Hash@1`
(`algorithm: Md5`, `inputFormat: String`) for the hash step.

**Example (illustrative, not from this dataset):**
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

The default values (`-tenant meshtest`, `-baseUrl https://localhost:5020`) work for the local demo. If you are working against a different environment or a different tenant, specify `-tenant` and `-baseUrl` explicitly.

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
