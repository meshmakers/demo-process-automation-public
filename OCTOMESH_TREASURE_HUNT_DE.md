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
1. Erstelle eine Pipeline, die alle AccountingDocuments mit Status "NEW" lädt
2. Finde folgende versteckte Hinweise:
   - Alle IBANs, die mit "AT42" beginnen
   - Rechnungsnummern, die das Muster "2024-XXXX-MM" haben (MM = Meshmakers)
   - Netto-Beträge (NetTotal), die durch 13 teilbar sind
3. Summiere die letzten 4 Ziffern aller gefundenen IBANs → **Code A**

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
1. Nutze die `detect_anomalies_amount_spike_estimation` Pipeline als Vorlage
2. Modifiziere die Parameter so, dass genau 3 Dokumente als Anomalien erkannt werden:
   - Diese haben Netto-Beträge, die Primzahlen > 1000 sind
3. Die Summe der 3 Anomalie-Beträge geteilt durch 100 → **Code B**

### 🔧 Stufe 3: Pipeline Engineering (30 Punkte)
**"Der Transformations-Meister"**

**Deine Aufgabe:**
1. Baue eine Pipeline, die:
   - Alle Dokumente mit Status "REVIEW" aus Stufe 2 lädt
   - Deren `NetTotal` Werte nimmt und folgende Berechnung durchführt:
     ```
     Ergebnis = (Summe aller NetTotal) * (Anzahl Dokumente) / 42
     ```
   - Das Ergebnis auf 2 Dezimalstellen rundet
   - Mit Base64 encodiert → **Code C**

2. Nutze dabei mindestens diese Transformatoren:
   - `GetRtEntitiesByType@1`
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
   - Ein `TreasureHunt` Entity für jede abgeschlossene Stufe anlegt
   - Die Codes A, B, C als `CodeFragment` speichert
   - Alle Entities abfragt und die Codes konkateniert

### 🔑 Der finale Schlüssel

Generiere den finalen Schlüssel mit folgender Formel:
```
OCTO-2025-{MD5(Code_A + "-" + Code_B + "-" + Code_C).substring(0,8).toUpperCase()}
```

**Beispiel:**
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

Die Standardwerte (`-tenant processautomationdemo`, `-baseUrl https://localhost:5020`) passen für die lokale Demo. Wenn du gegen eine andere Umgebung oder einen anderen Tenant arbeitest, gib `-tenant` und `-baseUrl` explizit an.

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
