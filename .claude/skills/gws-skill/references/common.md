# Common: flags, auth, exit codes, workflows, troubleshooting

`G=.claude/skills/gws-skill/scripts/gws.sh` (gws 0.22.5).

## Global flags

| Flag | Purpose |
|---|---|
| `--params '<JSON>'` | URL or query parameters (IDs, filters, pageSize, fields) |
| `--json '<JSON>'` | Request body for POST/PATCH/PUT |
| `--upload <PATH>` / `--upload-content-type <MIME>` | Media upload (multipart) |
| `--output <PATH>` | Save a binary response (download/export) |
| `--format json\|table\|yaml\|csv` | Output format (default `json`) |
| `--page-all`, `--page-limit N` (default 10), `--page-delay MS` | Auto-pagination, one NDJSON line per page |
| `--dry-run` | Validate locally and print the request without sending it |
| `--api-version <v>` | Override the API version |
| `--sanitize <template>` | Filter responses through Model Armor (needs cloud-platform scope) |

`bash $G schema <service.resource.method> [--resolve-refs]` shows the parameters and request body of any method.

## Auth commands

| Command | Purpose |
|---|---|
| `auth status` | JSON: `user`, `token_valid`, `scopes`, `project_id`, credential paths |
| `auth login -s gmail,drive,docs,sheets,calendar` | Browser login for the listed services (the user signs in) |
| `auth login --readonly` / `--full` / `--scopes <list>` | Read-only scopes / all scopes / custom scopes |
| `auth logout` | Remove saved credentials and the token cache |
| `auth export --unmasked` | Print decrypted credentials, **including the refresh token**. Do not run it without a clear reason and approval |
| `auth setup [--project ID]` | Create the GCP project and enable APIs (needs gcloud; OAuth client creation still requires Cloud Console) |

Credential lookup order: `GOOGLE_WORKSPACE_CLI_TOKEN` → `GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE` → encrypted login credentials (`~/.config/gws/credentials.enc`) → plain `credentials.json`. The OAuth client comes from `.env` (`CLIENT_ID`/`CLIENT_SECRET`) or `~/.config/gws/client_secret.json`.

Adding services means logging in again with the full list, for example:
`bash $G auth login -s gmail,drive,docs,sheets,calendar,tasks,slides`
Unverified (Testing) apps allow about 25 scopes at most, so do not use `--full` or the recommended preset.

## Exit codes

| Code | Meaning | Action |
|---|---|---|
| 0 | Success | — |
| 1 | API error (Google returned an error) | Read `error.message` / `reason` (404 wrong ID, 403 permission or API disabled) |
| 2 | Auth error (missing, expired, or invalid credentials) | Run `scripts/check.sh`, then log in again |
| 3 | Validation error (bad arguments or JSON) | Fix the command; use `schema` |
| 4 | Discovery error (cannot fetch the API schema) | Check the network and retry |
| 5 | Internal error | Report it to the user |

## Workflow helpers (`gws workflow …`, alias `wf`)

| Command | Purpose | Needs |
|---|---|---|
| `+weekly-digest` | This week's meetings and the unread mail count (read-only) | calendar, gmail ✅ |
| `+meeting-prep` | Next upcoming event with attendees and description (read-only) | calendar ✅ |
| `+standup-report` | Today's meetings and open tasks | tasks scope ❌ |
| `+email-to-task` | Turn a Gmail message into a Google Task | tasks scope ❌ |
| `+file-announce` | Announce a Drive file in a Chat space | chat scope ❌ |

## Other services (need an extra login scope)

`slides`, `tasks`, `people` (contacts), `chat`, `forms`, `keep`, `meet`, `classroom`, `script` (Apps Script), `events` (Workspace events), `admin-reports` (Workspace admin only), `modelarmor`. See `bash $G <service> --help`.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `gws: command not found` | `scripts/check.sh` (installs it via npm) |
| Exit 2 / `invalid_grant` | The token expired or was revoked. Testing-mode apps can expire refresh tokens after about 7 days, so log in again |
| `accessNotConfigured` (403) | Open the `enable_url` in the error (or `gcloud services enable <api>`), wait about 10 seconds, and retry |
| "Access blocked" at login | Add the account under Cloud Console → Google Auth Platform → Audience → Test users |
| `redirect_uri_mismatch` | The OAuth client must be of type **Desktop app** |
| JSON parse errors on Windows | Run from Git Bash, not PowerShell |
| `insufficientPermissions` | The service is not in the login scopes. Log in again with `-s` including it |
| `Using keyring backend: keyring` on every call | Normal (stderr). Use `2>/dev/null` when you parse JSON |
| `warning: unknown output format 'text'` from `gmail +read` | Harmless. The output is still correct |
