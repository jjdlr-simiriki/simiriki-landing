# Simiriki Landing — Ops Notes

## Deployment
- Uses Azure Static Web Apps with `AZURE_SWA_TOKEN`.
- `deploy-landing.yml` triggers on pushes to `main`.

## Analytics
Paste your IDs in your layout (or a small `analytics.html` partial).

### Google Analytics 4
```
<script async src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXX"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'G-XXXXXXX');
</script>
```

### Microsoft Clarity
```
<script type="text/javascript">
  (function(c,l,a,r,i,t,y){
    c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
    t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
    y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
  })(window, document, "clarity", "script", "CLARITY-ID");
</script>
```

## Performance Gates
`lighthouserc.json` enforces ≥0.9 on Performance, Accessibility, and SEO.
