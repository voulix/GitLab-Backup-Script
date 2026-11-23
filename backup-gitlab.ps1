# =================== CONFIGURATION ===================
$GITLAB_HOST   = "gitlab.deinedomain.de"   # GitLab server without http(s)://
$GITLAB_TOKEN  = "hierbittedeinaccounttoken"    # Personal Access Token with read_api + read_repository
$PREFIX        = "C:\Pfad\Zum\Speichern\des\Backups"     # Target folder for backups
$EXCLUDE_REPOS = ""                     # Leave empty to backup all
$FETCH_PROTO   = "https"                # Using HTTPS + token
$GITLAB_USER   = "git"                  # User for HTTPS URLs
# ======================================================

# API base URL
$GITLAB_HTTP = "https://${GITLAB_HOST}/"
# Base for git clone over HTTPS with token (note the backtick before :)
$GITLAB_URL  = "${FETCH_PROTO}://${GITLAB_USER}`:${GITLAB_TOKEN}@${GITLAB_HOST}/"

# Ensure target folder exists
if (-not (Test-Path $PREFIX)) {
    New-Item -Path $PREFIX -ItemType Directory -Force | Out-Null
}

function Get-Repos {
    param([int]$PerPage = 100)
    $page = 1
    $allRepos = @()

    do {
        $url = "${GITLAB_HTTP}api/v4/projects?per_page=$PerPage&simple=1&membership=1&archived=0&page=$page"
        Write-Host "Loading repos (page $page)..."

        try {
            $response = Invoke-RestMethod -Uri $url -Headers @{ "Private-Token" = $GITLAB_TOKEN }
        }
        catch {
            Write-Host "Error calling GitLab API: $_" -ForegroundColor Red
            break
        }

        if ($null -ne $response -and $response.Count -gt 0) {
            $allRepos += $response.path_with_namespace
        }

        $page++
    } while ($response.Count -eq $PerPage)

    return $allRepos
}

function Backup-Repo {
    param(
        [string]$RemoteUrl,
        [string]$LocalPath
    )

    $parentDir = Split-Path $LocalPath -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if (Test-Path (Join-Path $LocalPath ".git")) {
        Write-Host "Repository exists - updating: $LocalPath"
        git -C $LocalPath fetch --all --prune
        git -C $LocalPath pull --all
    } else {
        Write-Host "Cloning: $RemoteUrl to $LocalPath"
        git clone $RemoteUrl $LocalPath
    }
}

# === Main ===
$repos = Get-Repos
Write-Host "Repositories found:" $repos.Count

# Save repo list to JSON
$repos | ConvertTo-Json | Set-Content -Path (Join-Path $PREFIX "repos.json")

# Process each repo
foreach ($r in $repos) {
    if ($EXCLUDE_REPOS -ne "" -and ($r -match $EXCLUDE_REPOS)) {
        Write-Host "# skipping repo: $r" -ForegroundColor Yellow
    } else {
        $remoteUrl = "${GITLAB_URL}${r}.git"
        $targetDir = Join-Path $PREFIX $r
        Backup-Repo -RemoteUrl $remoteUrl -LocalPath $targetDir
    }
}

# Check for deleted repos
Write-Host ""
Write-Host "Geklonte Repos:"
$existingDirs = Get-ChildItem -Path $PREFIX -Recurse -Directory
foreach ($dir in $existingDirs) {
    $relPath = $dir.FullName.Substring($PREFIX.Length + 1) -replace '\\','/'
    if (-not ($repos -contains $relPath)) {
        Write-Host $relPath -ForegroundColor Red
    }
}