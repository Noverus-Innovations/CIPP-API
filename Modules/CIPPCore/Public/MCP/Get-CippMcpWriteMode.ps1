function Get-CippMcpWriteMode {
    <#
    .SYNOPSIS
        Decides whether a connection may see the write tools: 'off' (default), 'on' (read and write) or 'only' (write tools only).
    .DESCRIPTION
        Two switches must BOTH be set, so a tweak to a connector URL alone can never enable writes:
          1. the deployment allows it: app setting / environment variable CIPP_MCP_ALLOW_WRITE = 'true'
          2. the connector asks for it: ?write=true (or 1) for read and write, ?write=only for write tools only
        Anything else is 'off'. A request for writes on a deployment that has not allowed them is logged and stays 'off'.
    .FUNCTIONALITY
        Internal
    #>
    [CmdletBinding()]
    param($Request)

    $Asked = "$($Request.Query.write)".Trim().ToLowerInvariant()
    if (-not $Asked -or $Asked -in @('false', '0', 'no', 'off')) { return 'off' }

    if ("$($env:CIPP_MCP_ALLOW_WRITE)".Trim().ToLowerInvariant() -ne 'true') {
        Write-Warning '[MCP] write=... was requested but CIPP_MCP_ALLOW_WRITE is not true on this deployment; staying read-only.'
        return 'off'
    }
    if ($Asked -eq 'only') { return 'only' }
    if ($Asked -in @('true', '1', 'yes', 'on')) { return 'on' }
    Write-Warning "[MCP] Unrecognised write value '$Asked'; staying read-only."
    return 'off'
}
