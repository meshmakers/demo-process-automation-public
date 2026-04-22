param (
    [string]$tenantId = "processautomationdemo",
    [string]$systemContextName = "local_octosystem"
)

# Delete + create must run from a system-tenant context whose auth claims
# don't reference the target tenant. Otherwise the CLI's token in the
# target-tenant context becomes unusable the moment the tenant is deleted,
# and any subsequent command (including Create) fails on token refresh
# with an identity-service 500.

# Switch to system context (stable auth)
octo-cli -c UseContext -n $systemContextName

# Delete the target tenant
octo-cli -c Delete -tid $tenantId -y

# Remove the per-tenant context. Its stored access/refresh tokens
# now reference a tenant that no longer exists. Leaving them would
# cause a later `UseContext` back to this name to return a token
# that looks valid (by exp) but 500s on refresh.
$tenantContextName = "local_$tenantId"
octo-cli -c RemoveContext -n $tenantContextName

# Intentionally stay on $systemContextName — the target context is gone.
