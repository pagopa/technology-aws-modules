# IDVH Code Review Completo — Report Tecnico

> **Repo:** `pagopa/technology-aws-modules` — branch `init-idvh`  
> **Data:** 2026-02-15  
> **Obiettivo:** Migrare pattern IDH Azure → IDVH AWS  
> **Regola chiave:** nel modulo `lambda` i parametri strutturali devono stare SOLO nel tier YAML; variabili Terraform solo per parametri davvero dinamici (es. `memory_size`).

---

## Indice

1. [Parte 1 — Bug, Rischi e Finding](#parte-1--bug-rischi-e-finding)
   - [Severità Alta](#severità-alta)
   - [Severità Media](#severità-media)
   - [Severità Bassa](#severità-bassa)
2. [Verifica Regola Chiave: parametri strutturali SOLO nel YAML](#verifica-regola-chiave-parametri-strutturali-solo-nel-yaml)
3. [Coerenza YAML ↔ Logica Lambda](#coerenza-yaml--logica-lambda)
4. [Parte 2 — Raccomandazioni di Miglioramento](#parte-2--raccomandazioni-di-miglioramento)
   - [A. Architettura](#a-architettura)
   - [B. Codice Terraform](#b-codice-terraform)
   - [C. Script e Tooling](#c-script-e-tooling)
   - [D. Catalogo YAML](#d-catalogo-yaml)
   - [E. Testing](#e-testing)
5. [Riepilogo Azioni Prioritario](#riepilogo-azioni-prioritario)

---

# Parte 1 — Bug, Rischi e Finding

## Severità Alta

### H1 — Sintassi `check` block errata — il modulo non funziona

**File:** `IDVH/lambda/main.tf` — righe 68-112

In Terraform >=1.5 `assert` dentro `check` è un **blocco**, non un attributo. Il codice attuale usa `assert = (...)` + `error_message = "..."` come attributi flat, ma la sintassi corretta richiede `assert { condition = ...; error_message = ... }`.

Questo colpisce tutti e 4 i check:
- `lambda_yaml_required_keys` (L68)
- `lambda_yaml_types` (L78)
- `lambda_yaml_values` (L99)
- `external_code_bucket_inputs` (L110)

`terraform plan` fallisce con errori di compilazione:
```
Unexpected attribute: An attribute named "assert" is not expected here
Too few blocks specified for "assert": At least 1 block(s) are expected for "assert"
```

**Codice attuale (errato):**
```hcl
check "lambda_yaml_required_keys" {
  assert = (
    length(local.missing_tier_keys) == 0 &&
    length(local.missing_code_bucket_keys) == 0 &&
    length(local.missing_deploy_role_keys) == 0
  )
  error_message = "..."
}
```

**Fix:**
```hcl
check "lambda_yaml_required_keys" {
  assert {
    condition = (
      length(local.missing_tier_keys) == 0 &&
      length(local.missing_code_bucket_keys) == 0 &&
      length(local.missing_deploy_role_keys) == 0
    )
    error_message = "..."
  }
}
```

**Impatto:** Il modulo non può essere usato — `terraform init`/`plan` fallisce.

---

### H2 — IAM deploy policy con `Resource = "*"` su azioni Lambda

**File:** `IDVH/lambda/main.tf` — righe 200-204

```hcl
{
  Effect   = "Allow"
  Action   = local.deploy_lambda_actions
  Resource = "*"
}
```

Il GitHub Actions deploy role può chiamare `lambda:UpdateFunctionCode` su **qualsiasi Lambda dell'account**. Un attaccante con accesso al repo potrebbe modificare codice di Lambda non correlate.

**Fix:** restringere a `module.lambda_raw.lambda_function_arn`. Per `lambda:CreateFunction` (che richiede `*`) usare uno statement separato con condition tag-based.

---

### H3 — `s3_bucket` usa `try()` ovunque — viola la regola "strutturali solo in YAML"

**File:** `IDVH/s3_bucket/main.tf` — righe 35-57

Ci sono ~12 invocazioni `try(local.idh_config.xxx, fallback)`. Se una chiave manca dal YAML, il modulo funziona silenziosamente con un default hardcoded nel codice Terraform, rendendo il catalogo YAML bypassabile. Il modulo `lambda` fa il contrario: valida tutto con check espliciti.

Esempi:
```hcl
force_destroy     = coalesce(var.force_destroy, try(local.idh_config.force_destroy, false))
object_ownership  = try(local.idh_config.object_ownership, "BucketOwnerEnforced")
versioning_enabled = try(local.idh_config.versioning_enabled, true)
block_public_acls  = try(local.idh_config.block_public_acls, true)
# ... e molti altri
```

**Fix:** applicare a `s3_bucket` lo stesso pattern di validazione esplicita del modulo `lambda` (required keys + check block).

---

## Severità Media

### M1 — `can()` ridondante nel check values

**File:** `IDVH/lambda/main.tf` — righe 100-103

```hcl
can(length(local.idh_config.architectures) > 0) &&
can(length(local.idh_config.deploy_role.lambda_actions) > 0) &&
length(local.idh_config.architectures) > 0 &&
length(local.idh_config.deploy_role.lambda_actions) > 0
```

`can(expr > 0)` verifica solo che l'espressione non lanci errore — restituisce sempre `true` se la chiave esiste (un booleano è sempre valutabile da `can()`). Non controllano che il risultato sia `true`. Sono righe inutili che possono essere rimosse.

---

### M2 — YAML env-specifici identici — violazione DRY massiva

I file:
- `IDVH/00_product_configs/onemail/dev/lambda.yml`
- `IDVH/00_product_configs/onemail/uat/lambda.yml`
- `IDVH/00_product_configs/onemail/prod/lambda.yml`
- `IDVH/00_product_configs/common/lambda.yml`

ripetono **tutti** i campi, differendo solo per `memory_size`, `timeout`, `cloudwatch_logs_retention_in_days`.

Lo stesso per `s3_bucket.yml` dove sono al 100% identici tra tutti gli ambienti.

Il loader fa merge (`global_common → product_common → env`), ma questa gerarchia non viene sfruttata.

---

### M3 — Nessuna directory `onemail/common/`

La gerarchia prevede `{product}/common/` per valori condivisi tra env, ma `onemail/` ha solo `dev/`, `uat/`, `prod/`. Tutto è duplicato in ogni env.

---

### M4 — Deploy role silenziosamente disattivato senza warning

**File:** `IDVH/lambda/main.tf` — riga 64

```hcl
github_deploy_role_enabled = local.effective_create_github_deploy_role && var.github_repository != null
```

Se il YAML ha `deploy_role.enabled = true` ma l'utente non passa `github_repository`, il role non viene creato — senza alcun avviso. Andrebbe aggiunto un check di warning.

---

### M5 — Commit hash pinning senza commento versione

**File:** `IDVH/lambda/main.tf` (L116), `IDVH/s3_bucket/main.tf` (L32)

I raw modules usano `?ref=55abacb6bfa...` senza indicare a quale release corrisponde. Un maintainer deve andare su GitHub a verificare.

**Fix:** aggiungere commento tipo `# v7.7.1` accanto al ref.

---

### M6 — Naming inconsistente `idh_` vs `idvh_`

Ovunque nel codice: `idh_loader`, `idh_config`, `idh_resource_tier`, `idh_resource_type` — ma il progetto si chiama **IDVH** e la cartella è `01_idvh_loader`. Crea confusione e rende il codice meno leggibile.

---

## Severità Bassa

### L1 — Code bucket 1:1 per Lambda — rischio proliferazione S3

Con tier `standard`, ogni istanza del modulo `lambda` crea un bucket S3 separato. 50 Lambda = 50 bucket.

**Raccomandazione:** considerare un pattern di code bucket condiviso, dove un modulo esterno crea il bucket e tutte le Lambda usano il tier `standard_external_code_bucket`.

---

### L2 — `resource_description.info` accoppiamento implicito con `flatten_dict`

**File:** `IDVH/lambda/resource_description.info`

Il campo `{code_bucket_enabled}` funziona solo grazie all'appiattimento fatto in `idvh_doc_gen.py` (`code_bucket.enabled` → `code_bucket_enabled`). Rinominare la chiave YAML rompe la doc silenziosamente (`Default.__missing__` restituisce `"-"`).

---

### L3 — Nessun test automatico

Nessun `.tftest.hcl`, `terratest`, o `terraform validate` in CI per `lambda` o `s3_bucket`. A differenza di `IDH_AZURE/cosmosdb_account` (che ha una cartella `tests/`).

---

### L4 — `terraform_exec` in `terraform-aws.sh` re-inizializza ad ogni plan/apply

**File:** `.scripts/terraform-aws.sh`

La funzione `terraform_exec` chiama `terraform_init` prima di ogni `plan`/`apply`/`destroy`. Questo è safe ma rallenta l'iterazione in dev. Un check `if [ ! -d .terraform ]` sarebbe più efficiente.

---

# Verifica Regola Chiave: parametri strutturali SOLO nel YAML

| Parametro | Fonte YAML | Override TF | Conforme? |
|-----------|:----------:|:-----------:|:---------:|
| `runtime` | Sì | No | **Sì** |
| `handler` | Sì | No | **Sì** |
| `architectures` | Sì | No | **Sì** |
| `timeout` | Sì | No | **Sì** |
| `publish` | Sì | No | **Sì** |
| `ignore_source_code_hash` | Sì | No | **Sì** |
| `cloudwatch_logs_retention` | Sì | No | **Sì** |
| `code_bucket.*` | Sì | No | **Sì** |
| `deploy_role.*` | Sì | No | **Sì** |
| `memory_size` | Sì (default) | Sì (`coalesce`) | **Sì** (design intenzionale) |

**Nessun fallback nascosto** nel modulo `lambda` per parametri strutturali. La regola è rispettata.

⚠️ Il modulo `s3_bucket` invece **viola la regola** con i `try()` fallback (vedi H3).

---

# Coerenza YAML ↔ Logica Lambda

| Check | Risultato |
|-------|-----------|
| Tutti i tier hanno le chiavi richieste | **OK** (standard + standard_external_code_bucket) |
| Dev/Uat usano `cloudwatch_logs_retention` = 14/30, Prod = 90 | **OK**, progressione sensata |
| Dev/Uat `memory_size` = 512, Prod = 1024 | **OK** |
| `standard_external_code_bucket` ha `code_bucket.enabled = false` | **OK** |
| Tier con bucket esterno ancora definisce `name_prefix/suffix/tier` (non usati) | **Rischio basso** — chiavi ridondanti ma non dannose |

---

# Parte 2 — Raccomandazioni di Miglioramento

## A. Architettura

---

### A3 — Separare il deploy role dal modulo Lambda

Il `github_lambda_deploy` role con OIDC federation è una responsabilità separata dalla Lambda stessa. Un modulo IDVH dedicato `iam_deploy_role/` sarebbe:
- Più riusabile (altri moduli AWS ne avranno bisogno)
- Più testabile isolatamente
- Coerente con il principio single-responsibility
- Permetterebbe un singolo role per N Lambda dello stesso repo (evitando N role identici)

---

### A4 — Aggiungere tier diversificati nel catalogo

Attualmente ci sono solo 2 tier molto simili. Un catalogo maturo ha tier che coprono scenari reali:

```yaml
high_memory:       # memory 3008+, timeout 300s
arm64_standard:    # architectures: [arm64], costo ~20% inferiore
python312:         # runtime: python3.12, handler: lambda_function.handler
nodejs20:          # runtime: nodejs20.x, handler: index.handler
```

Questo è il vero valore del catalogo: evitare che ogni team scelga configurazioni random.

---

### A5 — Aggiungere tagging obbligatorio IDVH

Il modulo dovrebbe aggiungere tag automatici per tracciabilità:

```hcl
locals {
  idvh_tags = {
    "idvh:module"     = "lambda"
    "idvh:tier"       = var.idh_resource_tier
    "idvh:product"    = var.product_name
    "idvh:env"        = var.env
    "idvh:managed_by" = "idvh"
  }
}

tags = merge(local.idvh_tags, var.tags)
```

Permette audit, cost allocation e governance centralizzata.

---

### A6 — Aggiungere output `idvh_metadata` strutturato

Un output che espone la configurazione effettiva usata, utile per debugging e per moduli downstream:

```hcl
output "idvh_metadata" {
  value = {
    tier           = var.idh_resource_tier
    product        = var.product_name
    env            = var.env
    effective_config = {
      runtime       = local.effective_runtime
      memory_size   = local.effective_memory_size
      timeout       = local.effective_timeout
      architectures = local.effective_architectures
    }
  }
}
```

---

## B. Codice Terraform

### B1 — Uniformare la validazione tra `lambda` e `s3_bucket`

Creare un pattern comune riusabile. La validazione nel `lambda` è ben fatta (required keys, type checks, value checks) — va replicata identica in `s3_bucket` e in ogni futuro modulo IDVH. Idealmente estratta in un modulo `_validation_helpers`

---

### B2 — Aggiungere `precondition` nei `lifecycle` dei moduli raw

I `check` block di Terraform sono **warning**, non bloccano `terraform apply`. Per validazioni che devono bloccare, usare `precondition` nel `lifecycle` delle risorse:

```hcl
module "lambda_raw" {
  # ...
  lifecycle {
    precondition {
      condition     = length(local.missing_tier_keys) == 0
      error_message = "Missing required YAML keys: ${join(", ", local.missing_tier_keys)}"
    }
  }
}
```

Questo blocca realmente il deploy con un YAML incompleto, anziché mostrare solo un warning.

---

### B3 — Aggiungere validazioni sulle variabili `lambda`

```hcl
variable "name" {
  type = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.name)) && length(var.name) <= 64
    error_message = "Lambda name must be alphanumeric with hyphens/underscores, max 64 chars."
  }
}

variable "vpc_subnet_ids" {
  type = list(string)
  validation {
    condition     = length(var.vpc_subnet_ids) == 0 || length(var.vpc_security_group_ids) > 0
    error_message = "vpc_security_group_ids is required when vpc_subnet_ids is set."
  }
}
```

---

### B4 — Aggiungere `description` a tutti gli output

Attualmente nessun output di `IDVH/lambda/outputs.tf` o `IDVH/s3_bucket/outputs.tf` ha `description`. Rende `terraform output` e `terraform-docs` meno utili.

```hcl
output "lambda_function_arn" {
  description = "ARN of the created Lambda function"
  value       = module.lambda_raw.lambda_function_arn
}
```

---

### B5 — Il loader dovrebbe esporre anche la versione del catalogo

Aggiungere un campo `catalog_version` nel YAML root o nel loader, per tracciare quale versione del catalogo è stata usata. Utile per drift detection e rollback:

```yaml
_meta:
  catalog_version: "1.0.0"
  last_updated: "2026-02-15"
```

---

### B6 — Considerare `moved` blocks per future rifattorizzazioni

Se cambierete naming (`idh_` → `idvh_`), indirizzi di moduli interni, o struttura di risorse, preparare `moved` block evita `destroy + recreate` in produzione:

```hcl
moved {
  from = module.idh_loader
  to   = module.idvh_loader
}
```

---

## C. Script e Tooling

### C1 — `generate-idvh-docs.sh` ricrea venv ogni volta

**File:** `.scripts/generate-idvh-docs.sh`

Ogni invocazione crea un virtualenv, installa `pyyaml`, esegue, distrugge. Questo è lento e non idempotente.

**Miglioramenti:**
1. Usare `pip install --user pyyaml` o un `requirements.txt` con caching
2. Oppure riscrivere `idvh_doc_gen.py` senza dipendenze esterne (il YAML dei tier è semplice abbastanza per un parser minimale)
3. In CI: cacheare il venv e rigenerare solo se `requirements.txt` cambia

---

### C3 — `idvh_doc_gen.py` non valida lo schema YAML

Lo script genera documentazione senza mai verificare che il YAML sia valido. Se un tier ha un campo mancante, la doc mostra `"-"` silenziosamente (grazie a `Default.__missing__`). Dovrebbe almeno loggare un warning.

**Miglioramento:** aggiungere un flag `--strict` che fallisce se un placeholder del template non trova corrispondenza nel YAML.

---


### C5 — Aggiungere un CI pipeline YAML per IDVH

Manca completamente un workflow CI (GitHub Actions) per IDVH. Mettere action per validazione dei
file yaml cambiati.

---

## D. Catalogo YAML

### D1 — Aggiungere validazione dei valori nei tier

Attualmente nessun tier valida che i valori siano sensati. Raccomandazioni:
- `memory_size` deve essere multiplo di 1 MB (requisito AWS: tra 128 e 10240)
- `timeout` deve essere <= 900 (limite AWS)
- `runtime` deve essere in una lista di runtime supportati
- `cloudwatch_logs_retention_in_days` deve essere un valore valido AWS: `1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653`

Queste validazioni vanno sia nel `check` Terraform .

---

### D2 — `standard_external_code_bucket` ha chiavi `name_prefix/name_suffix/idh_resource_tier` inutilizzate

Quando `code_bucket.enabled = false`, le chiavi `name_prefix`, `name_suffix`, `idh_resource_tier` nel blocco `code_bucket` **non vengono usate** (il modulo non crea il bucket). Però la validazione le richiede comunque. Questo è confusionario: o si rendono opzionali per tier con `enabled=false`, o si documenta esplicitamente che sono placeholder.

---

## E. Testing

### E1 — Creare `.tftest.hcl` per ogni modulo

Terraform 1.6+ supporta test nativi. Esempio:

```hcl
# lambda/tests/standard_tier.tftest.hcl
variables {
  product_name      = "onemail"
  env               = "dev"
  idh_resource_tier = "standard"
  name              = "test-lambda"
  package_path      = "./test.zip"
}

run "validates_yaml_keys" {
  command = plan
  assert {
    condition     = output.lambda_function_name == "test-lambda"
    error_message = "Function name mismatch"
  }
}
```

---

### E2 — Test di validazione negativa

Testare che un YAML malformato fallisca correttamente:

```hcl
run "rejects_missing_runtime" {
  command = plan
  variables {
    idh_resource_tier = "broken_tier"  # creato apposta senza runtime
  }
  expect_failures = [check.lambda_yaml_required_keys]
}
```

---


# Riepilogo Azioni Prioritario

| # | Categoria | Azione | Effort | Impatto |
|---|-----------|--------|:------:|:-------:|
| H1 | Bug | Fix sintassi `check` → `assert { condition; error_message }` | Basso | **Bloccante** |
| H2 | Security | Restringere `Resource = "*"` nella IAM policy | Basso | Alto |
| H3 | Design | Rimuovere `try()` da `s3_bucket`, aggiungere check espliciti | Medio | Alto |
| A1 | Architettura | JSON Schema per validazione YAML in CI | Medio | Alto |
| A2 | Architettura | Deep merge nel loader + ereditarietà YAML reale | Medio | Alto |
| B2 | Codice | `precondition` al posto di `check` (warning → errore bloccante) | Basso | Alto |
| C5 | Tooling | CI pipeline per validate + fmt + test | Medio | Alto |
| A5 | Architettura | Tagging IDVH automatico | Basso | Medio |
| A3 | Architettura | Estrarre deploy role in modulo separato | Medio | Medio |
| D3 | Catalogo | Ancore YAML per DRY nei tier | Basso | Medio |
| C2 | Script | Fix `idvh_doc_gen.py` che skippa `common/` | Basso | Medio |
| M6 | Naming | Uniformare `idh_` → `idvh_` ovunque | Medio | Medio |
| E1 | Testing | `.tftest.hcl` per ogni modulo | Alto | Alto |
| B3 | Codice | Validazioni su variabili (`name`, `vpc`) | Basso | Basso |
| B4 | Codice | `description` su tutti gli output | Basso | Basso |
| C4 | Tooling | Aggiungere `validate`/`fmt`/`test` a `terraform-aws.sh` | Basso | Medio |
| C6 | Tooling | Pre-commit hooks | Basso | Medio |
| A4 | Catalogo | Tier diversificati (`arm64`, `high_memory`, `python312`) | Medio | Medio |
| D1 | Catalogo | Validazione valori AWS (retention days, memory multipli) | Basso | Medio |
