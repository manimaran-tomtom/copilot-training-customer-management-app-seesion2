#!/usr/bin/env pwsh
#
# set-branch-ruleset.ps1
#
# Creates or updates the branch ruleset that protects the default branch of
# this repository, and wires up the required status check produced by the
# "Pull Request CI" workflow (.github/workflows/ci.yml).
#
# This exists because the GitHub web UI's "Add checks" picker is a typeahead
# over check runs it has already *observed* on the repo — it does not read the
# workflow YAML. On a repo where the workflow has never run (no PRs yet), the
# check name is unfindable in the UI. The REST API has no such restriction and
# accepts an arbitrary context name, so this script can configure the gate
# before the first pipeline run.
#
# The ruleset applies:
#   - deletion            — the branch cannot be deleted
#   - non_fast_forward    — no force pushes
#   - pull_request        — changes must arrive via PR
#   - required_status_checks — the CI job must pass before merge
#
# The status check is pinned to the GitHub Actions app so a third-party app
# cannot satisfy the gate by reporting a check of the same name.
#
# The script is idempotent: it looks up the ruleset by name, creates it if
# absent, and replaces it in full if present. Re-running is safe.
#
# Usage:
#   pwsh ./scripts/set-branch-ruleset.ps1                    # create or update
#   pwsh ./scripts/set-branch-ruleset.ps1 -DryRun            # print payload, no API calls
#   pwsh ./scripts/set-branch-ruleset.ps1 -Strict            # also require branches be up to date
#   pwsh ./scripts/set-branch-ruleset.ps1 -RequiredApprovals 1
#
# Requirements:
#   - PowerShell 7+ (pwsh) — https://aka.ms/powershell
#   - GitHub CLI (`gh`) installed and authenticated (`gh auth login`)
#   - Admin permission on the repository
#   - Run from anywhere inside the repo (script resolves the repo automatically)

[CmdletBinding()]
param(
    [string]$RulesetName = 'default-branch-gate',
    [string[]]$StatusCheck = @('build-and-test'),
    [int]$RequiredApprovals = 0,
    [switch]$Strict,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error "GitHub CLI ('gh') is not installed. Install it from https://cli.github.com/"
    exit 1
}

gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "gh is not authenticated. Run 'gh auth login' first."
    exit 1
}

$Repo = gh repo view --json nameWithOwner --jq .nameWithOwner

# App id 15368 is GitHub Actions. Resolved at runtime rather than hardcoded so
# the script still works against GitHub Enterprise Server, where it differs.
$ActionsAppId = [int](gh api apps/github-actions --jq .id)

Write-Host "Repository:   $Repo"
Write-Host "Ruleset:      $RulesetName"
Write-Host "Status checks: $($StatusCheck -join ', ') (app id $ActionsAppId)"

$payload = [ordered]@{
    name          = $RulesetName
    target        = 'branch'
    enforcement   = 'active'
    bypass_actors = @()
    conditions    = [ordered]@{
        ref_name = [ordered]@{
            include = @('~DEFAULT_BRANCH')
            exclude = @()
        }
    }
    rules         = @(
        [ordered]@{ type = 'deletion' }
        [ordered]@{ type = 'non_fast_forward' }
        [ordered]@{
            type       = 'pull_request'
            parameters = [ordered]@{
                required_approving_review_count   = $RequiredApprovals
                dismiss_stale_reviews_on_push     = $false
                required_reviewers                = @()
                require_code_owner_review         = $false
                require_last_push_approval        = $false
                required_review_thread_resolution = $false
                allowed_merge_methods             = @('merge', 'squash', 'rebase')
            }
        }
        [ordered]@{
            type       = 'required_status_checks'
            parameters = [ordered]@{
                strict_required_status_checks_policy = [bool]$Strict
                do_not_enforce_on_create             = $false
                required_status_checks               = @(
                    $StatusCheck | ForEach-Object {
                        [ordered]@{ context = $_; integration_id = $ActionsAppId }
                    }
                )
            }
        }
    )
}

# Depth 10 is needed: rules -> parameters -> required_status_checks -> object.
$json = $payload | ConvertTo-Json -Depth 10

if ($DryRun) {
    Write-Host "----------------------------------------"
    Write-Host "[dry-run] No API calls will be made. Payload:"
    Write-Host $json
    exit 0
}

$existingId = gh api "repos/$Repo/rulesets" --jq "map(select(.name == `"$RulesetName`")) | .[0].id // empty"

$tempFile = New-TemporaryFile
try {
    # -NoNewline avoids a trailing newline that some gh versions reject.
    Set-Content -Path $tempFile -Value $json -Encoding utf8 -NoNewline

    if ([string]::IsNullOrWhiteSpace($existingId)) {
        Write-Host "No ruleset named '$RulesetName' found — creating it."
        $result = gh api -X POST "repos/$Repo/rulesets" --input $tempFile
    }
    else {
        # PUT is a full replacement, not a merge: every rule to keep must be
        # present in the payload above, or it is silently dropped.
        Write-Host "Ruleset '$RulesetName' exists (id $existingId) — updating it."
        $result = gh api -X PUT "repos/$Repo/rulesets/$existingId" --input $tempFile
    }
}
finally {
    Remove-Item $tempFile -ErrorAction SilentlyContinue
}

$applied = $result | ConvertFrom-Json
Write-Host "----------------------------------------"
Write-Host "Ruleset applied: id $($applied.id), enforcement '$($applied.enforcement)'"
Write-Host "Rules: $(($applied.rules | ForEach-Object { $_.type }) -join ', ')"
Write-Host "View: https://github.com/$Repo/rules/$($applied.id)"
Write-Host ""
Write-Host "Note: a required check that never reports leaves PRs pending forever."
Write-Host "      Ensure '$($StatusCheck -join ', ')' runs on every PR targeting the default branch."
