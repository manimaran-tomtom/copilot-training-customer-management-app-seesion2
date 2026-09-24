# Customer Management API

[![](https://img.shields.io/badge/Create%20Repo-%E2%86%92-1f883d?style=for-the-badge&logo=github&labelColor=197935)](https://github.com/new?template_owner=epam-agent-forge&template_name=copilot-training-customer-management-app&owner=%40me&name=copilot-training-customer-management-app&description=A+simple+application+used+as+a+training+resource+in+conjunction+with+the+epam-agent-forge+training+materials&visibility=private)

A small, beginner-friendly **customer management API** built with **.NET Minimal APIs**, **Entity Framework Core**, and **SQLite**. It is designed as a clean starter project for a hands-on **GitHub Copilot agentic coding** training course.

The application currently supports a single business capability: **add a new customer**.

---

## 0. Templates — read this first (for agents)

> **📌 Standing instruction for any GitHub Copilot agent working in this repository.**
>
> This is a training project. Whenever you are asked to **create a new artifact of a kind that has a template** — for example a new custom agent — you **must** first read the matching template in [`training-resources/templates/`](training-resources/templates/) and follow its structure. Do not invent your own structure when a template exists.

The available templates are listed in the registry below. **This table is the source of truth** — whenever a new template is added to `training-resources/templates/`, add a row here in the same change so that every agent knows, from the very start of the project, exactly what templates exist and when to use them.

### Template registry

| Template | File | Use it when you are asked to… |
| --- | --- | --- |
| Custom agent | [`training-resources/templates/agent.template.md`](training-resources/templates/agent.template.md) | Create a new custom agent (a `*.agent.md` file, typically under `.github/agents/`). |
| Skill | [`training-resources/templates/skill.template/SKILL.md`](training-resources/templates/skill.template/SKILL.md) | Create a new project skill (a `SKILL.md` file under `.github/skills/<skill-name>/`). |

> **Adding a new template?** Drop the file into `training-resources/templates/`, then add a row to the table above describing what it is and when to reach for it. Keep the registry complete and current.

---

## 1. Project overview

This is a minimal HTTP API that lets you create customer records and store them in a local SQLite database file.

- **Framework:** .NET Minimal APIs (`.NET 10`)
- **Data access:** Entity Framework Core
- **Database:** SQLite (a real, on-disk file — data survives restarts)
- **API docs:** Swagger / OpenAPI, enabled automatically in development
- **Auth:** none yet (intentionally, to keep the demo simple)
- **Frontend:** placeholder only for future exercises — for now you drive the API through Swagger or `curl`

The current endpoints are:

```
POST /customers
GET /customers/{id}
```

- `POST /customers` accepts a JSON body with `firstName`, `lastName`, and `email`, validates them, saves the customer, and returns the created record including its generated `id`.
- `GET /customers/{id}` returns the matching customer when it exists, otherwise `404 Not Found`.

**Project structure**

```
.
├── CustomerManagement.slnx              # Solution file (.NET 10 XML format)
├── README.md
├── .gitignore
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   └── agent-task.yml               # GitHub issue form for autonomous agent tasks
│   ├── prompts/                         # Course prompt snippets used during the lessons
│   ├── scripts/
│   │   ├── agent_delivery.py            # Validates agent task handoffs and delivery boundaries
│   │   └── tests/
│   │       └── test_agent_delivery.py   # Unit tests for the delivery helper
│   ├── skills/
│   │   └── pull-main/
│   │       └── SKILL.md                 # Project skill for syncing a branch with main
│   └── workflows/
│       ├── agent-plan-implement.yml      # Agent task planning and implementation workflow
│       └── ci.yml                        # Pull request build-and-test workflow
├── frontend/                            # Empty placeholder reserved for future course exercises
│   ├── src/
│   │   └── .gitkeep
│   └── tests/
│       └── .gitkeep
├── backend/
│   ├── src/
│   │   └── CustomerManagement.Api/
│   │       ├── Program.cs                   # App startup + POST /customers endpoint
│   │       ├── Models/
│   │       │   ├── Customer.cs              # Customer entity
│   │       │   └── AddCustomerRequest.cs    # Request model + validation rules
│   │       ├── Data/
│   │       │   └── AppDbContext.cs          # EF Core DbContext
│   │       ├── Migrations/                  # EF Core migration (creates the schema)
│   │       ├── appsettings.json
│   │       └── appsettings.Development.json # SQLite connection string lives here
│   └── tests/
│       ├── CustomerManagement.UnitTests/
│       │   └── AddCustomerTests.cs          # xUnit test: a valid customer can be added
│       └── CustomerManagement.AcceptanceTests/  # SpecFlow.xUnit BDD acceptance tests
│           ├── Features/
│           │   └── CreateCustomer.feature   # Gherkin scenarios for POST /customers
│           ├── StepDefinitions/
│           │   └── CreateCustomerSteps.cs   # Step bindings
│           └── Support/                     # WebApplicationFactory + scenario state
├── training-resources/
│   └── templates/                       # Templates agents must follow (see section 0)
│       ├── agent.template.md            # Structure for new custom agents
│       └── skill.template/              # Structure for new agent skills (AgentSkills.io spec)
│           ├── SKILL.md
│           ├── scripts/
│           ├── references/
│           └── assets/
└── .config/
    └── dotnet-tools.json                # Local dotnet-ef tool (for migrations)
```

---

## 2. Prerequisites

You are expected to have the following installed **before** the course:

- **Git**
- **.NET SDK** (version 10.0 or later)
- **Visual Studio Code**
- **Access to GitHub Copilot**
- **The GitHub Copilot app**
- **SQLite tooling** (the `sqlite3` command-line tool)
- **Python 3** — required by pipx and Datasette (usually installed automatically alongside pipx on macOS)
- **pipx** — used to install Python tools in isolated environments
- **Datasette** — a web UI for browsing SQLite databases
- **A terminal or command-line shell**

> **Missing something?** You don't have to fix it by hand. Open the GitHub Copilot app, connect it to this repository, and paste the suggested prompt from section 10. The agent will check what is installed, ask your permission before installing anything, and get everything running for you.

### 2.1 Installing the prerequisites

Pick **one** of the three routes below and work through it top to bottom. Every route installs the same set of tools.

<details>
<summary><strong>Route A — macOS (Homebrew)</strong></summary>

If you don't have Homebrew yet, install it first by following the instructions at [brew.sh](https://brew.sh), then:

```bash
# Git
brew install git

# .NET SDK 10
brew install --cask dotnet-sdk

# Visual Studio Code
brew install --cask visual-studio-code

# SQLite command-line tool
brew install sqlite

# Python 3 and pipx (Homebrew pulls in Python as a dependency of pipx)
brew install python pipx
pipx ensurepath

# Datasette
pipx install datasette
```

The **GitHub Copilot app** is not on Homebrew — download it from
[github.com/features/ai/github-app](https://github.com/features/ai/github-app).

> **Notes for macOS**
> - macOS already ships with a `sqlite3` binary, so `brew install sqlite` is optional; it simply gives you a newer version.
> - After `pipx ensurepath`, open a **new** terminal window so the updated `PATH` takes effect.
> - If Homebrew's `dotnet-sdk` cask is behind the 10.0 release, use the official installer from the manual route below instead.

</details>

<details>
<summary><strong>Route B — Windows (winget)</strong></summary>

`winget` ships with Windows 10 (1809+) and Windows 11. If it's missing, see the
[winget documentation](https://learn.microsoft.com/en-us/windows/package-manager/winget/).
Run these in **PowerShell**:

```powershell
# Git
winget install --id Git.Git -e

# .NET SDK 10
winget install --id Microsoft.DotNet.SDK.10 -e

# Visual Studio Code
winget install --id Microsoft.VisualStudioCode -e

# SQLite command-line tools
winget install --id SQLite.SQLite -e

# Python 3
winget install --id Python.Python.3.13 -e

# GitHub Copilot app
winget install --id GitHub.CopilotApp -e
```

Then close and reopen PowerShell so the new tools are on your `PATH`, and install the Python tooling:

```powershell
py -m pip install --user pipx
py -m pipx ensurepath
```

Close and reopen PowerShell once more, then:

```powershell
pipx install datasette
```

> **Notes for Windows**
> - `-e` means "exact ID match", which stops winget picking a similarly named package.
> - If `winget install --id GitHub.CopilotApp -e` reports that no package was found, download the app manually from [github.com/features/ai/github-app](https://github.com/features/ai/github-app).
> - Use `winget search python.python` if you'd prefer a different Python 3 minor version.

</details>

<details>
<summary><strong>Route C — Manual download from the official websites</strong></summary>

Download and run each installer in the order listed. Everything except Datasette has a
graphical installer.

| # | Tool | Download page |
| --- | --- | --- |
| 1 | Git | <https://git-scm.com/downloads> |
| 2 | .NET SDK 10.0 | <https://dotnet.microsoft.com/download/dotnet/10.0> |
| 3 | Visual Studio Code | <https://code.visualstudio.com/download> |
| 4 | SQLite command-line tools | <https://www.sqlite.org/download.html> |
| 5 | Python 3 | <https://www.python.org/downloads/> |
| 6 | pipx | <https://pipx.pypa.io/stable/> |
| 7 | Datasette | <https://docs.datasette.io/en/stable/installation.html> |
| 8 | GitHub Copilot app | <https://github.com/features/ai/github-app> |
| 9 | GitHub Copilot plan | <https://github.com/features/copilot> |

Once Python 3 is installed, finish off pipx and Datasette from a terminal:

```bash
python3 -m pip install --user pipx
python3 -m pipx ensurepath
# open a new terminal, then:
pipx install datasette
```

> **Notes for the manual route**
> - On the SQLite page, choose the **"Precompiled Binaries"** bundle for your operating system that includes the `sqlite3` command-line shell, then add the extracted folder to your `PATH`.
> - On Windows, tick **"Add python.exe to PATH"** in the Python installer.
> - You need an active Copilot plan (or your own model provider) before the Copilot app will do any work — see the [Copilot app quickstart](https://docs.github.com/en/copilot/get-started/quickstart-copilot-app).

</details>

### 2.2 First run: signing in to the GitHub Copilot app

Downloading the GitHub Copilot app isn't quite enough — open it once and complete the initial
setup before the course starts:

1. Launch the app and click **Sign in to GitHub**, then follow the prompts to authenticate. If
   you use GitHub Enterprise Server, choose **Use GitHub Enterprise** and enter your server
   address.
2. If you don't have a Copilot plan, choose whether to sign up for one or continue with your own
   model provider (which needs provider credentials such as an API key).
3. When prompted, pick one or more repositories to connect. You can skip this and add projects
   later — you'll connect this repository during the course.
4. Choose your preferred **theme** and finish the onboarding flow.

You should end up looking at the app's main window with the sidebar visible. For more detail, see
the [GitHub Copilot app quickstart](https://docs.github.com/en/copilot/get-started/quickstart-copilot-app).

### 2.3 Verifying the installation

Whichever route you took, open a **new** terminal and confirm each tool responds:

```bash
git --version
dotnet --version      # expect 10.0 or later
code --version
sqlite3 --version
python3 --version     # on Windows: py --version
pipx --version
datasette --version
```

If any command reports "not found", revisit that tool in your chosen route above — or ask the
GitHub Copilot app to sort it out for you using the prompt in section 10.

---

## 3. Agent setup instructions

> **This section is written for a GitHub Copilot coding agent.** A student can simply ask the agent to "follow the Agent setup instructions in the README" and the application should end up running. Follow these steps in order.

1. **Inspect the repository structure.** List the files and folders and read this README so you understand the layout described in section 1.

2. **Confirm the required tools are installed.** Run the checks in the following steps. If any tool is missing, tell the student what is missing and ask their permission before installing anything.

3. **Check that Git is available:**
   ```bash
   git --version
   ```

4. **Check that the .NET SDK is available** (expect 10.0 or later):
   ```bash
   dotnet --version
   ```

5. **Check that Visual Studio Code is available:**
   ```bash
   code --version
   ```

6. **Check that SQLite tooling is available:**
   ```bash
   sqlite3 --version
   ```

7. **Check that pipx is available:**
   ```bash
   pipx --version
   ```
   If `pipx` is not found, ask the student: *"pipx is not installed. It is needed to install Datasette. May I install it now using Homebrew (`brew install pipx`)? Please confirm yes or no."* Only proceed if the student confirms. Install with:
   ```bash
   brew install pipx && pipx ensurepath
   ```

8. **Check that Datasette is available:**
   ```bash
   datasette --version || ~/.local/bin/datasette --version
   ```
   If `datasette` is not found, ask the student: *"Datasette is not installed. It is used to browse the SQLite database in a web UI. May I install it now using `pipx install datasette`? Please confirm yes or no."* Only proceed if the student confirms. Install with:
   ```bash
   pipx install datasette
   ```
   After installing, verify: `~/.local/bin/datasette --version`.

9. **Restore NuGet packages** (this also restores the local `dotnet-ef` tool):
   ```bash
   dotnet tool restore
   dotnet restore
   ```

10. **Build the solution:**
    ```bash
    dotnet build
    ```

11. **Run the automated test suite:**
    ```bash
    dotnet test
    ```

12. **Create or update the SQLite database.** Apply the EF Core migration to create the local `customers.db` file and its schema:
    ```bash
    dotnet ef database update --project backend/src/CustomerManagement.Api
    ```
    > Note: the API also applies migrations automatically on startup in development, so this step is optional — but running it explicitly is a good way to confirm the database is set up correctly.

13. **Run the API** in one terminal:
    ```bash
    dotnet run --project backend/src/CustomerManagement.Api
    ```
    The API listens on **http://localhost:5154**.

14. **Start Datasette** in a separate terminal so the student can browse the database:
    ```bash
    datasette serve backend/src/CustomerManagement.Api/customers.db --port 8001
    ```
    > If `datasette` is not on `PATH`, use `~/.local/bin/datasette serve ...` instead.

    Datasette will be available at **http://localhost:8001**. The Customers table is at:
    ```
    http://localhost:8001/customers/Customers
    ```

15. **Open or provide the Swagger URL.** Share this link with the student:
    ```
    http://localhost:5154/swagger
    ```

16. **Explain how to send a sample `POST /customers` request.** Show the student how to add a customer from Swagger (section 7) or with `curl`:
    ```bash
    curl -X POST http://localhost:5154/customers \
      -H "Content-Type: application/json" \
      -d '{"firstName":"Ada","lastName":"Lovelace","email":"ada@example.com"}'
    ```
    After adding a customer, tell the student to refresh the Datasette tab at `http://localhost:8001/customers/Customers` to see the new record appear.

---

## 4. Getting started manually

If you prefer to set the project up yourself instead of asking the agent:

```bash
# 1. Restore the local dotnet-ef tool and NuGet packages
dotnet tool restore
dotnet restore

# 2. Build
dotnet build

# 3. Run the tests
dotnet test

# 4. Create the SQLite database (optional — also happens on startup)
dotnet ef database update --project backend/src/CustomerManagement.Api

# 5. Run the API
dotnet run --project backend/src/CustomerManagement.Api
```

---

## 5. Running the API

```bash
dotnet run --project backend/src/CustomerManagement.Api
```

- The API starts on **http://localhost:5154**.
- In development it applies any pending database migrations at startup, so the database is always ready.
- Press **Ctrl+C** to stop it.

---

## 6. Using Swagger

Swagger UI is enabled automatically in development. With the API running, open:

```
http://localhost:5154/swagger
```

From there you can see the `POST /customers` endpoint, view the expected request/response shapes, and send requests directly from the browser.

---

## 7. Adding a customer

Using **Swagger**:

1. Open http://localhost:5154/swagger.
2. Expand **POST /customers** and click **Try it out**.
3. Enter a request body, for example:
   ```json
   {
     "firstName": "Ada",
     "lastName": "Lovelace",
     "email": "ada@example.com"
   }
   ```
4. Click **Execute**.

**Successful response — `201 Created`:**
```json
{
  "id": 1,
  "firstName": "Ada",
  "lastName": "Lovelace",
  "email": "ada@example.com"
}
```

**Validation rules** (all fields are required; email must be a valid email address). A bad request returns **`400 Bad Request`** with details, for example:
```json
{
  "title": "One or more validation errors occurred.",
  "status": 400,
  "errors": {
    "Email": ["The Email field is not a valid e-mail address."]
  }
}
```

Using **curl**:
```bash
curl -X POST http://localhost:5154/customers \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Ada","lastName":"Lovelace","email":"ada@example.com"}'
```

---

## 8. Database setup

- The database is **SQLite**, stored in a local file named **`customers.db`** inside `backend/src/CustomerManagement.Api/` (created when you first run the API or apply the migration).
- The connection string is configured in **`backend/src/CustomerManagement.Api/appsettings.Development.json`**:
  ```json
  {
    "ConnectionStrings": {
      "Default": "Data Source=customers.db"
    }
  }
  ```
- The schema is created by an **EF Core migration** (`Migrations/`), which is checked into the repository. You never have to create tables by hand.
- Apply the migration explicitly with:
  ```bash
  dotnet ef database update --project backend/src/CustomerManagement.Api
  ```
- **For convenience during training, the API also applies migrations automatically on startup in development** (`db.Database.Migrate()` in `Program.cs`). This is a deliberate choice to keep the demo simple — in a production application you would typically apply migrations as an explicit, controlled step rather than on every startup.
- The database is a **real, persistent file**, not an in-memory database, so customers you add remain after you restart the app. To start fresh, delete `backend/src/CustomerManagement.Api/customers.db` and run the app again.

---

## 9. Useful commands

| Task | Command |
| --- | --- |
| Restore local tools (`dotnet-ef`) | `dotnet tool restore` |
| Restore NuGet packages | `dotnet restore` |
| Build | `dotnet build` |
| Run tests | `dotnet test` |
| Apply/create the database | `dotnet ef database update --project backend/src/CustomerManagement.Api` |
| Run the API | `dotnet run --project backend/src/CustomerManagement.Api` |
| Add a new migration (after changing the model) | `dotnet ef migrations add <Name> --project backend/src/CustomerManagement.Api` |
| Inspect the database via CLI | `sqlite3 backend/src/CustomerManagement.Api/customers.db ".tables"` |
| Browse the database in Datasette | `datasette serve backend/src/CustomerManagement.Api/customers.db --port 8001` |
| Install Datasette | `pipx install datasette` |

---

## 10. Suggested first prompt for students

Open the GitHub Copilot app, connect it to this repository, and paste this prompt:

> I am new to this repository. Please read the README, inspect the project structure, follow the Agent setup instructions, check the prerequisites, restore the project, set up the SQLite database, run the API, start Datasette so I can browse the database, and show me how to add a customer using Swagger.

---

## 11. Troubleshooting

- **`dotnet: command not found`** — the .NET SDK isn't installed or isn't on your `PATH`. Ask the Copilot agent to help you install the .NET SDK, or download it from https://dotnet.microsoft.com/download.
- **`dotnet ef` isn't recognised** — run `dotnet tool restore` first; the `dotnet-ef` tool is defined locally in `.config/dotnet-tools.json`.
- **`sqlite3: command not found`** — the SQLite command-line tooling isn't installed. It's only needed for inspecting the database directly; the API itself does not require it. Ask the agent to help you install it.
- **`'0xE2' is an invalid start of a value` / "Failed to read parameter ... from the request body as JSON"** — your request body is not valid JSON. Some editors and macOS (System Settings → Keyboard → Text Input → "Use smart quotes") replace straight quotes (`"`) with **smart/curly quotes** (`“ ”`); the API normalises those common quote characters before parsing, but other malformed JSON still returns a clear 400 message. Retype the JSON using straight double quotes, e.g. `{"firstName": "Ada", "lastName": "Lovelace", "email": "ada@example.com"}`.
- **Port 5154 is already in use** — another process is using the port. Stop that process, or change the port in `backend/src/CustomerManagement.Api/Properties/launchSettings.json`.
- **Swagger page doesn't load** — make sure the API is running and that you are in the Development environment (the default when using `dotnet run`). Swagger is only enabled in development.
- **Want to reset the data** — stop the API and delete `backend/src/CustomerManagement.Api/customers.db`, then run the app again to recreate an empty database.
- **`datasette: command not found`** — Datasette isn't installed or isn't on `PATH`. Try `~/.local/bin/datasette`. If that also fails, ask the agent to install it with `pipx install datasette`.
- **Datasette shows no rows** — make sure the API has been started at least once (so the migration runs and `customers.db` is created) and that you've added at least one customer. Refresh the Datasette page after adding records.
- **Port 8001 is already in use** — another Datasette process may still be running. Find its PID with `lsof -i :8001` and stop it, or start Datasette on a different port with `--port 8002`.
- **Still stuck?** Ask the GitHub Copilot agent: *"The setup isn't working — please check my environment against the README prerequisites and help me fix it."*

---

## 12. Project conventions for agent primitives

This repository is a GitHub Copilot training project. As you work through the course,
you may create **agent primitives** — Copilot **skills**, custom **agents**, **prompt
files**, and similar reusable building blocks.

Keep project-specific primitives in the repository using the directory conventions
below. Manage them alongside the application code through the normal GitHub workflow:
branches, commits, pushes, and pull requests, using the GitHub Copilot app with the
repository on GitHub.com.

| Primitive | Repository path |
| --- | --- |
| Skills | `.github/skills/<skill-name>/SKILL.md` |
| Agents | `.github/agents/` |
| Prompt files | `.github/prompts/` |

Guidelines:

- **One folder per skill.** Each skill lives in its own directory under `.github/skills/`
  and contains a `SKILL.md` with YAML frontmatter (`name`, `description`) followed by the
  instructions. The `name` in the frontmatter must match the folder name.
- **Use the GitHub Copilot paths above**, not the newer cross-editor `.agents/` convention,
  so the Copilot app picks primitives up out of the box.
