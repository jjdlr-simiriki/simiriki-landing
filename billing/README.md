# Billing

Purpose: Seat-based plans (Starter/Pro/Premium), proration, invoicing, MXN/USD support.

## Submodules
- plans/: JSON schemas for bundles
- payments/: gateway adapter
- invoices/: PDF/CFDI hooks (future)
- webhooks/: billing events → CRM

## Next
- Plan catalog & price mapping
- Trial → paid upgrade flow
- Dunning + churn prevention
