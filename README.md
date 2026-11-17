# pfm-web-infra

Repositório dedicado **1:1 de Infraestrutura como Código (IaC)** para o frontend executivo `pfm-web-nextjs` (OpenTofu Multi-Cloud, Helm Charts e CI/CD).

---

## Topologia de Portas: Local Host vs. Kubernetes Cloud

- **Host Local (`values-local.yaml`):** HTTP `18300` (`PORT`), Gateway Envoy `18080` (`NEXT_PUBLIC_API_URL`).
- **Produção K8s (`values-prod.yaml`):** HTTP `3000` (Service & Container), Gateway Envoy `8080`.
