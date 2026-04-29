# jccpokemonpocket Launch Checklist

## Deployment Mapping

- GitHub repository: `gateszhangc/jccpokemonpocket`
- Git branch: `main`
- Image repository: `registry.144.91.77.245.sslip.io/jccpokemonpocket`
- K8s manifest path: `gateszhangc/k8s-fleet/tenants/jccpokemonpocket`
- Argo CD application: `jccpokemonpocket`
- Primary domain: `jccpokemonpocket.lol`
- Argo platform repo: `gateszhangc/k8s-fleet`
- Dokploy: `not used`
- Release route: `gateszhangc/jccpokemonpocket -> main -> K8s build Job -> registry.144.91.77.245.sslip.io/jccpokemonpocket -> gateszhangc/k8s-fleet/tenants/jccpokemonpocket/kustomization.yaml newTag -> Argo CD auto sync`

## DNS and Cloudflare

- Cloudflare zone id: `ee6b30b9fb66594d996a1a31f47526fc`
- Cloudflare assigned nameservers: `jaziel.ns.cloudflare.com`, `sandra.ns.cloudflare.com`
- Authoritative records on Cloudflare zone:
  - apex `A 144.91.77.245`
  - `www CNAME jccpokemonpocket.lol`
  - `CLOUDFLARE_PROXY_APEX=false`
  - `CLOUDFLARE_PROXY_WWW=false`
- Registrar nameserver update via Porkbun API result: `UNABLE_TO_UPDATE_DOMAIN` (failed)
- Observed public behavior:
  - `http://jccpokemonpocket.lol` still serves parking/origin outside cluster
  - `https://jccpokemonpocket.lol` TLS handshake fails
- Conclusion: domain delegation to Cloudflare is not active yet on public DNS.

## CI/CD and Release Execution

- Application commit deployed: `36d5ef01d8f8bb3dcd59dde9becf75c9b9d9b1fa`
- GitHub Actions run `Build And Release` was triggered but failed at `Configure kubeconfig` (repo secrets missing), so manual fallback was used.
- Manual fallback completed:
  - Build Job: `jccpokemonpocket-image-manual1777470955` completed in `build-jobs`
  - Registry push confirmed for image `registry.144.91.77.245.sslip.io/jccpokemonpocket:36d5ef01d8f8bb3dcd59dde9becf75c9b9d9b1fa`
  - Fleet `newTag` updated and pushed to `gateszhangc/k8s-fleet`

## Argo and Workload Status

- Fleet `kustomization.yaml` `newTag`: `36d5ef01d8f8bb3dcd59dde9becf75c9b9d9b1fa`
- Argo app status: `Synced`, `Progressing` (progressing due live cert challenge pending)
- Argo source revision observed: `42cddbb7675f82a0a5bb6a3d7daa524ca3f01a2d`
- Workload image running:
  - `registry.144.91.77.245.sslip.io/jccpokemonpocket:36d5ef01d8f8bb3dcd59dde9becf75c9b9d9b1fa`

## Certificate and Ingress

- Preview certificate: `jccpokemonpocket-preview-tls` = `Ready`
- Live certificate: `jccpokemonpocket-live-tls` = `Not Ready`
- ACME challenge reason:
  - `Waiting for HTTP-01 challenge propagation: wrong status code '403', expected '200'`
- Root cause aligns with public DNS not delegated to Cloudflare yet.

## Live HTTP Checks

- `https://jccpokemonpocket.lol/` -> TLS handshake failure
- `https://www.jccpokemonpocket.lol/` -> TLS handshake failure
- `https://jccpokemonpocket.lol/sitemap.xml` -> TLS handshake failure
- `http://www.jccpokemonpocket.lol/` -> `301` to `http://jccpokemonpocket.lol`
- Preview endpoint:
  - `https://jccpokemonpocket.144.91.77.245.sslip.io/` -> `200` (with `-k`)

## Browser/Image/Navbar Acceptance

- Preview homepage HTML renders and static assets are available on preview endpoint.
- Navbar height adjusted from previous value and reduced to compact style (`58px` min height) to stay close to `autoresearch.lol` proportions.
- Full live browser acceptance is blocked until real domain DNS delegation and live certificate become ready.

## GSC Ownership

- Scope requested by task: `GSC only`
- GA4/Clarity/GTM: `not added`
- GSC setup/check scripts were attempted with existing ADC and Cloudflare zone settings, but operation did not complete within execution window.
- Current gate result:
  - `GSC siteOwner`: not confirmed yet
  - `sitemap listed`: not confirmed yet
- Dependency: live domain delegation + reachable `https://jccpokemonpocket.lol/sitemap.xml` + successful Google API completion.

## Outstanding Items

1. Complete registrar nameserver switch from Porkbun to Cloudflare (`jaziel/sandra`).
2. Wait for live cert-manager order/challenge to pass and `jccpokemonpocket-live-tls` to become `Ready`.
3. Re-run:
   - `setup-gsc.sh https://jccpokemonpocket.lol`
   - `check-gsc-property.sh https://jccpokemonpocket.lol`
4. Verify final gates:
   - `siteOwner`
   - `sitemap listed`
   - live apex/www/sitemap HTTPS returns expected status.
