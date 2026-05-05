# Use -r (replace) so re-running the script on an existing tenant is idempotent:
# ImportRt defaults to InsertOnly, which fails with duplicate-key errors on
# already-imported entities.
#
# IMPORTANT: pipelines that include an AnthropicAiQuery@1 node (v2, v3)
# resolve the Anthropic API key from a System.Communication/AiConfiguration
# entity. Run `./om_setup_ai_configuration.ps1` once before deploying those
# data flows so the 'Anthropic' AiConfiguration is in place; the pipelines
# below carry the System.Communication/Uses association that points at its
# well-known RtId.

octo-cli -c ImportRt -f ./../data/_general/rt-root-folders.yaml -w -r
octo-cli -c ImportRt -f ./../data/_general/rt-autoincrement.yaml -w -r

# Import adapters
octo-cli -c ImportRt -f ./../data/_general/rt-adapters-mesh.yaml -w -r

# Import pipelines
octo-cli -c ImportRt -f ./../data/_pipelines/rt-pipeline-excel.yaml -w -r
octo-cli -c ImportRt -f ./../data/_pipelines/upload_accounting_document_v1.yaml -w -r
octo-cli -c ImportRt -f ./../data/_pipelines/upload_accounting_document_v2.yaml -w -r
octo-cli -c ImportRt -f ./../data/_pipelines/upload_accounting_document_v3.yaml -w -r
