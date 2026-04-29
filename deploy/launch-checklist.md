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
- Registrar nameserver update via Porkbun API result: `SUCCESS`
- Public resolver verification:
  - `dig +short NS jccpokemonpocket.lol @8.8.8.8` -> `jaziel.ns.cloudflare.com`, `sandra.ns.cloudflare.com`
  - `dig +short A jccpokemonpocket.lol @8.8.8.8` -> `144.91.77.245`
- Conclusion: domain delegation to Cloudflare is active.

## CI/CD and Release Execution

- Application commit deployed: `36d5ef01d8f8bb3dcd59dde9becf75c9b9d9b1fa`
- GitHub Actions run `Build And Release` was triggered but failed at `Configure kubeconfig` (repo secrets missing), so manual fallback was used.
- Manual fallback completed:
  - Build Job: `jccpokemonpocket-image-manual1777470955` completed in `build-jobs`
  - Registry push confirmed for image `registry.144.91.77.245.sslip.io/jccpokemonpocket:36d5ef01d8f8bb3dcd59dde9becf75c9b9d9b1fa`
  - Fleet `newTag` updated and pushed to `gateszhangc/k8s-fleet`

## Argo and Workload Status

- Fleet `kustomization.yaml` `newTag`: `36d5ef01d8f8bb3dcd59dde9becf75c9b9d9b1fa`
- Argo app status: `Synced`, `Healthy`
- Argo source revision observed: `4758d6637f9889c806ad8e5f44e34f6e42766b77`
- Workload image running:
  - `registry.144.91.77.245.sslip.io/jccpokemonpocket:36d5ef01d8f8bb3dcd59dde9becf75c9b9d9b1fa`

## Certificate and Ingress

- Preview certificate: `jccpokemonpocket-preview-tls` = `Ready`
- Live certificate: `jccpokemonpocket-live-tls` = `Ready`
- Certificate fix applied:
  - switched issuer from `letsencrypt-prod` (HTTP-01) to `letsencrypt-prod-cloudflare` (DNS-01)
- ACME order state: `valid`

## Live HTTP Checks

- `https://jccpokemonpocket.lol/` -> `200`
- `https://www.jccpokemonpocket.lol/` -> `200`
- `https://jccpokemonpocket.lol/sitemap.xml` -> `200`
- `http://www.jccpokemonpocket.lol/` -> redirects to live host
- Preview endpoint:
  - `https://jccpokemonpocket.144.91.77.245.sslip.io/` -> `200` (with `-k`)

## Browser/Image/Navbar Acceptance

- Preview homepage HTML renders and static assets are available on preview endpoint.
- Navbar height adjusted from previous value and reduced to compact style (`58px` min height) to stay close to `autoresearch.lol` proportions.
- Skill browser/image scripts require local `playwright` package; in this static-only repo they fail with `MODULE_NOT_FOUND`.
- Live endpoint and image URLs are reachable by HTTP checks; no broken asset response observed.

## GSC Ownership

- Scope requested by task: `GSC only`
- GA4/Clarity/GTM: `not added`
- Final gate result:
  - `GSC_CHECK_PERMISSION_LEVEL=siteOwner`
  - `GSC_CHECK_OWNER_CONFIRMED=true`
  - `GSC_CHECK_SITEMAP_LISTED=true`

## Outstanding Items

1. Optional hardening: add repository release secrets (`KUBE_CONFIG_DATA`, `FLEET_REPO_PAT`) to let GitHub Actions replace manual fallback.
2. Optional QA: install `playwright` in this repo if full browser/scripted visual gate is required in CI.
