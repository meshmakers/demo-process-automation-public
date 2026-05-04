# 🐙 OctoMesh Treasure Hunt Challenge 🏆

## Gewinne eine exklusive OctoMesh-Tasse!

Willkommen zur **OctoMesh Treasure Hunt Challenge** - einem spannenden Pipeline-Wettbewerb, bei dem du deine Skills in Datenverarbeitung, AI-Integration und kreativer Problem-Lösung unter Beweis stellen kannst!

## 🎯 Das Ziel

Konstruiere clevere OctoMesh-Pipelines, um versteckte Hinweise in Dokumenten zu finden, Anomalien zu entdecken und am Ende einen geheimen Schlüssel zu generieren. Der erste, der den korrekten Schlüssel einreicht, gewinnt eine limitierte **OctoMesh-Tasse** mit Logo!

## 📋 Voraussetzungen

- OctoMesh-Zugang (Testumgebung wird bereitgestellt)
- Grundkenntnisse in YAML und JSON
- Spaß an kniffligen Rätseln und Datenanalyse
- Das Process Automation Demo Repository

## 🗺️ Die Challenge - 4 Stufen zum Schatz

### 🔍 Stufe 1: Data Discovery (25 Punkte)
**"Die Suche nach den versteckten Mustern"**

In diesem Ordner findest du 10 PDF-Rechnungen: `data/testFiles/2_treasure_hunt/stage1/`

**Deine Aufgabe:**
1. Erstelle eine Pipeline, die alle `AccountingDocument`-Entitäten mit
   `DocumentState == NEW` lädt.
2. Finde folgende versteckte Hinweise in den geladenen Dokumenten (nur der
   erste Punkt fließt in Code A ein; die anderen beiden sind unabhängige
   Easter-Eggs, die du mit derselben Pipeline ebenfalls aufdecken können
   solltest, sie gehören aber nicht zur Code-A-Berechnung):
   - Alle IBANs, die mit `AT42` beginnen.
   - Rechnungsnummern, die auf den Regex `^2024-\d{4}-MM$` passen
     (MM = Meshmakers).
   - Netto-Beträge (`NetTotal`), die durch 13 teilbar sind.
3. **Code A — ziffernweise Summe der AT42-IBAN-Enden.** Für jede
   passende IBAN nimmst du die letzten 4 Zeichen (lauter Ziffern) und
   addierst diese vier Ziffern **einzeln**; die so entstehende
   Ziffernsumme pro IBAN summierst du anschließend über alle passenden
   IBANs. Beispiel: `AT42 1234 5678 9012 3456` liefert
   `3 + 4 + 5 + 6 = 18`; wäre dies die einzige AT42-IBAN, wäre Code A
   gleich `18`. Es ist **nicht** gemeint, die letzten 4 Ziffern als
   vierstellige Zahl zu interpretieren und diese Zahlen zu summieren.
   → **Code A**

**Tipps zum Pipeline-Design**
* Erstelle für diese Stufe eine neue Pipeline, z.B. `treasure_hunt_stage1`
* Nutze diese Transformatoren:
```yaml
- GetRtEntitiesByType@1
- ForEach@1
- If@1 # (Bedingte Logik mit z. B. Regex)
- Math@1
- ExecuteCSharp@1
- SetPrimitiveValue@1
- Flatten@1
- Project@1
- SumAggregation@1
- CreateUpdateInfo@1
- ApplyChanges@2
```

Für weitere Informationen und Beispiele siehe [OctoMesh Docs](https://docs.meshmakers.cloud/docs/technologyGuide/communication/dataPipelines/nodes/transformation/math_1) für Details zu den Nodes.

### 🎲 Stufe 2: Anomaly Hunter (25 Punkte)
**"Finde die Schätze in den Daten"**

Upload-Verzeichnis: `data/testFiles/2_treasure_hunt/stage2/`
Enthält 20 Rechnungen von 3 verschiedenen Firmen.

**Deine Aufgabe:**
1. Nutze die `detect_anomalies_amount_spike_estimation` Pipeline als
   **strukturelle Vorlage** (gleicher Ablauf
   `GetRtEntitiesByType → ForEach → Flag setzen → Update`) - ersetze aber
   den ML.NET-Spike-Detector durch einen Primzahl-Test, denn die Aufgabe
   verlangt die Markierung nach einer mathematischen Eigenschaft
   (Primalität), nicht nach einem statistischen Ausreißer.
2. Genau 3 der 21 Rechnungen sollen als Anomalien markiert werden. Ein
   Dokument ist eine Anomalie genau dann, wenn sein `NetTotal` ganzzahlig
   ist, **größer als 1000** und **prim** ist (z. B. Trial-Division-Test
   in einem `ExecuteCSharp@1`). Diese 3 Dokumente bringst du auf
   `DocumentState = REVIEW`, damit Stufe 3 sie weiterverarbeiten kann.
3. **Code B** = (Summe dieser 3 `NetTotal`-Werte) / 100, formatiert mit
   Punkt als Dezimaltrennzeichen und 2 Nachkommastellen (z. B. `30.41`).
   → **Code B**

### 🔧 Stufe 3: Pipeline Engineering (30 Punkte)
**"Der Transformations-Meister"**

**Deine Aufgabe:**
1. Baue eine Pipeline, die:
   - Alle `AccountingDocument`-Entitäten mit `DocumentState == REVIEW`
     lädt (das sind die 3 Primzahl-Anomalien aus Stufe 2).
   - Deren `NetTotal`-Werte nimmt und berechnet:
     ```
     Ergebnis = (Summe aller NetTotal) * (Anzahl Dokumente) / 42
     ```
   - Das Ergebnis auf exakt 2 Nachkommastellen rundet (Banker's Rounding)
     und culture-invariant mit Punkt als Dezimaltrennzeichen formatiert
     (z. B. `217.21`, niemals `217,21`).
   - Den formatierten String UTF-8-kodiert und dessen Bytes Base64-codiert
     (`Base64Encode@1` erledigt beide Schritte in einem Node). → **Code C**

2. Nutze dabei mindestens diese Transformatoren:
   - `GetRtEntitiesByType@1` (mit Field-Filter `documentState == REVIEW`)
   - `ForEach@1`
   - `Math@1` oder `ExecuteCSharp@1`
   - `Base64Encode@1`

### 🏗️ Stufe 4: Construction Kit Master (20 Punkte)
**"Erweitere das Datenmodell"**

**Deine Aufgabe:**
1. Erweitere das AccountingDemo Construction Kit um einen neuen Typ `TreasureHunt` mit den Attributen `HunterName` (String), `StageCompleted` (Int) und `CodeFragment` (String). Pseudocode-Skizze:
   ```yaml
   TreasureHunt:
     attributes:
       - HunterName: String
       - StageCompleted: Int
       - CodeFragment: String
   ```
   Die echte CK-YAML-Syntax (mit `typeId`, `derivedFromCkTypeId`, separaten `attributes/*.yaml`-Dateien etc.) findest du in `docs/ConstructionKit-Quick-Reference.md` und in den bestehenden Dateien unter `src/ProcessAutomationDemo/ConstructionKit/`. Du musst das CK anschließend bauen (`dotnet build -c DebugL`) und neu importieren (`om_importck.ps1`).

2. Erstelle eine Pipeline, die:
   - Pro Stufe ein `TreasureHunt`-Entity anlegt: `HunterName`
     identifiziert die Stufe (z. B. `Stage1/2/3`), `StageCompleted` ∈
     {1, 2, 3}, und `CodeFragment` enthält den jeweiligen Code (A, B
     oder C, als String).
   - Alle `TreasureHunt`-Entities wieder abfragt (sortiert nach
     `StageCompleted` aufsteigend, damit du die Codes garantiert in der
     Reihenfolge A, B, C bekommst) und die drei `CodeFragment`-Werte mit
     `-` konkateniert - das ist der Input für die Formel unten.

### 🔑 Der finale Schlüssel

Generiere den finalen Schlüssel mit folgender Formel:
```
OCTO-2025-{MD5(Code_A + "-" + Code_B + "-" + Code_C).substring(0,8).toUpperCase()}
```

`MD5(...)` ist der 32-stellige lowercase-Hex-Digest der UTF-8-Bytes der
Konkatenation. `substring(0,8).toUpperCase()` liefert 8 großgeschriebene
Hex-Zeichen; davor kommt der Präfix `OCTO-2025-`. Für die Hash-Stufe
nutzt du `Hash@1` (`algorithm: Md5`, `inputFormat: String`).

**Beispiel (illustrativ, nicht aus diesem Datensatz):**
- Code A: 4289
- Code B: 171.50  
- Code C: MTIzNC41Ng==
- Schlüssel: `OCTO-2025-A7F3B2C8`

## 📊 Bewertung & Bonus-Punkte

### Hauptpreis
- Erster korrekter Schlüssel: **OctoMesh Tasse mit Logo**

### Bonus-Kategorien (je 10 Punkte extra)
- **🎨 Eleganz-Award**: Sauberste, best-dokumentierte Pipeline
- **⚡ Speed-Runner**: Schnellste Lösung (Zeitstempel der Einreichung)
- **🚀 Innovation-Prize**: Kreativste Nutzung von OctoMesh-Features
- **📝 Documentation-Star**: Beste Dokumentation der Lösung

## 🛠️ Hilfreiche Ressourcen

### Pipeline-Transformatoren Cheat Sheet
```yaml
# OCR & AI
PdfOcrExtraction@1       # PDF Text-Extraktion
AnthropicAiQuery@1       # AI-basierte Datenextraktion

# Anomalie-Detection
MachineLearningAnomalyDetection@1  # ML.NET Spike Detection
StatisticalAnomalyDetection@1      # Statistische Methoden

# Daten-Manipulation  
ForEach@1                # Iteration über Arrays
Project@1                # Felder selektieren
Flatten@1                # Arrays glätten
If@1                     # Bedingte Verarbeitung
SetPrimitiveValue@1      # Primitive Werte setzen
CreateUpdateInfo@1       # Update-Informationen erstellen
ApplyChanges@2           # Änderungen anwenden
GetRtEntitiesByType@1    # Entities eines Typs abrufen
ExecuteCSharp@1          # C# Code ausführen
FormatString@1           # Strings formatieren
TransformString@1        # Strings transformieren
SumAggregation@1         # Summenbildung

# Berechnungen
Math@1                   # Mathematische Operationen
Base64Encode@1           # Base64 Encoding
Hash@1                   # Hashing (z.B. MD5, SHA256)
```

Für weitere Informationen und Beispiele siehe [OctoMesh Docs](https://docs.meshmakers.cloud/docs/technologyGuide/communication/dataPipelines/nodes/transformation/math_1) für Details zu den Nodes.

### Nützliche Queries
```graphql
# Alle AccountingDocuments mit Status REVIEW
{
  AccountingDocument(where: {DocumentState: {eq: "REVIEW"}}) {
    RtId
    GrossTotal
    TransactionNumber
  }
}
```

### Test-Kommandos

```powershell
# Upload der Testdateien für Stufe 1
.\uploadDirectoryv3.ps1 -directory "../data/testFiles/2_treasure_hunt/stage1/"

# Upload der Testdateien für Stufe 2
.\uploadDirectoryv3.ps1 -directory "../data/testFiles/2_treasure_hunt/stage2/"
```

Die Standardwerte (`-tenant meshtest`, `-baseUrl https://localhost:5020`) passen für die lokale Demo. Wenn du gegen eine andere Umgebung oder einen anderen Tenant arbeitest, gib `-tenant` und `-baseUrl` explizit an.

## 📤 Einreichung

1. **Dokumentiere deine Lösung** in einer `SOLUTION.md` Datei mit:
   - Alle erstellten Pipelines (YAML)
   - Construction Kit Erweiterungen
   - Zwischenergebnisse (Code A, B, C)
   - Finaler Schlüssel

2. **Sende deine Lösung** an: `treasurehunt@meshmakers.io`
   - Betreff: "OctoMesh Treasure Hunt - [Dein Name]"
   - Anhänge: SOLUTION.md, Pipeline-YAMLs

3. **Deadline**: [Wird noch bekannt gegeben]

## 💡 Tipps

- Starte mit den bereitgestellten Demo-Pipelines als Vorlage
- Teste jede Stufe einzeln bevor du zur nächsten gehst
- Dokumentiere deine Gedankengänge - das hilft bei der Bonus-Bewertung
- Bei Problemen: Schau in die `README.md` und die Pipeline-Beispiele

## 🤝 Fair Play

- Zusammenarbeit ist erlaubt und erwünscht!
- Teilt Tipps und Tricks (aber nicht die finalen Codes 😉)
- Der Spaß und das Lernen stehen im Vordergrund
- Bei technischen Problemen: Support im Teams-Channel #octomesh-treasure-hunt

## 🎉 Viel Erfolg!

Möge die beste Pipeline gewinnen! Zeigt uns, was ihr mit OctoMesh alles anstellen könnt!

---

*PS: Die Tasse ist nicht nur ein Sammlerstück, sondern auch der perfekte Begleiter für lange Coding-Sessions mit OctoMesh!*

**#OctoMeshTreasureHunt #DataMesh #PipelineChallenge**
