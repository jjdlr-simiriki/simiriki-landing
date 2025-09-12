# Simiriki Landing

This repository contains the landing page for [simiriki.com](https://simiriki.com).

## Setup

1. Clone this repository.
2. There is no build step. Open `index.html` in your browser to preview the site locally.
3. Run a Lighthouse audit and address any warnings.

## Content

- The landing page includes sections for **benefits**, **testimonials**, and an interactive demo integrated with `simiriki-ai`.

### Stripe Checkout

1. Install dependencies with `npm install`.
2. Set the environment variables `STRIPE_SECRET_KEY`, `STRIPE_PRICE_ID` and `STRIPE_WEBHOOK_SECRET`.
3. Start the server with `npm start` and open `http://localhost:4242`.

## Deployment

Upload all files in this repository to your Azure Static Web Apps project or another static hosting provider.

## Customization

- The links for **Agenda** and the embedded `iframe` in `index.html` are preconfigured with production URLs. Update them if you change your form or schedule.
- Replace `assets/img/icon.png` and `assets/img/logo.svg` with your final logos if needed.
- **Colors:** Primary `#19C37D`; neutral palette based on Slate.
- **Typography:** Inter (optional) with system fallbacks.
- **Compatibility:** Automatic dark mode (`prefers-color-scheme`).

# Simiriki Landing – Deploy

## Local preview
`
python -m http.server 8080
# or
npx serve . -l 8080
`

## Analytics
- Microsoft Clarity ID lives in <meta name="clarity-id"> (edit in index.html).
- Loader is external (js/clarity.js), CSP-safe.

## Canva
index.html -> replace the iframe src if you update the design.

## Azure Static Web Apps (SWA)
1. In Azure Portal, create a Static Web App (Production).
2. In GitHub → Settings → Secrets & variables → Actions:
   - AZURE_STATIC_WEB_APPS_API_TOKEN = deployment token from SWA.
3. Push to main → GitHub Action .github/workflows/azure-swa.yml runs:
   - Copies static files to dist/
   - Deploys dist/ as app and pi/ as Functions.

### Environment settings (Functions)
In SWA → **Configuration** (Application settings):
- STRIPE_SECRET_KEY = sk_live_.../sk_test_...
- STRIPE_PRICE_ID   = price_...

### Custom domain
Add www.simiriki.com in SWA → Custom domains. Follow CNAME/TXT prompts. Enable free SSL.

## Security headers
staticwebapp.config.json sets CSP, Referrer-Policy, Permissions-Policy, X-Content-Type-Options.

## Related Repos
- simiriki-ai (Next.js demo): interactive experience; host on SWA and link from this landing.
- simiriki-landing-swa: older/alternate SWA landing. Recommended to consolidate into this repo.
- simiriki-base44-core (Python): internal/core library; not directly used by this landing.
