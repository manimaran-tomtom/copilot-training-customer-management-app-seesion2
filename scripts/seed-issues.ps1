#!/usr/bin/env pwsh
#
# seed-issues.ps1
#
# Creates the "Update customer", "Add product — API and unit tests",
# "Delete customer — API and unit tests", and "Get product — API and unit
# tests" agent-task issues in this repository, following the format of
# .github/ISSUE_TEMPLATE/agent-task.yml. The "Add product" and "Delete
# customer" issues are development-only (API + unit tests) by design;
# acceptance tests for them are left for future issues.
# The "Get product" issue depends on "Add product" being merged and is reserved
# for the plan-to-implementation workflow exercise.
#
# It also creates a "List customers" issue that intentionally does NOT follow
# the template — vague, unlabeled, and missing the context/success-criteria an
# agent needs to work autonomously. This is a deliberate example of a
# low-quality, off-template issue someone might add to the board directly, to
# demonstrate what NOT to do.
#
# This is the PowerShell equivalent of seed-issues.sh, intended to run
# unmodified on macOS, Linux, and Windows via PowerShell 7+ (pwsh).
#
# Usage:
#   pwsh ./scripts/seed-issues.ps1              # creates all five issues
#   pwsh ./scripts/seed-issues.ps1 -DryRun      # prints what would be created, no API calls
#
# Requirements:
#   - PowerShell 7+ (pwsh) — https://aka.ms/powershell
#   - GitHub CLI (`gh`) installed and authenticated (`gh auth login`)
#   - Run from anywhere inside the repo (script resolves the repo automatically)

[CmdletBinding()]
param(
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
$Label = 'agent-task'
$script:LastIssueNumber = $null

Write-Host "Repository: $Repo"

function Ensure-Label {
    $existingLabels = gh label list --repo $Repo --json name --jq '.[].name'
    if ($existingLabels -notcontains $Label) {
        Write-Host "Label '$Label' not found — creating it."
        if (-not $DryRun) {
            gh label create $Label `
                --repo $Repo `
                --description "Task defined for an AI coding agent to implement" `
                --color "5319E7"
        }
    }
}

function Create-Issue {
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][string]$Body
    )

    Write-Host "----------------------------------------"
    Write-Host "Creating issue: $Title"

    if ($DryRun) {
        Write-Host "[dry-run] Title: $Title"
        Write-Host "[dry-run] Body:"
        Write-Host $Body
        $script:LastIssueNumber = "<dry-run-issue-number>"
        return
    }

    $url = gh issue create `
        --repo $Repo `
        --title $Title `
        --label $Label `
        --body $Body
    Write-Host "Created: $url"
    $script:LastIssueNumber = $url.Split('/')[-1]
}

Ensure-Label

# ---------------------------------------------------------------------------
# Issue 1: Update customer
# ---------------------------------------------------------------------------
$UpdateBody = @'
### Context and inputs

- Related issue/PR: none — this is the next endpoint to add after `POST /customers` (Add) and `GET /customers/{id}` (Get)
- Starting point (branch, files, or module):
  - `backend/src/CustomerManagement.Api/Program.cs` — existing minimal API endpoints (`AddCustomer`, `GetCustomer`)
  - `backend/src/CustomerManagement.Api/Models/Customer.cs` and `Models/AddCustomerRequest.cs`
  - `backend/src/CustomerManagement.Api/Data/AppDbContext.cs`
  - `backend/tests/CustomerManagement.UnitTests/` (xUnit)
  - `backend/tests/CustomerManagement.AcceptanceTests/` (SpecFlow — `Features/`, `StepDefinitions/`, `Support/`)
- Constraints (frameworks, versions, style rules):
  - .NET minimal APIs (no controllers) — follow the existing endpoint style in `Program.cs`
  - EF Core with SQLite via `AppDbContext`
  - Reuse the existing `DataAnnotations` validation pattern (see `AddCustomerRequest`) for the update request body
  - Unit tests: xUnit, following the style/naming in `AddCustomerTests.cs` / `GetCustomerTests.cs`
  - Acceptance tests: SpecFlow Gherkin feature file + step definitions, following the style of `CreateCustomer.feature` / `GetCustomer.feature` and their step definitions
- Relevant background/context:
  - The API currently supports Add and Get only. Update and Delete are explicitly called out in the Swagger description as "Not included (yet)".
  - A customer has three editable fields: `firstName`, `lastName`, `email` (all required, `email` must be a valid email format).

### Expected outputs

- Plan: a written plan describing the approach, posted for review before/with the PR
- Pull request: implements `PUT /customers/{id}`, targets the correct branch, references this issue
- Evidence: `dotnet test` output for both `CustomerManagement.UnitTests` and `CustomerManagement.AcceptanceTests` showing all new and existing tests passing

### Success criteria

- Correct behaviour:
  - `PUT /customers/{id}` updates `firstName`, `lastName`, and `email` on an existing customer and returns `200 OK` with the updated customer record.
  - Returns `404 Not Found` if no customer with the given `id` exists.
  - Returns `400 Bad Request` with a validation problem if any field is missing or invalid (same validation approach as `POST /customers`).
  - Existing `POST /customers` and `GET /customers/{id}` behaviour is unchanged.
- Required checks: CI green (`dotnet test` for both test projects), no build warnings introduced
- Review/scan outcomes required: code review approval
- Explicitly NOT sufficient: "tests pass" alone — the PR must include both unit tests (success, not-found, validation-failure cases) AND acceptance tests (Gherkin scenarios exercising the endpoint end-to-end via `CustomerApiFactory`)

'@

Create-Issue -Title "[Agent Task]: Update customer" -Body $UpdateBody

# ---------------------------------------------------------------------------
# Issue 1b: Add product — API and unit tests
# ---------------------------------------------------------------------------
$AddProductBody = @'
### Context and inputs

- Related issue/PR: none — this introduces a new `Product` entity and its first endpoint, following the same pattern used for `Customer`
- Starting point (branch, files, or module):
  - `backend/src/CustomerManagement.Api/Program.cs` — existing minimal API endpoints (`AddCustomer`, `GetCustomer`) as the style reference
  - `backend/src/CustomerManagement.Api/Models/Customer.cs` and `Models/AddCustomerRequest.cs` — reference for how entity/DTO pairs are structured and documented
  - `backend/src/CustomerManagement.Api/Data/AppDbContext.cs` — will need a new `DbSet<Product>`
  - `backend/tests/CustomerManagement.UnitTests/` (xUnit) — reference `AddCustomerTests.cs` for style/naming
- Constraints (frameworks, versions, style rules):
  - .NET minimal APIs (no controllers) — follow the existing endpoint style in `Program.cs`
  - EF Core with SQLite via `AppDbContext`; add a new EF Core migration for the `Product` table
  - Keep DTO and entity separate (`AddProductRequest` input DTO, `Product` entity/response), same as `AddCustomerRequest`/`Customer`
  - Use Data Annotations for validation on the request DTO (no duplicated validation logic in the handler)
  - Document the endpoint fully for Swagger (`.WithName()`, `.WithTags()`, `.WithSummary()`, `.WithDescription()`, `.Produces<T>()`, `.ProducesValidationProblem()`), and add XML doc comments to model properties
- Relevant background/context:
  - A product has three fields: `name` (string, required), `description` (string, optional), and `price` (decimal, required, must be greater than 0).
  - This issue is development only (endpoint implementation + unit tests + migration). Acceptance/automation tests are explicitly out of scope and will be handled by a separate follow-up issue.

### Expected outputs

- Plan: a written plan describing the approach, posted for review before/with the PR
- Pull request: implements `POST /products`, adds the `Product` model/entity, DbSet, and EF Core migration, targets the correct branch, references this issue
- Evidence: `dotnet test` output for `CustomerManagement.UnitTests` showing all new and existing tests passing

### Success criteria

- Correct behaviour:
  - `POST /products` creates a new product and returns `201 Created` with the created product record (including its generated `id`).
  - Returns `400 Bad Request` with a validation problem if `name` is missing, or `price` is missing or not greater than 0.
  - Existing `POST /customers`, `GET /customers/{id}` behaviour is unchanged.
- Required checks: CI green (`dotnet test` for `CustomerManagement.UnitTests`), no build warnings introduced
- Review/scan outcomes required: code review approval
- Explicitly NOT sufficient: "tests pass" alone — the PR must include unit tests covering the success case and each validation-failure case. Acceptance/automation tests are explicitly out of scope for this issue.

'@

Create-Issue -Title "[Agent Task]: Add product — API and unit tests" -Body $AddProductBody
$AddProductIssue = $script:LastIssueNumber

# ---------------------------------------------------------------------------
# Issue 2: Delete customer — API and unit tests
# ---------------------------------------------------------------------------
$DeleteDevBody = @'
### Context and inputs

- Related issue/PR: none — this is the next endpoint to add after `POST /customers` (Add) and `GET /customers/{id}` (Get)
- Starting point (branch, files, or module):
  - `backend/src/CustomerManagement.Api/Program.cs` — existing minimal API endpoints (`AddCustomer`, `GetCustomer`)
  - `backend/src/CustomerManagement.Api/Models/Customer.cs`
  - `backend/src/CustomerManagement.Api/Data/AppDbContext.cs`
  - `backend/tests/CustomerManagement.UnitTests/` (xUnit)
- Constraints (frameworks, versions, style rules):
  - .NET minimal APIs (no controllers) — follow the existing endpoint style in `Program.cs`
  - EF Core with SQLite via `AppDbContext`
  - Unit tests: xUnit, following the style/naming in `AddCustomerTests.cs` / `GetCustomerTests.cs`
- Relevant background/context:
  - The API currently supports Add and Get only. Update and Delete are explicitly called out in the Swagger description as "Not included (yet)".
  - This issue covers development only (the endpoint implementation and unit tests). Acceptance/automation tests are handled by a separate follow-up issue that depends on this one.

### Expected outputs

- Plan: a written plan describing the approach, posted for review before/with the PR
- Pull request: implements `DELETE /customers/{id}`, targets the correct branch, references this issue
- Evidence: `dotnet test` output for `CustomerManagement.UnitTests` showing all new and existing tests passing

### Success criteria

- Correct behaviour:
  - `DELETE /customers/{id}` removes the customer with the given `id` and returns `204 No Content` on success.
  - Returns `404 Not Found` if no customer with the given `id` exists.
  - A subsequent `GET /customers/{id}` for a deleted customer returns `404 Not Found`.
  - Existing `POST /customers` and `GET /customers/{id}` behaviour is unchanged.
- Required checks: CI green (`dotnet test` for `CustomerManagement.UnitTests`), no build warnings introduced
- Review/scan outcomes required: code review approval
- Explicitly NOT sufficient: "tests pass" alone — the PR must include unit tests (successful delete, not-found case). Acceptance/automation tests are explicitly out of scope for this issue.

'@

Create-Issue -Title "[Agent Task]: Delete customer — API and unit tests" -Body $DeleteDevBody

# ---------------------------------------------------------------------------
# Issue 3: List customers (intentionally off-template — no labels, no context,
# no success criteria, no boundaries. This is what a rushed, informal issue
# looks like when the agent-task template isn't followed.)
# ---------------------------------------------------------------------------
$ListBody = "can we get an endpoint to list all the customers? shouldn't be a big deal, just add it whenever"

Write-Host "----------------------------------------"
Write-Host "Creating issue: List customers"

if ($DryRun) {
    Write-Host "[dry-run] Title: List customers"
    Write-Host "[dry-run] Body:"
    Write-Host $ListBody
    Write-Host "[dry-run] Labels: (none — intentionally off-template)"
}
else {
    $url = gh issue create `
        --repo $Repo `
        --title "List customers" `
        --body $ListBody
    Write-Host "Created: $url"
}

# ---------------------------------------------------------------------------
# Issue 4: Get product — API and unit tests (depends on 1b)
# ---------------------------------------------------------------------------
$GetProductBodyTemplate = @'
### 1. Context and Inputs

- **Background:** After #__ADD_PRODUCT_ISSUE__ is implemented and merged, products can be created with `POST /products`, but there is no endpoint for retrieving a product by its identifier. This task is reserved for the plan-to-implementation workflow exercise; do not implement it before that exercise.
- **Prerequisite:** Depends on #__ADD_PRODUCT_ISSUE__ — the product entity, database migration, creation endpoint, and unit tests must be merged first.
- **Starting point:**
  - `backend/src/CustomerManagement.Api/Program.cs`
  - `backend/src/CustomerManagement.Api/Models/Product.cs`
  - `backend/src/CustomerManagement.Api/Data/AppDbContext.cs`
  - `backend/tests/CustomerManagement.UnitTests/AddProductTests.cs`
- **Constraints:** Use .NET Minimal APIs and EF Core/SQLite, following the existing `GET /customers/{id}` pattern and product conventions. Add complete Swagger metadata. No controllers, schema changes, EF migration, acceptance tests, or unrelated refactoring. Existing endpoints must remain unchanged.

### 2. Expected Outputs

- **Plan:** A written implementation plan produced before code changes and carried into the implementation phase.
- **Pull request:** Implement `GET /products/{id}` and its xUnit unit tests against `main`, using the repository PR template with meaningful Plan and Evidence sections.
- **Evidence:** Passing `CustomerManagement.UnitTests` output covering the new behaviour and existing tests.

### 3. Success Criteria

- `GET /products/{id}` returns `200 OK` with the matching product, including `id`, `name`, optional `description`, and `price`.
- It returns `404 Not Found` when no product has the supplied identifier.
- The endpoint includes `.WithName()`, `.WithTags()`, `.WithSummary()`, `.WithDescription()`, `.Produces<Product>()`, and the documented `404` response.
- Unit tests cover both found and not-found cases.
- Existing customer and product-creation behaviour remains unchanged.
- The relevant unit-test project passes with no new build warnings.
- Acceptance/SpecFlow changes, a database migration, and merely reporting "tests pass" without the required behavioural coverage are explicitly insufficient.

'@
$GetProductBody = $GetProductBodyTemplate -replace '__ADD_PRODUCT_ISSUE__', $AddProductIssue

Create-Issue -Title "[Agent Task]: Get product — API and unit tests" -Body $GetProductBody

Write-Host "----------------------------------------"
Write-Host "Done."
