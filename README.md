# PFM Web Infra — IaC 1:1 (ECS Fargate Spot Arm64 / EKS)

[![Gitflow](https://img.shields.io/badge/Gitflow-develop%20%7C%20main-indigo)](CONTRIBUTING.md)
[![SemVer](https://img.shields.io/badge/SemVer-2.0.0-blue)](CHANGELOG.md)
[![Docs](https://img.shields.io/badge/PFM%20Docs-V3.0-8CBA51)](https://sorobanerp.github.io/pfm-docs/)

---

## 1. Visão Geral & Papel na Arquitetura

Infraestrutura dedicada 1:1 para o `pfm-web-nextjs`: Task Definition **Fargate Spot Arm64**, Service Connect (`pfm-web-nextjs.pfm.internal:3000`), Auto Scaling (`1–3`) e Rollback Automático S3.

- **Repositório:** `Sorobanerp/pfm-web-infra`
- **Vínculo com `pfm-docs`:** `ADR-002, ADR-008 | US-11, US-14`

```mermaid
flowchart LR
    INFRA["pfm-web-infra (OpenTofu)"] --> ECS["ECS Service (Fargate Spot Arm64)"]
    ECS --> SC["Service Connect: pfm-web-nextjs.pfm.internal:3000"]
```

---

## 2. Pré-requisitos & Variáveis de Ambiente

### Pré-requisitos
- OpenTofu `>= 1.8.0`
- Trivy `>= 0.50`

### Variáveis de Ambiente (Sem Segredos Hardcoded)
| Variável | Padrão | Descrição |
| :--- | :---: | :--- |
| `TF_VAR_compute_engine` | `ecs_fargate_spot` | Motor de compute (`ecs_fargate_spot` ou `eks`) |
| `TF_VAR_environment` | `prod` | Ambiente alvo |
| `TF_STATE_BUCKET_AWS` | *(CI Secret/Var)* | Bucket S3 de state remoto OpenTofu |

> **Segurança (Zero-Trust):** Nunca commite tokens, senhas, chaves AWS ou strings de conexão com credenciais reais. Utilize `.env` local (ignorado no `.gitignore`) ou AWS Secrets Manager / GitHub OIDC.

---

## 3. Como Executar Localmente

```bash
tofu -chdir=terraform/aws init -backend=false
tofu -chdir=terraform/aws validate
```

---

## 4. Como Testar e Validar

```bash
tofu fmt -check -recursive terraform/
tofu -chdir=terraform/aws init -backend=false && tofu -chdir=terraform/aws validate
trivy config --severity CRITICAL,HIGH --exit-code 1 terraform/
```

---

## 5. Como Provisionar / Validar na Nuvem

1. Fluxo Gitflow: `feat/*` $\rightarrow$ `develop` $\rightarrow$ `release/vX.Y.Z` $\rightarrow$ `main`.
2. Validação pós-deploy: `aws ecs describe-services --cluster pfm-pilot-prod --services pfm-web-nextjs --region us-east-2`.

Consulte [CONTRIBUTING.md](CONTRIBUTING.md) para regras de Conventional Commits e [CHANGELOG.md](CHANGELOG.md) para histórico de versões.
