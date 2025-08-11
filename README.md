# Simiriki Landing

This repository contains the landing page for [simiriki.com](https://simiriki.com).

## Setup
1. Clone this repository.
2. There is no build step. Open `index.html` in your browser to preview the site locally.
3. Run a Lighthouse audit and address any warnings.

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

