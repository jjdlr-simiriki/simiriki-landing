# Repository Guidelines

This guide helps contributors work effectively on simiriki-landing (static site with optional Stripe‑backed endpoints for local/SWA use).

## Project Structure & Module Organization
- Root HTML: `index.html` (primary landing), plus `404.html`, policy pages.
- Assets: `assets/css`, `assets/js`, `assets/img` (lowercase, hyphenated names).
- API (SWA Functions): `api/*` with endpoint folders (e.g., `create-checkout-session/`).
- Server utilities: `server.js` (local Express + Stripe), `csp-server.js` (static server with headers).
- Config/CI: `.github/workflows/*`, `staticwebapp.config.json`, `.editorconfig`, `.prettierrc`, `.nvmrc`.

## Build, Test, and Development Commands
- Install: `npm ci` (use Node version in `.nvmrc`). No build step; files are static.
- Local dev (Stripe demo): `npm start` → `http://localhost:4242` (requires `STRIPE_SECRET_KEY`, `STRIPE_PRICE_ID`, `STRIPE_WEBHOOK_SECRET`).
- Local static preview with headers: `node csp-server.js` → `http://localhost:4244` (serves `index.html` with CSP).
- Quick preview (no headers): `npx http-server -p 8080` or `npx serve . -l 8080`.
- Format: `npm run format` (Prettier over repository).

## Coding Style & Naming Conventions
- Indentation: 2 spaces (see `.editorconfig`).
- Prettier: width 100, single quotes (see `.prettierrc`). Run before committing.
- Filenames: lowercase, words separated by `-` (e.g., `site-header.js`).
- JavaScript: CommonJS in Node helpers; keep browser JS minimal and framework‑free.

## Testing Guidelines
- Unit tests: none at present. Prefer small, pure functions and manual verification.
- Lighthouse: CI runs a report on PRs (`.github/workflows/lighthouse.yml`). Aim ≥90 in all categories.
- Local Lighthouse (optional):
  - `npx http-server -p 8080 & npx @lhci/cli collect --url=http://localhost:8080 --preset=desktop`

## Commit & Pull Request Guidelines
- Commits: follow Conventional Commits where possible (e.g., `feat(landing): ...`, `docs(readme): ...`, `chore(ci): ...`).
- PRs must include:
  - Clear description and linked issues (e.g., `Closes #18`).
  - Screenshots/GIFs for visual changes and notes on a11y.
  - Mention of Lighthouse impact; attach report if run locally.
  - Verification steps (Stripe env set if touching checkout: `STRIPE_SECRET_KEY`, `STRIPE_PRICE_ID`, `STRIPE_WEBHOOK_SECRET`).
- All CI checks must pass (Pages/SWA deploy artifacts and Lighthouse job).

## Security & Configuration Tips
- Never commit secrets. Use local env vars; see `.env.example` for names.
- `staticwebapp.config.json` sets CSP and security headers; keep Stripe and Clarity origins in sync.
- For local headers, prefer `node csp-server.js` over raw `http-server`.
