# Process Automation Demo - Construction Kit

A comprehensive hands-on demonstration of OctoMesh Process Automation featuring an accounting document processing construction kit with AI-powered anomaly detection capabilities.

## Overview

This demo showcases a complete process automation solution built on the OctoMesh platform, including:

- **Construction Kit**: Pre-built accounting domain model with document processing capabilities
- **AI Pipelines**: Intelligent document analysis and anomaly detection
- **Runtime Data**: Sample queries, pipelines, and test data for immediate experimentation
- **Automation Scripts**: PowerShell scripts for rapid tenant setup and data import

## Quick Start

### Prerequisites

- OctoMesh CLI (`octo-cli`) installed and configured
- PowerShell Core
- .NET 10.0 SDK (for building the construction kit)
- An existing `local_octosystem` CLI context that is logged in. The create/delete
  scripts run from that stable system-tenant context so the auth token survives
  the tenant lifecycle. Register it once with `octo-cli -c AddContext` +
  `octo-cli -c LogIn -i`.
- A running `octo-mesh-adapter` process (this demo uses its HTTP endpoints on
  port 5020). The adapter registers with the Communication Controller at
  startup; restart it after recreating the tenant.
- Build the construction kit before importing it:
  `dotnet build src/ProcessAutomationDemo -c DebugL`

### 1. Create Tenant

```powershell
cd scripts
.\om_create_tenants.ps1
```

This creates a new tenant named `processautomationdemo`, auto-provisions the
current system user as its admin, registers a `local_processautomationdemo`
CLI context, and switches the active context to it.

### 2. Log in to the new tenant (interactive)

```powershell
octo-cli -c LogIn -i
```

Required: the fresh context has no tokens yet. Until this step succeeds every
tenant-scoped command (`EnableCommunication`, `ImportCk`, `ImportRt`,
`DeployDataFlow`) will fail on auth refresh.

### 3. Import Construction Kit Models

```powershell
.\om_importck.ps1
```

Imports the custom accounting demo model and automatically pulls the `Basic` construction kit from the public GitHub catalog:
- `Basic` construction kit (pulled via `ImportFromCatalog` from `PublicGitHubCatalog`)
- Accounting document entities
- AI-enabled analysis fields

No bundled Basic CK is shipped — any recent OctoMesh installation with public-catalog access will resolve it on import.

### 4. Import Runtime Data

```powershell
.\om_importrt.ps1
```

Loads sample data including:
- Document processing pipelines
- Anomaly detection algorithms
- Pre-configured queries
- Mesh adapters

The script imports with `-r` (Upsert), so re-running it against an existing
tenant is safe.

### 5. Deploy DataFlows to the mesh adapter

```powershell
.\om_deploy_dataflows.ps1
```

Walks every DataFlow defined in `data/_pipelines/*.yaml` and calls
`octo-cli -c DeployDataFlow -id <rtId>` for each. The HTTP-triggered pipelines
(v1/v2/v3 upload endpoints, excel) only answer on port 5020 after this step —
import alone is not enough.

Run this again after `om_update_2_anomaly.ps1` or whenever you add a new
pipeline YAML.

## Components

### Construction Kit

The accounting demo construction kit includes:

- **Document Types**: Invoice, Receipt, Contract processing
- **AI Analysis**: Anomaly detection, amount validation, pattern recognition
- **Workflow Integration**: Automated document routing and approval flows

### Pipelines

| Pipeline                                   | Description                                                |
|--------------------------------------------|------------------------------------------------------------|
| `upload_accounting_document_v1`            | Initial version document upload                            |
| `upload_accounting_document_v2`            | Enhanced document upload with metadata extraction          |
| `upload_accounting_document_v3`            | Enhanced document upload with complete metadata extraction |
| `detect_anomalies_amount_percent_change`     | Percent-change on `GrossTotal` (flags amount outliers)   |
| `detect_anomalies_amount_spike_estimation`   | ML.NET spike on `GrossTotal`                             |
| `detect_anomalies_interval_percent_change`   | Percent-change on days-since-last (flags cadence bursts) |
| `detect_anomalies_interval_spike_estimation` | ML.NET spike on days-since-last                          |

### Sample Queries

- `_accounting_documents_all.yaml`: Complete document listing
- `_accounting_documents_review.yaml`: Documents requiring review

## Project Structure

```
demo-process-automation/
├── src/ProcessAutomationDemo/          # Construction kit source
│   └── ConstructionKit/                # YAML model definitions
├── scripts/                            # Automation scripts
│   ├── om_create_tenants.ps1           # Tenant creation (runs from system context)
│   ├── om_delete_tenants.ps1           # Delete demo tenant (runs from system context)
│   ├── om_importck.ps1                 # Construction kit import (pulls Basic from catalog)
│   ├── om_importrt.ps1                 # Runtime data import
│   ├── om_deploy_dataflows.ps1         # Deploys every DataFlow from data/_pipelines/
│   ├── om_update_2_anomaly.ps1         # Unit 2 update: v3 + anomaly pipelines + review queries
│   ├── uploadFile.ps1 / uploadFilev2.ps1 / uploadFilev3.ps1   # Single-file HTTP upload
│   ├── uploadDirectoryv3.ps1           # Batch directory upload via v3 endpoint
│   ├── reset-review-documents.ps1      # Reset REVIEW -> NEW (needs JWT)
│   └── Delete-AccountingAndFileSystemItems.ps1  # Bulk cleanup (supports -Force)
├── data/                               # Sample runtime data
│   ├── _pipelines/                     # AI processing pipelines
│   ├── _queries/                       # Pre-built queries
│   ├── _general/                       # Configuration data
│   └── testFiles/                      # Sample documents
└── docs/                               # Further documentation
```

## Development Workflow

### Building the Construction Kit

```bash
cd src/ProcessAutomationDemo
dotnet build --configuration DebugL
```

The build process generates the deployable construction kit YAML files in the output directory.

### Customizing the Model

1. Edit YAML files in `src/ProcessAutomationDemo/ConstructionKit/`
2. Rebuild the project
3. Re-import using `om_importck.ps1`

### Adding New Pipelines

1. Create new pipeline YAML files in `data/_pipelines/`
2. Update `om_importrt.ps1` (or `om_update_2_anomaly.ps1`) to include the new pipeline
3. Re-run the import script
4. Re-run `.\om_deploy_dataflows.ps1` so the mesh adapter picks up the new DataFlow

## Demo Units

### Unit 1: Invoice Import - Comparing Basic vs AI-Enhanced Processing

This unit demonstrates two different approaches to invoice processing:

#### Basic Invoice Upload (`uploadFile.ps1`)

Simple document upload without data extraction:

```powershell
.\uploadFile.ps1 -file "..\data\testFiles\0_initial\DemoRechnung.pdf"
```

**Pipeline Features (v1):**
- Direct PDF upload to `/uploadaccountingdocument`
- Creates `AccountingDocument` with default values (`GrossTotal = 0`)
- Stores file in FileSystem under "Accounting" folder
- Links document to file via association
- **Use Case**: Fast upload when manual data entry is acceptable

#### AI-Enhanced Invoice Upload (`uploadFilev2.ps1`)

Intelligent document processing with automatic data extraction:

```powershell
.\uploadFilev2.ps1 -file "..\data\testFiles\0_initial\DemoRechnung.pdf"
```

**Pipeline Features (v2):**
- Enhanced PDF upload to `/uploadaccountingdocumentv2`
- **OCR Text Recognition** - Extracts all text from PDF
- **AI-Powered Data Extraction** using Anthropic AI to extract:
  - `transactionDate`: Invoice date
  - `companyName`: Vendor company name
  - `companyAddress`: Company address
  - `grossTotal`: Total amount including tax
  - `netTotal`: Net amount before tax
  - `taxAmount`: Tax amount
- Creates `AccountingDocument` with **real extracted data**
- **Use Case**: Fully automated processing for high-volume scenarios

#### Comparison Table

| Feature              | Basic Upload (v1)            | AI-Enhanced (v2)                  |
|----------------------|------------------------------|-----------------------------------|
| **Speed**            | Fast                         | Slower (OCR + AI processing)      |
| **Data Extraction**  | None - manual entry needed   | Automatic field extraction        |
| **Accuracy**         | Depends on manual input      | AI-based extraction accuracy      |
| **Cost**             | Low                          | Higher (AI API usage)             |
| **Automation Level** | Minimal                      | Full automation                   |
| **Best For**         | Small volumes, manual review | High volumes, automated workflows |

#### Test Instructions

1. Upload the same invoice with both methods:
   ```powershell
   # Basic upload
   .\uploadFile.ps1 -file "..\data\testFiles\0_initial\DemoRechnung.pdf"

   # AI-enhanced upload
   .\uploadFilev2.ps1 -file "..\data\testFiles\0_initial\DemoRechnung.pdf"
   ```

2. Compare the created `AccountingDocument` entities in the system
3. Observe the difference in `GrossTotal` and other extracted fields

### Unit 2: Bulk Import with Enhanced Data Extraction

This unit demonstrates bulk document processing using the most advanced pipeline (v3) which extracts comprehensive accounting data for anomaly detection scenarios.

#### Enhanced Bulk Upload (`uploadDirectoryv3.ps1`)

Process multiple invoices simultaneously with comprehensive data extraction:

```powershell
.\uploadDirectoryv3.ps1 -directory "..\data\testFiles\1_anomalies\interval\"
```

Defaults: `-tenant processautomationdemo`, `-baseUrl https://localhost:5020`
(the mesh adapter's HTTP port). Override either only when running against a
remote environment.

**Pipeline Features (v3):**
- Bulk PDF upload to `/uploadaccountingdocumentv3`
- **Enhanced OCR Processing** with confidence scoring
- **Advanced AI Extraction** using comprehensive JSON schema
- **Complete Data Model Population** including:
  - **Amount Details**: `grossTotal`, `netTotal`, `taxTotal`
  - **Bank Information**: `accountHolder`, `iban`
  - **Issuer Details**: `companyName`, complete address structure
  - **Transaction Data**: `date`, `number`
  - **Document State**: Automatically set to `NEW`

#### Advanced Data Extraction Schema

The v3 pipeline extracts a comprehensive data structure:

```json
{
  "amount": {
    "grossTotal": 1200.00,
    "netTotal": 1000.00,
    "taxTotal": 200.00
  },
  "bankAccount": {
    "accountHolder": "Company Name",
    "iban": "AT741233964761549439"
  },
  "issuer": {
    "companyName": "Invoice Issuer",
    "address": {
      "street": "Main Street 123",
      "zipcode": 5020,
      "cityTown": "Salzburg",
      "nationalCode": "AT"
    }
  },
  "transaction": {
    "date": "2025-09-30",
    "number": "inv-20250930-abc"
  }
}
```

#### Script Features

**Batch Processing:**
- Processes all PDF files in specified directory
- Configurable file filter (default: `*.pdf`)
- Progress tracking with success/failure counts
- Detailed error handling and reporting

**Results Export:**
- Generates timestamped CSV report: `upload_results_YYYYMMDD_HHMMSS.csv`
- Tracks status, response, and errors for each file
- Useful for audit trails and troubleshooting

#### Usage Example

```powershell
# Upload all anomaly test files (interval set)
.\uploadDirectoryv3.ps1 -directory "..\data\testFiles\1_anomalies\interval"

# Amounts set (triggers the grossTotal anomaly pipelines)
.\uploadDirectoryv3.ps1 -directory "..\data\testFiles\1_anomalies\amounts"

# IBAN set
.\uploadDirectoryv3.ps1 -directory "..\data\testFiles\1_anomalies\iban" -filter "*.pdf"

# Point at a remote environment if you are not running locally
.\uploadDirectoryv3.ps1 -tenant mytenant -baseUrl "https://adapter.example.com" -directory "..\data\testFiles\1_anomalies\amounts"
```

#### Expected Results

After processing, you'll have:
1. **10 AccountingDocument entities** with complete extracted data
2. **Comprehensive metadata** for anomaly detection algorithms
3. **CSV report** with processing results
4. **FileSystem storage** of all uploaded PDFs

This dataset is specifically designed to trigger the anomaly detection pipelines in subsequent demo units.

### Unit 3: Anomaly Detection - ML.NET vs Statistical Approaches

After importing data with Unit 2, this unit demonstrates two different
detection **methods** (ML.NET spike vs. statistical percent-change) applied
to two different **signals**:

- **Amount anomalies** — `GrossTotal` deviations per issuer (e.g. an invoice
  that is ~10× the usual amount).
- **Interval anomalies** — `DaysSinceLast` deviations per issuer (e.g. an
  issuer that suddenly sends a burst of invoices in 5 days when their normal
  cadence is monthly).

The two signals are detected by separate pipelines (four in total), each
independently triggerable. The interval pipelines compute `DaysSinceLast`
in-pipeline on each run — no attribute is persisted on the invoice, and
upload order does not affect the result.

#### ML.NET Spike Detection

Two pipelines share the same ML.NET method but target different signals:
- `detect_anomalies_amount_spike_estimation` — detects spikes in `GrossTotal`.
- `detect_anomalies_interval_spike_estimation` — detects spikes in `DaysSinceLast`.

Both use the `MachineLearningAnomalyDetection@1` node with the same parameters
(`detectSpikes: true`, `minDataPoints: 3`, `pValueHistoryLength: 3`) — only
the attribute fed into the detector differs.

**Pipeline Execution:**
```bash
octo-cli -c ExecutePipeline -id <PipelineRtId>
```

`-id` takes the **Pipeline** RtId (not the DataFlow RtId). Look it up in the
matching `data/_pipelines/detect_anomalies_{amount|interval}_spike_estimation.yaml`
— it's the entity with `ckTypeId: System.Communication/Pipeline`. You can
also run the pipeline from Refinery Studio.

**ML.NET Features:**
- **Spike Detection**: Uses `MachineLearningAnomalyDetection@1` transformer
- **Advanced Algorithm**: ML.NET's time series anomaly detection models
- **Statistical Parameters**:
  - `detectSpikes: true` - Focuses on sudden value increases
  - `detectChangePoints: false` - Ignores gradual trend changes
  - `minDataPoints: 3` - Minimum samples needed for analysis
  - `pValueHistoryLength: 3` - Statistical significance window

**Detection Logic:**
- Groups documents by `Issuer.CompanyName`
- Analyzes the target attribute (`GrossTotal` or `DaysSinceLast`) within each company group
- Calculates anomaly scores with statistical confidence levels
- Provides detailed metrics: `level`, `score`, `pValue`

#### Statistical Percent Change Detection

Two pipelines share the same statistical method but target different signals:
- `detect_anomalies_amount_percent_change` — detects percent-changes in `GrossTotal`.
- `detect_anomalies_interval_percent_change` — detects percent-changes in `DaysSinceLast`.

Both use the `StatisticalAnomalyDetection@1` node with the same parameters
(`method: PercentChange`, `threshold: 50.0`, `minSamples: 2`) — only the
attribute fed into the detector differs.

**Pipeline Execution:**
```bash
octo-cli -c ExecutePipeline -id <PipelineRtId>
```

Same convention as above — use the Pipeline RtId from the matching
`data/_pipelines/detect_anomalies_{amount|interval}_percent_change.yaml`,
or trigger it from Refinery Studio.

**Statistical Features:**
- **Percent Change Method**: Uses `StatisticalAnomalyDetection@1` transformer
- **Threshold-Based**: Configurable percentage deviation detection
- **Simple Algorithm**: Basic statistical comparison
- **Parameters**:
  - `method: PercentChange` - Compares values to historical average
  - `threshold: 50.0` - Deviations >50% trigger anomalies
  - `minSamples: 2` - Minimal data requirement for testing

**Detection Logic:**
- Groups documents by `Issuer.CompanyName`
- Calculates a rolling average of the target attribute (`GrossTotal` or `DaysSinceLast`) per company
- Flags invoices whose value deviates >50% from the running baseline
- Simple percentage-based scoring

#### Comparison: ML.NET vs Statistical Approaches

| Aspect                   | ML.NET Spike Detection        | Statistical Percent Change     |
|--------------------------|-------------------------------|--------------------------------|
| **Algorithm Complexity** | Advanced ML models            | Simple statistical comparison  |
| **Detection Method**     | Time series spike analysis    | Percentage deviation from mean |
| **Accuracy**             | High (considers patterns)     | Good (threshold-based)         |
| **Setup Complexity**     | Moderate                      | Simple                         |
| **Performance**          | Slower (ML processing)        | Fast                           |
| **False Positives**      | Lower (context-aware)         | Higher (simple threshold)      |
| **Minimum Data**         | 3 data points                 | 2 data points                  |
| **Best For**             | Complex patterns, time series | Quick setup, simple rules      |

#### Anomaly Response Actions

Both pipelines perform identical actions when anomalies are detected:

1. **Document Status Update**: Changes `DocumentState` from `NEW` to `REVIEW`
2. **Comment Addition**: Adds descriptive comment explaining the anomaly:
   - **ML.NET**: "Invoice amounts are out of range with level X, score Y, pValue Z"
   - **Statistical**: Includes reason and deviation percentage
3. **Workflow Trigger**: Documents enter review queue for manual inspection

#### Testing with Sample Datasets

Two complementary sample datasets live under `data/testFiles/1_anomalies/`.
Each one exercises a different **signal** — the detection **method** (ML.NET
spike vs. percent-change) is orthogonal and applies to both.

**`amounts/`** — ten invoices from *Demo Energie Gmunden KG*. Jan–Apr 2023 are
at €288 each, then May–Oct 2023 jump to €2880 each (a 10× step). Triggers
the `detect_anomalies_amount_*` pipelines:
- **Percent change** flags May 2023 and June 2023 with `Change: 900,00%`.
- **ML.NET spike** flags May 2023 with a high-confidence distributional spike
  (level 1, pValue ~1E-08).

**`interval/`** — ten invoices from *Delta Energie Salzburg GmbH*, all at €288
so `GrossTotal` is uninteresting. Jan–May 10 2023 are one invoice per month;
May 11–15 2023 add five more invoices in five days (a cadence burst).
Triggers the `detect_anomalies_interval_*` pipelines:
- **Percent change** flags May 11 and May 12 with `Change: ~96,77%` (the
  first two invoices where `DaysSinceLast` collapses from ~30 to 1).
- **ML.NET spike** flags May 11 with a high-confidence distributional spike.

#### Demo Workflow

The two datasets are independent — you can exercise them in either order, or
mix them in the same tenant. Each detector only flags the invoices whose
signal is anomalous, so uploading both sets still produces clean, separable
results.

1. **Import a dataset** (Unit 2). Pick one or both:
   ```powershell
   # amount anomalies
   .\uploadDirectoryv3.ps1 -directory "..\data\testFiles\1_anomalies\amounts"

   # interval (cadence) anomalies
   .\uploadDirectoryv3.ps1 -directory "..\data\testFiles\1_anomalies\interval"
   ```

2. **Run a detector** — via `octo-cli -c ExecutePipeline -id <PipelineRtId>`
   or from Refinery Studio. Pick the pipeline that matches the signal you
   want to exercise (`detect_anomalies_amount_*` or
   `detect_anomalies_interval_*`) and the method you want to compare
   (`*_percent_change` vs. `*_spike_estimation`).

3. **Review results**: query documents with `DocumentState = "REVIEW"`.

4. **Reset for re-testing**:
   ```powershell
   .\reset-review-documents.ps1 -AuthToken "your-token"
   ```

5. Repeat step 2 with a different pipeline to compare how each
   method/signal combination behaves on the same data.

This demonstrates how different anomaly detection methods can be applied to
different signals on the same dataset, showcasing the flexibility of the
OctoMesh platform for various analytical needs.

## File Upload Utilities

Additional PowerShell scripts for document management:

- `uploadFile.ps1`: Basic single file upload (Pipeline v1)
- `uploadFilev2.ps1`: AI-enhanced single file upload (Pipeline v2)
- `uploadFilev3.ps1`: Full-extraction single file upload (Pipeline v3)
- `uploadDirectoryv3.ps1`: Batch directory upload
- `reset-review-documents.ps1`: Reset documents from REVIEW status back to NEW
- `Delete-AccountingAndFileSystemItems.ps1`: Bulk-delete AccountingDocuments + FileSystemItems (pass `-Force` to skip the confirmation prompt)

### Document Status Management

The `reset-review-documents.ps1` script allows you to reset all documents that are in "REVIEW" status back to "NEW" status. This is useful for demo purposes when you want to restart the review workflow.

**Usage:**
```powershell
.\reset-review-documents.ps1 -AuthToken "your-jwt-token"
```

**Optional Parameters:**
- `-BaseUrl`: OctoMesh server base URI (default: `https://localhost:5001`)
- `-tenant`: Tenant name (default: `processautomationdemo`)

**What it does:**
1. Queries all `AccountingDocument` entities with `documentState = "REVIEW"`
2. Updates each document to set:
   - `documentState = "NEW"`
   - `comment = null`
3. Reports the number of successfully reset documents

**Note:** This script requires a JWT access token. `octo-cli` stores the
current one in its context file — pull it from there:

```powershell
$ctx = Get-Content ~/.octo-cli/contexts.json | ConvertFrom-Json
$token = $ctx.Contexts.local_processautomationdemo.Authentication.AccessToken
.\reset-review-documents.ps1 -AuthToken $token
```

Run `octo-cli -c AuthStatus` first if the token has expired; it will refresh
the context automatically. The same token pattern applies to
`Delete-AccountingAndFileSystemItems.ps1`.

## Cleanup

To remove the demo tenant:

```powershell
.\om_delete_tenants.ps1
```

## Advanced Features

### AI Integration

The construction kit demonstrates several AI capabilities:

- **Data Extraction**: Key-value pair extraction from documents via AI
- **Anomaly Detection**: Statistical and ML.NET-based analysis for unusual patterns

### Extensibility

The demo is designed for extension:

- Add new document types by extending the construction kit
- Create custom AI pipelines for specific business rules
- Integrate with external systems via mesh adapters
- Build custom queries for specific reporting needs

## Documentation

Detailed documentation is available in the `docs/` directory (German originals with English translations):

- Complete construction kit development guide: [Deutsch](docs/ConstructionKit-Step-by-Step.md) | [English](docs/ConstructionKit-Step-by-Step-EN.md)
- Advanced development patterns: [Deutsch](docs/ConstructionKit-Development-Guide.md) | [English](docs/ConstructionKit-Development-Guide-EN.md)
- API reference and examples: [Deutsch](docs/ConstructionKit-Quick-Reference.md) | [English](docs/ConstructionKit-Quick-Reference-EN.md)
- OctoMesh Treasure Hunt Challenge: [Deutsch](OCTOMESH_TREASURE_HUNT_DE.md) | [English](OCTOMESH_TREASURE_HUNT_EN.md)

## Support

For issues and questions:

- Review the documentation in the `docs/` folder
- Check the OctoMesh documentation
- Examine the sample data files for usage patterns

This demo provides a complete foundation for building sophisticated process automation solutions with AI capabilities using the OctoMesh platform.