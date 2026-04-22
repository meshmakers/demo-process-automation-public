param (
    [string]$configuration = "DebugL"
)

octo-cli -c EnableCommunication
octo-cli -c EnableReporting
octo-cli -c ImportFromCatalog -cn PublicGitHubCatalog -m Basic-2.0.2 -w
octo-cli -c ImportCk -f ../src/ProcessAutomationDemo/bin/$configuration/net10.0/octo-ck-libraries/ProcessAutomationDemo/out/ck-accountingdemo.yaml -w
