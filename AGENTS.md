\# AGENTS — Starter Blueprint for Codex CLI

This file declares your operators ("agents") for OpenAI \*\*Codex CLI\*\* and the rules of engagement. Drop this file in the \*\*root of your workspace\*\* (e.g., `C:\\work\\simiriki`).

> Tip: After saving, run `codex /status` to confirm Codex sees \*\*AGENTS files\*\*.

---

\## Global Policy

\* \*\*Approval mode\*\*: default `never` (agent may act without prompts). Override per-agent in \*\*Approvals\*\* below.

\* \*\*Sandbox\*\*: `danger-full-access` unless overridden per-task.

\* \*\*Identity\*\*: Operate as `jjdlrmex\_1@outlook.com` unless a task specifies otherwise.

\* \*\*Model\*\*: `gpt-5` with Reasoning Effort: High.

\* \*\*Guardrails\*\*: Agents must:

&nbsp; \* Log all shell commands before execution.

&nbsp; \* Fail \*\*closed\*\* on missing secrets (do not guess).

&nbsp; \* Never hard‑code API keys into files; use environment variables or Azure Key Vault references.

---

\## Required Tooling on Host

\* \*\*PowerShell 7+\*\* (Windows).

\* \*\*Azure CLI\*\* (`az`) signed in to the correct tenant/subscription.

\* \*\*Docker Desktop\*\*.

\* \*\*Git\*\*.

\* \*\*Node.js LTS\*\* + `npm` (for SWA, build tooling, Codex itself).

\* \*\*Stripe CLI\*\* (optional; for webhook test).

\* \*\*Terraform\*\* (optional; infra as code).

---

\## Environment \& Secrets

Provide these as \*\*environment variables\*\* (user or system) or via \*\*Azure Key Vault\*\*; agents expect them and will abort if missing.

```env

\# Azure

AZ\_SUBSCRIPTION\_ID=

AZ\_TENANT\_ID=

AZ\_LOCATION="Mexico Central"

AZ\_RG\_CORE="rg-simiriki-core"

AZ\_RG\_PROD="rg-simiriki-negocio-mxc"



\# Static Web Apps (SWA)

SWA\_APP\_NAME="simiriki-landing-new"

SWA\_APP\_RG="rg-simiriki-core"



\# Storage / Function App

AZ\_STORAGE\_ACCOUNT="stsimirikinegocio"

AZ\_FUNCAPP\_NAME="func-simiriki-leadscore"



\# Stripe (production)

STRIPE\_SECRET\_KEY=

STRIPE\_PRICE\_ID=

STRIPE\_WEBHOOK\_SECRET=



\# GitHub

GITHUB\_REPO="jjdlr-simiriki/simiriki-landing"

GITHUB\_BRANCH="main"



\# Observability

APPINSIGHTS\_KEY=

```

> If using Key Vault, agents will reference `AZ\_KEYVAULT\_NAME` and resolve secrets at runtime.

---

\## Approvals

Define when a human must confirm. Use \*\*paths\*\*, \*\*verbs\*\*, or \*\*risk levels\*\*.

```yaml

approvals:

&nbsp; # Safe reads, idempotent checks

&nbsp; - action: read\_only

&nbsp;   require: never



&nbsp; # Low‑risk writes inside local workspace (e.g., generate files)

&nbsp; - action: write\_local

&nbsp;   paths:

&nbsp;     - "C:/work/simiriki/\*\*"

&nbsp;   require: auto



&nbsp; # Cloud resource creation or deletion

&nbsp; - action: azure\_modify

&nbsp;   resources:

&nbsp;     - resourceGroups/\*

&nbsp;     - Microsoft.Web/\*

&nbsp;     - Microsoft.Storage/\*

&nbsp;     - Microsoft.App/\*

&nbsp;   require: always



&nbsp; # Payments or webhook changes

&nbsp; - action: stripe\_modify

&nbsp;   require: always



&nbsp; # Docker image removal/prune

&nbsp; - action: docker\_prune

&nbsp;   require: always

```

---

\## Agents

Each agent includes: \*\*Purpose\*\*, \*\*Capabilities\*\*, \*\*Inputs\*\*, \*\*Outcomes\*\*, and \*\*Example triggers\*\* you can paste to Codex.

\### 1) Azure Deployer

\*\*Purpose:\*\* Create/upgrade core Azure resources (RG, SWA, Storage, Function App) in \*\*Mexico Central\*\*.

\*\*Capabilities:\*\* `az group|staticwebapp|storage|functionapp`, template rendering, secret resolution.

\*\*Inputs:\*\* `AZ\_\*`, `SWA\_\*`, `GITHUB\_\*`, Stripe vars (for SWA app settings).

\*\*Outcomes:\*\* Running SWA, bound storage containers, Function App scaffold.

\*\*Example trigger:\*\*

```text

/run Azure Deployer -> Provision SWA + set Stripe keys + output hostname

```

\*\*Execution outline:\*\*

```bash

az account set --subscription "$AZ\_SUBSCRIPTION\_ID"

az group create -n "$AZ\_RG\_PROD" -l "$AZ\_LOCATION"

az staticwebapp create \\

&nbsp; -n "$SWA\_APP\_NAME" -g "$SWA\_APP\_RG" --location "$AZ\_LOCATION" \\

&nbsp; --sku Standard --source "https://github.com/$GITHUB\_REPO" \\

&nbsp; --branch "$GITHUB\_BRANCH" --app-location dist --api-location api --login-with-github



az staticwebapp appsettings set -n "$SWA\_APP\_NAME" -g "$SWA\_APP\_RG" \\

&nbsp; --setting-names STRIPE\_SECRET\_KEY="$STRIPE\_SECRET\_KEY" \\

&nbsp; STRIPE\_PRICE\_ID="$STRIPE\_PRICE\_ID" STRIPE\_WEBHOOK\_SECRET="$STRIPE\_WEBHOOK\_SECRET"



az staticwebapp show -n "$SWA\_APP\_NAME" -g "$SWA\_APP\_RG" --query "properties.defaultHostname" -o tsv

```

---

\### 2) Docker Maintainer

\*\*Purpose:\*\* Keep local Docker environment clean and consistent.

\*\*Capabilities:\*\* `docker ps|images|prune|rmi|pull`, safety checks.

\*\*Example trigger:\*\*

```text

/run Docker Maintainer -> remove dangling images/containers (confirm before prune)

```

\*\*Execution outline:\*\*

```bash

docker ps -a

docker images

\# confirm required

docker system prune --all --volumes

```

---

\### 3) Lead Intake Processor (Logic App/Function)

\*\*Purpose:\*\* Process inbound leads → normalize → store in Storage → notify Teams/Email.

\*\*Capabilities:\*\* Generate Azure Function (Node/Python), bind to `stsimirikinegocio`, create Logic App workflow.

\*\*Inputs:\*\* Storage names, Teams webhook or Graph scope.

\*\*Example trigger:\*\*

```text

/run Lead Intake Processor -> scaffold function + blob trigger + Teams notify

```

---

\### 4) GitOps Sync Agent

\*\*Purpose:\*\* Keep `main` in sync, tag deployments, generate release notes.

\*\*Capabilities:\*\* `git status|pull|tag`, conventional changelog, GitHub release draft.

\*\*Example trigger:\*\*

```text

/run GitOps Sync Agent -> pull main, create tag vNext, draft notes

```

---

\### 5) Security Hardening Agent

\*\*Purpose:\*\* Apply baseline hardening for SWA, Storage, and repos.

\*\*Checks/Actions:\*\*

\* Enforce HTTPS on SWA, disable legacy TLS.

\* Private endpoints / firewall on Storage (optional).

\* Secret scanning enabled in GitHub.

\* Basic headers (CSP, HSTS) for static site.

\*\*Trigger:\*\*

```text

/run Security Hardening Agent -> audit + remediate high‑impact settings

```

---

\### 6) Data Pipelines Agent

\*\*Purpose:\*\* Export leads → CSV/Parquet in `reports/`, schedule via Logic App.

\*\*Trigger:\*\*

```text

/run Data Pipelines Agent -> daily export at 06:00 local to Storage/reports

```

---

\### 7) Backup \& DR Agent

\*\*Purpose:\*\* Snapshot configs, export app settings, back up Function code artifacts.

\*\*Trigger:\*\*

```text

/run Backup \& DR Agent -> create weekly snapshot + verify restore

```

---

\### 8) Observability Agent

\*\*Purpose:\*\* Wire Application Insights, log retention, alerts on errors and cost spikes.

\*\*Trigger:\*\*

```text

/run Observability Agent -> connect to AppInsights and set alert rules

```

---

\### 9) Finance/Billing Guard

\*\*Purpose:\*\* Protect against runaway spend.

\*\*Actions:\*\* Budgets + email alerts, list SKUs, surface daily cost deltas.

\*\*Trigger:\*\*

```text

/run Finance Guard -> set 3 budget thresholds and send alerts

```

---

\### 10) SWA Deployer (Website Content)

\*\*Purpose:\*\* Build and deploy the landing site to SWA from local artifacts.

\*\*Trigger:\*\*

```text

/run SWA Deployer -> build (npm) and deploy to $SWA\_APP\_NAME

```

\*\*Outline:\*\*

```bash

npm ci

npm run build

\# SWA upload handled by GitHub action or az staticwebapp; choose one based on repo setup

```

---

\### 11) Windows Workstation Setup

\*\*Purpose:\*\* Ensure this PC has everything needed for the project.

\*\*Actions:\*\* Check versions, install missing tools silently where possible.

\*\*Trigger:\*\*

```text

/run Windows Setup -> verify az, node/npm, git, docker; install/update if missing

```

---

\## Task Templates (Copy/Paste)

Use these with Codex CLI input box.

```text

/agents          # list loaded agents

/status          # show current config and that AGENTS.md is detected

/approvals       # review/adjust approval rules

/model gpt-5     # enforce model selection



\# Run a composed task

/run Azure Deployer -> create RG $AZ\_RG\_PROD if missing, then SWA, set Stripe keys, print hostname



\# Safe dry‑run of Security Hardening

/run Security Hardening Agent (dry-run) -> enumerate diffs only



\# Docker cleanup with confirmation

/run Docker Maintainer -> show plan; require approval for prune

```

---

\## Conventions

\* \*\*Dry‑runs first\*\* for anything destructive.

\* \*\*Idempotent\*\* commands where possible.

\* \*\*Logs\*\* saved to `C:/work/simiriki/.logs/YYYY-MM-DD/\*.log`.

---

\## Troubleshooting

\* If `/status` still shows `AGENTS files: (none)`, ensure:

&nbsp; 1. This file is named `AGENTS.md` (exact) and is inside your active workspace path shown by `/status`.

&nbsp; 2. You started Codex in that folder or ran `cd` there before launching Codex.

&nbsp; 3. Restart the Codex CLI if needed.

\* For `az` auth issues: `az login`, then `az account set --subscription <id>`.

\* For missing env vars: set them and re-run `/status`; agents will refuse to run without required secrets.
