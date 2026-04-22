param (
    [string]$configuration = "DebugL"
)

# Use -r (replace) so re-running the script is idempotent; otherwise ImportRt
# defaults to InsertOnly and fails with duplicate-key errors on already-imported
# entities.

octo-cli -c ImportCk -f ../src/ProcessAutomationDemo/bin/$configuration/net10.0/octo-ck-libraries/ProcessAutomationDemo/out/ck-accountingdemo.yaml -w

octo-cli -c ImportRt -f ./../data/_pipelines/upload_accounting_document_v3.yaml -w -r
octo-cli -c ImportRt -f ./../data/_pipelines/detect_anomalies_amount_percent_change.yaml -w -r
octo-cli -c ImportRt -f ./../data/_pipelines/detect_anomalies_amount_spike_estimation.yaml -w -r
octo-cli -c ImportRt -f ./../data/_pipelines/detect_anomalies_interval_percent_change.yaml -w -r
octo-cli -c ImportRt -f ./../data/_pipelines/detect_anomalies_interval_spike_estimation.yaml -w -r

octo-cli -c ImportRt -f ./../data/_queries/_accounting_documents_all.yaml -r
octo-cli -c ImportRt -f ./../data/_queries/_accounting_documents_review.yaml -r
