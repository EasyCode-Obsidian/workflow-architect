# deepwiki.ps1 — DeepWiki MCP HTTP wrapper for workflow-architect (Windows)
# Calls DeepWiki's Streamable HTTP MCP endpoint directly via Invoke-RestMethod.
# No MCP configuration or session restart required.
#
# Usage:
#   deepwiki.ps1 ask "owner/repo" "question"
#   deepwiki.ps1 ask '["owner/repo1","owner/repo2"]' "question"   # cross-repo (max 10)
#   deepwiki.ps1 structure "owner/repo"
#   deepwiki.ps1 contents "owner/repo"
#
# Environment:
#   DEEPWIKI_RETRIES   - max retry attempts on 429 (default: 3)
#   DEEPWIKI_CACHE_DIR - cache directory path (default: .workflow/deepwiki-cache)

param(
    [Parameter(Position=0, Mandatory=$true)]
    [string]$Command,

    [Parameter(Position=1, Mandatory=$true)]
    [string]$Repo,

    [Parameter(Position=2)]
    [string]$Question
)

$ErrorActionPreference = "Stop"

$ENDPOINT = "https://mcp.deepwiki.com/mcp"
$MAX_RETRIES = if ($env:DEEPWIKI_RETRIES) { [int]$env:DEEPWIKI_RETRIES } else { 3 }
$RETRY_DELAYS = @(10, 30, 60)
$CACHE_DIR = if ($env:DEEPWIKI_CACHE_DIR) { $env:DEEPWIKI_CACHE_DIR } else { ".workflow/deepwiki-cache" }

# ── helpers ──────────────────────────────────────────────────────

function Call-MCP {
    param(
        [string]$ToolName,
        [hashtable]$Arguments
    )

    $payload = @{
        jsonrpc = "2.0"
        id      = 1
        method  = "tools/call"
        params  = @{
            name      = $ToolName
            arguments = $Arguments
        }
    } | ConvertTo-Json -Depth 10 -Compress

    $response = Invoke-WebRequest -Uri $ENDPOINT -Method POST `
        -ContentType "application/json" `
        -Headers @{ Accept = "application/json, text/event-stream" } `
        -Body $payload `
        -UseBasicParsing `
        -ErrorAction Stop

    return $response.Content
}

function Extract-Text {
    param([string]$Raw)

    # Remove SSE framing (event: message\ndata: prefix)
    $lines = $Raw -split "`n" | Where-Object {
        $_ -notmatch "^event:" -and $_.Trim() -ne ""
    } | ForEach-Object {
        $_ -replace "^data:\s*", ""
    }

    $json = $lines -join ""

    try {
        $parsed = $json | ConvertFrom-Json
        # Navigate to the text content in the JSON-RPC response
        if ($parsed.result -and $parsed.result.content) {
            foreach ($item in $parsed.result.content) {
                if ($item.type -eq "text") {
                    return $item.text
                }
            }
        }
    } catch {
        # Fallback: regex extraction if JSON parsing fails
        if ($json -match '"text"\s*:\s*"((?:[^"\\]|\\.)*)"}') {
            $text = $Matches[1]
            # Unescape JSON string
            $text = $text -replace '\\n', "`n"
            $text = $text -replace '\\"', '"'
            $text = $text -replace '\\\\', '\'
            $text = $text -replace '\\t', "`t"
            return $text
        }
    }

    return $json
}

function Get-CacheKey {
    param([string]$Input)
    $safe = $Input -replace '[^a-zA-Z0-9_-]', '_'
    if ($safe.Length -gt 80) { $safe = $safe.Substring(0, 80) }
    return $safe
}

# ── subcommands ──────────────────────────────────────────────────

function Invoke-Ask {
    param(
        [string]$Repo,
        [string]$Question
    )

    # Build repoName value
    if ($Repo.StartsWith("[")) {
        $repoValue = $Repo | ConvertFrom-Json
    } else {
        $repoValue = $Repo
    }

    # Check cache
    $cacheFile = $null
    if ($CACHE_DIR) {
        $key = Get-CacheKey "${Repo}__${Question}"
        $cacheFile = Join-Path $CACHE_DIR "${key}.md"
        if (Test-Path $cacheFile) {
            Write-Host "[DeepWiki] Cache hit: $cacheFile" -ForegroundColor DarkGray
            Get-Content $cacheFile -Raw
            return
        }
    }

    # Call with retry
    $arguments = @{
        repoName = $repoValue
        question = $Question
    }

    for ($i = 0; $i -lt $MAX_RETRIES; $i++) {
        try {
            $result = Call-MCP -ToolName "ask_question" -Arguments $arguments
        } catch {
            if ($_.Exception.Response.StatusCode -eq 429) {
                if ($i -lt ($MAX_RETRIES - 1)) {
                    $delay = $RETRY_DELAYS[$i]
                    Write-Host "[DeepWiki] 429 rate limited, retry in ${delay}s... (attempt $($i+2)/$MAX_RETRIES)" -ForegroundColor Yellow
                    Start-Sleep -Seconds $delay
                    continue
                } else {
                    Write-Error "[DeepWiki] Failed after $MAX_RETRIES attempts"
                    exit 1
                }
            }
            throw
        }

        if ($result -match "429 Too Many Requests") {
            if ($i -lt ($MAX_RETRIES - 1)) {
                $delay = $RETRY_DELAYS[$i]
                Write-Host "[DeepWiki] 429 rate limited, retry in ${delay}s... (attempt $($i+2)/$MAX_RETRIES)" -ForegroundColor Yellow
                Start-Sleep -Seconds $delay
                continue
            } else {
                Write-Error "[DeepWiki] Failed after $MAX_RETRIES attempts"
                exit 1
            }
        }

        $text = Extract-Text $result

        # Write to cache
        if ($CACHE_DIR -and $cacheFile) {
            if (-not (Test-Path $CACHE_DIR)) {
                New-Item -ItemType Directory -Path $CACHE_DIR -Force | Out-Null
            }
            $text | Out-File -FilePath $cacheFile -Encoding utf8
        }

        Write-Output $text
        return
    }

    Write-Error "[DeepWiki] Failed after $MAX_RETRIES attempts"
    exit 1
}

function Invoke-Structure {
    param([string]$Repo)

    $arguments = @{ repoName = $Repo }
    $result = Call-MCP -ToolName "read_wiki_structure" -Arguments $arguments
    Extract-Text $result
}

function Invoke-Contents {
    param([string]$Repo)

    $arguments = @{ repoName = $Repo }
    $result = Call-MCP -ToolName "read_wiki_contents" -Arguments $arguments
    Extract-Text $result
}

# ── main ─────────────────────────────────────────────────────────

function Show-Usage {
    Write-Host "Usage:" -ForegroundColor Red
    Write-Host "  $($MyInvocation.ScriptName) ask <owner/repo | '[`"repo1`",`"repo2`"]'> <question>"
    Write-Host "  $($MyInvocation.ScriptName) structure <owner/repo>"
    Write-Host "  $($MyInvocation.ScriptName) contents <owner/repo>"
    exit 1
}

switch ($Command) {
    "ask" {
        if (-not $Question) { Show-Usage }
        Invoke-Ask -Repo $Repo -Question $Question
    }
    "structure" {
        Invoke-Structure -Repo $Repo
    }
    "contents" {
        Invoke-Contents -Repo $Repo
    }
    default {
        Write-Host "Unknown command: $Command" -ForegroundColor Red
        Show-Usage
    }
}
