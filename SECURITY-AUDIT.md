# Security Audit Report

This file is generated ad-hoc. For fresh results, rerun the commands below.

## npm audit (production)

Run:

```
cd /home/jjdlr/work/simiriki
npm audit --omit=dev
```

Summary output is stored in `SECURITY-AUDIT.json` (machine-readable). Consider enabling Dependabot to keep dependencies patched.

## pip-audit (Functions)

Run after creating the Python Function environment:

```
pip install pip-audit
pip-audit -r functions/func-simiriki-leadscore/requirements.txt
```

Resolve reported CVEs by upgrading the affected packages.
