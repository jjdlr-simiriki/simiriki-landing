# Authentication — Azure AD (SWA)

Enable Microsoft login for Static Web Apps:

- Create App Registration in Azure AD:
  - Redirect URI: `https://<SWA_HOSTNAME>/.auth/login/aad/callback`
- In SWA (Azure Portal) → Authentication:
  - Add Identity Provider: Microsoft.
  - Client ID/Secret from the App Registration.
- Restrict access (optional):
  - Set roles and invite users via SWA → Users.

Testing:

- Visit `https://<SWA_HOSTNAME>/.auth/login/aad` to initiate login.
- Check `/.auth/me` for user claims.
