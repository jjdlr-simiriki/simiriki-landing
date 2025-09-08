# Integrations

Purpose: This module handles Microsoft provisioning (Defender, Intune), Graph auth flows, and Sentinel rules seeding.

## Submodules
- auth/: OAuth & token cache
- ms-defender/: onboard devices & policies
- intune/: device compliance & MAM/MDM
- sentinel/: analytic rules & alerts
- webhooks/: event intake for actions

## Next
- Define service principals & scopes
- Tenant detection and consent
- Idempotent provisioning scripts
