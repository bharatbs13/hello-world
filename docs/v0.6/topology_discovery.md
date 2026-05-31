# DESIGN DOCUMENT: Relix Enterprise Infrastructure, Schema & Lineage Discovery Engine

**Document Identifier:** Relix Enterprise Metadata Discovery Platform v0.6.1 Architecture Freeze

**Requirement Reference:** FR-100 — Enterprise Topology, Schema & Lineage Discovery

**Integrated Feature Requirements:**

* FR-101 — Standard SaaS and Custom API Discovery Adapter Support (v0.6.1)
* FR-102 — Object Storage, Data Lake Integration, and Connector Registry Governance (v0.6.1)
* FR-103 — Messaging & Streaming Discovery Support (v0.6.1)
* FR-104 — Compute & Processing Discovery (v0.6.1 Integrated)
* FR-105 — Discovery Command Cache, Failure Memory, and Latency Profile (v0.6.1)
* FR-107 — Agent Governance and Execution Mode Classification (v0.6.1 Integrated)
* FR-108 — Credential Security, Secret Isolation & Access Governance (v0.6.1 Integrated)

**Planned / Optional Extensions:**

* FR-106 — MCP Tool Gateway Integration (v0.6.1)

**System Status:** ARCHITECTURE FROZEN | APPROVED

---

## 1. Executive Summary

This document establishes the finalized, production-grade baseline architecture for **Relix**. Through systematic iterative refinement, Relix has transitioned from a localized network-scanning utility into a robust, multi-tenant **Enterprise Metadata Control Plane**.

The core operational paradigm of Relix relies on strict cognitive decoupling paired with deterministic authority gates and zero-trust credential isolation:

1. **Phase 1: Analytical Planning:** A single, isolated **Discovery Planner Agent** evaluates high-level tenant inventory configurations alongside an explicit **Agent Governance Policy** to produce a deterministic, declarative **Task Manifest**. The agent remains completely decoupled from the network, has zero visibility into raw credentials, and cannot self-escalate its execution authority.
2. **Phase 2: Governance & Deterministic Execution:** The generated manifest passes through a physical **Manifest Approval Gate** and an **Execution Mode Controller**. Once cleared, a non-LLM, software-driven **Discovery Executor** ingests the tasks. It cross-references them against a **Connector Capability Registry**, optimizes routes via a multi-tenant **Discovery Command Cache**, enforces adaptive **Latency Profiles** to dynamically adjust timeouts, and executes queries via target adapters.
3. **Phase 3: Cryptographic & Runtime Secret Isolation:** At the exact boundary of execution, a **Secret Access Policy** dictates that credential references (`secret_ref`) are resolved just-in-time from a secure **Secret Provider**. Raw credentials are never exposed to the Planner Agent, never stored in the Task Manifest, never persisted in cache matrices, and explicitly redacted from all engine logs and evidence trails.
4. **Phase 4: Graph and Lineage Inference:** Discovered assets are processed, tracking clear schema relationships automatically, while routing probabilistic assertions (e.g., name-similarity lineage, cross-system dependencies) to an evidence-backed **Human Review Queue** before final persistence into the **Approved Graph Store**.

---

## 2. Platform Architecture Blueprint

The systemic boundary mapping isolates cognitive planning from execution protocols while embedding strict execution authority layers and cryptographic secret isolation directly inside the execution block.

```text
                        ┌──────────────────────────────┐
                        │ Config, Policy & Secret Ref  │
                        │ Vault                        │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ [FR-107] Agent Governance    │
                        │ Policy                       │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ Discovery Run Context        │
                        │ run_id, tenant_id, budgets   │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ Phase 1: Discovery Planner   │
                        │ Agent                        │
                        │ Produces Task Manifest Only  │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ Task Manifest                │
                        │ *Zero Credentials Contained* │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ [FR-107] Manifest Approval   │
                        │ Gate                         │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ [FR-107] Execution Mode      │
                        │ Controller                   │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ Discovery Command Cache      │
                        │ Evades redundant/failed paths│
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ Latency Profile Resolver     │
                        │ Calculates adaptive timeouts │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ Phase 2: Discovery Executor  │
                        │ Non-LLM, Deterministic Core  │
                        └──────────────┬───────────────┘
                                       │
                        ┌──────────────┴───────────────┐
                        │ [FR-108] Secret Access       │
                        │ Policy                       │
                        └──────────────┬───────────────┘
                                       │
                        ┌──────────────▼───────────────┐
                        │ [FR-108] Secret Provider     │
                        │ Just-In-Time API Resolution  │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ Connector Capability Registry│
                        │ Maps targets to capabilities │
                        └──────────────┬───────────────┘
                                       │
                        ┌──────────────▼───────────────┐
                        │ Connector Governance Wrapper │
                        │ Redaction Filter / Audit     │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ Rate Limiter                 │
                        │ connection/query budgets     │
                        └──────────────┬───────────────┘
                                       │
          ┌────────────────────────────┴────────────────────────────┐
          ▼                                                         ▼
┌──────────────────────────────────────┐          ┌──────────────────────────────────────┐
│            Native Adapter            │          │  MCP Adapter (FR-106 Future Gateway) │
│   *Injected Short-Lived Tokens* │          │     *Wrapped Credential Broker* │
└──────────────────┬───────────────────┘          └──────────────────┬───────────────────┘
                   │                                                 │
  ┌────────────────┼────────────────┐               ┌────────────────┼────────────────┐
  ▼                ▼                ▼               ▼                ▼                ▼
+------------+   +------------+   +------------+  +------------+   +------------+   +------------+
|  Database  |   |   Object   |   | Messaging  |  | Salesforce |   | Databricks |   | Custom API |
|   Adapter  |   |   Storage  |   | & Stream   |  | MCP Server |   | MCP Server |   | MCP Server |
+------------+   +------------+   +------------+  +------------+   +------------+   +------------+
  │                │                │               │                │                │
  └────────────────┴──────────────┬─┴───────────────┴────────────────┴────────────────┘
                                  │
                                  ▼
                        ┌──────────────────────────────┐
                        │ Raw Discovery Result Store   │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ Phase 3: Graph & Lineage     │
                        │ Inference Engine             │
                        └──────────────┬───────────────┘
                                       │
                     ┌─────────────────┴─────────────────┐
                     ▼                                   ▼
        ┌──────────────────────────┐        ┌──────────────────────────┐
        │ Evidence Store           │        │ Draft Graph Store        │
        │ *No Cached Secrets* │        └────────────┬─────────────┘
        └────────────┬─────────────┘                     │
                     │                                   │
                     └─────────────────┬─────────────────┘
                                       ▼
                        ┌──────────────────────────────┐
                        │ Human Review Queue           │
                        │ Required for uncertain edges │
                        └──────────────┬───────────────┘
                                       │
                                       ▼
                        ┌──────────────────────────────┐
                        │ Approved Graph Store         │
                        │ Neo4j / graph backend        │
                        └──────────────────────────────┘

```

---

## 3. Production Scaffolding Reference (Illustrative Only)

### 3.1. Tenant Configuration & Scope Policies (`tenant_policy.yml`)

Enforces structural multi-tenant constraints, agent autonomy parameters, and cryptographic isolation rule sets.

```yaml
version: "2.0"
tenant_id: "relix_enterprise_global"

scope_policy:
  allowed_node_patterns:
    - "prod_.*"
    - "analytics_.*"
    - "salesforce_.*"
    - "customer_.*"
    - "compute_.*"
  blocked_node_patterns:
    - "security_.*"
    - "payroll_.*"

agent_governance:
  execution_mode: "SUPERVISED"
  require_manifest_approval: true
  allow_autonomous_retry: false
  allow_deep_scan_without_approval: false
  max_autonomous_tasks: 25
  require_review_for:
    - "lineage_inference"
    - "cross_system_dependency"
    - "deep_scan"
    - "unsupported_target"

credential_security:
  secret_ref_only: true
  resolve_only_inside_executor: true
  redact_logs: true
  prohibit_secret_cache: true
  prohibit_secret_in_manifest: true
  rotate_token_supported: true
  least_privilege_required: true
  read_only_credentials_required: true

discovery_budget:
  max_nodes_per_run: 100
  max_tables_per_node: 500
  max_columns_per_table: 200
  max_tool_calls: 1000
  max_runtime_minutes: 30

rate_limiting:
  max_connections_per_minute: 60
  max_queries_per_minute: 300

```

### 3.2. Unified Tenant Topology Seeds (`tenant_topology_seed.yml`)

```yaml
version: "2.0"
tenant_id: "relix_enterprise_global"

database_nodes:
  prod_sales_pg:
    system_type: "postgres"
    profile: "postgres_profile"
    host_alias: "prod-sales-db-01.internal"
    port: 5432
    secret_ref: "vault://relix/tenant/prod_sales_pg"

api_storage_nodes:
  salesforce_prod:
    system_type: "salesforce"
    profile: "salesforce_profile"
    org_alias: "sf-prod"
    secret_ref: "vault://relix/tenant/salesforce_prod"

object_storage_nodes:
  customer_s3_lake:
    system_type: "s3"
    profile: "s3_profile"
    region_alias: "ap-south-1"
    secret_ref: "vault://relix/tenant/customer_s3_lake"
    discovery_scope:
      buckets:
        - "prod-sales-lake"
      prefixes:
        - "curated/sales/"

messaging_streaming_nodes:
  prod_corporate_kafka:
    system_type: "kafka"
    profile: "kafka_profile"
    bootstrap_servers: ["kafka-broker-01.internal:9092", "kafka-broker-02.internal:9092"]
    secret_ref: "vault://relix/tenant/prod_corporate_kafka"
    discovery_scope:
      include_topics:
        - "telemetry.*"
        - "orders-v1"

compute_processing_nodes:
  compute_prod_databricks:
    system_type: "databricks"
    profile: "databricks_profile"
    workspace_url: "https://prod-workspace.cloud.databricks.com"
    secret_ref: "vault://relix/tenant/compute_prod_databricks"
    discovery_scope:
      include_jobs:
        - "etl_.*"
        - "sync_.*"

unsupported_legacy_system:
  system_type: "unknown_legacy_platform"
  profile: "legacy_profile"
  secret_ref: "vault://relix/tenant/legacy_error"

```

---

### 3.3. Isolation Runtime & Audit Log Layers (`config_loader.py`)

```python
# config_loader.py
import re
import yaml
import time
import uuid
from typing import Dict, Any, List

class RelixConfigVault:
    def __init__(self, policy_path: str = "tenant_policy.yml", seed_path: str = "tenant_topology_seed.yml"):
        with open(policy_path, 'r') as f: self._policy = yaml.safe_load(f)
        with open(seed_path, 'r') as f: self._seed = yaml.safe_load(f)
            
        self.tenant_id = self._policy.get("tenant_id", "unknown")
        self.budget = self._policy.get("discovery_budget", {})
        self.rate_limits = self._policy.get("rate_limiting", {})
        self.gov_config = self._policy.get("agent_governance", {})
        self.sec_config = self._policy.get("credential_security", {})
        
        policy = self._policy.get("scope_policy", {})
        self._allowed_patterns = policy.get("allowed_node_patterns", [".*"])
        self._blocked_patterns = policy.get("blocked_node_patterns", [])
        
        self._all_nodes = {
            **self._seed.get("database_nodes", {}),
            **self._seed.get("api_storage_nodes", {}),
            **self._seed.get("object_storage_nodes", {}),
            **self._seed.get("messaging_streaming_nodes", {}),
            **self._seed.get("compute_processing_nodes", {})
        }

    def is_alias_permitted(self, alias: str) -> bool:
        for block_pat in self._blocked_patterns:
            if re.match(block_pat, alias): return False
        for allow_pat in self._allowed_patterns:
            if re.match(allow_pat, alias): return True
        return False

    def get_filtered_aliases(self) -> List[str]:
        return [alias for alias in self._all_nodes.keys() if self.is_alias_permitted(alias)]

    def get_node_metadata(self, alias: str) -> Dict[str, Any]:
        if not self.is_alias_permitted(alias): return {}
        return self._all_nodes.get(alias, {})

    def emit_audit_log(self, run_id: str, node: str, action: str, duration_ms: float, result: str):
        # FR-108: Explicit verification loop to block accidental credential leaks in logs
        if "pass" in result.lower() or "secret" in result.lower() or "token" in result.lower():
            result = "[REDACTED_BY_GOVERNANCE_FILTER]"
        print(f"[AUDIT TRAIL] Run: {run_id} | Target: {node} | Action: {action} | Result: {result}")

vault = RelixConfigVault()

class DiscoveryRunContext:
    def __init__(self, workflow_id: str = "topology_discovery_v0_1", override_mode: str = None):
        self.run_id = str(uuid.uuid4())
        self.tenant_id = vault.tenant_id
        self.workflow_id = workflow_id
        self.execution_mode = override_mode if override_mode else vault.gov_config.get("execution_mode", "SUPERVISED")
        self.started_at = time.time()
        self.nodes_processed = 0
        self.total_tool_calls = 0

    def check_budget_safety(self) -> bool:
        elapsed = (time.time() - self.started_at) / 60
        if self.total_tool_calls >= vault.budget.get("max_tool_calls", 1000): return False
        if self.nodes_processed >= vault.budget.get("max_nodes_per_run", 100): return False
        if elapsed >= vault.budget.get("max_runtime_minutes", 30): return False
        return True

```

---

### 3.4. Command Cache, Failure Memory, and Latency Resolver (`cache_manager.py`)

```python
# cache_manager.py
import time
from typing import Dict, Any, Optional

class DiscoveryCommandCache:
    def __init__(self):
        self._store: Dict[str, Dict[str, Any]] = {}

    def generate_key(self, tenant_id: str, workflow_id: str, node_alias: str, phase: str, command_signature: str) -> str:
        return f"{tenant_id}::{workflow_id}::{node_alias}::{phase}::{command_signature}"

    def get(self, key: str) -> Optional[Dict[str, Any]]:
        entry = self._store.get(key)
        if not entry: return None
        if time.time() > entry.get("expires_at", 0):
            del self._store[key]
            return None
        return entry

    def set_success(self, key: str, payload: Dict[str, Any], ttl_seconds: int = 86400):
        # FR-108 Guard: Guarantee absolutely no decrypted credentials bypass the memory barrier
        clean_payload = self._scrub(payload)
        self._store[key] = {
            "status": "SUCCESS", "data": clean_payload, "expires_at": time.time() + ttl_seconds,
            "last_seen_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        }

    def set_failure(self, key: str, error_code: str, retry_policy: str, ttl_seconds: int = 3600):
        self._store[key] = {
            "status": "FAILED", "error_code": error_code, "retry_policy": retry_policy,
            "expires_at": time.time() + ttl_seconds,
            "last_seen_at": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
        }

    def keys_matching_failure(self, tenant_id: str, workflow_id: str) -> list:
        prefix = f"{tenant_id}::{workflow_id}::"
        return [k for k, v in self._store.items() if k.startswith(prefix) and v["status"] == "FAILED"]

    def _scrub(self, data: Any) -> Any:
        if isinstance(data, dict):
            return {k: "[REDACTED]" if "secret" in k.lower() or "token" in k.lower() or "pass" in k.lower() else self._scrub(v) for k, v in data.items()}
        elif isinstance(data, list):
            return [self._scrub(item) for item in data]
        return data

class LatencyProfileResolver:
    def __init__(self):
        self._profiles: Dict[str, Dict[str, Any]] = {}
        self.configured_min_timeout_ms = 2000
        self.safety_factor = 2

    def get_profile(self, key: str) -> Dict[str, Any]:
        if key not in self._profiles:
            self._profiles[key] = {
                "last_latency_ms": 1000, "avg_latency_ms": 1000, "p95_latency_ms": 1500,
                "p99_latency_ms": 1800, "max_observed_latency_ms": 2000, "timeout_count": 0
            }
        return self._profiles[key]

    def calculate_timeout(self, key: str) -> int:
        prof = self.get_profile(key)
        recommended = prof["p99_latency_ms"] * self.safety_factor
        return max(self.configured_min_timeout_ms, recommended)

    def record_execution(self, key: str, latency_ms: float, was_timeout: bool):
        prof = self.get_profile(key)
        prof["last_latency_ms"] = latency_ms
        prof["max_observed_latency_ms"] = max(prof["max_observed_latency_ms"], latency_ms)
        prof["avg_latency_ms"] = int((prof["avg_latency_ms"] * 0.8) + (latency_ms * 0.2))
        prof["p99_latency_ms"] = int((prof["p99_latency_ms"] * 0.9) + (latency_ms * 1.1 if was_timeout else latency_ms * 0.1))
        if was_timeout: prof["timeout_count"] += 1

command_cache = DiscoveryCommandCache()
latency_resolver = LatencyProfileResolver()

```

---

### 3.5. Just-In-Time Secret Provider & Multi-Adapter Executor (`tools.py`)

```python
# tools.py
import time
import json
from typing import Dict, Any, List
from config_loader import vault, DiscoveryRunContext
from cache_manager import command_cache, latency_resolver

class RelixSecretProvider:
    """FR-108: Restricts secret resolution exclusively to runtime execution windows."""
    @classmethod
    def resolve_secret_ref(cls, secret_ref: str) -> Dict[str, str]:
        if not secret_ref.startswith("vault://"):
            raise SecurityException("Prohibited raw credential input pattern detected.")
        # Simulates secure call parameters to KMS/Vault endpoint
        return {"decrypted_token": "token_session_ap_south_1_temp_hash"}


class ConnectorCapabilityRegistry:
    REGISTRY = {
        "postgres_profile": {"adapter": "database", "capabilities": ["schema"]},
        "salesforce_profile": {"adapter": "standard_saas", "capabilities": ["objects"]},
        "s3_profile": {"adapter": "object_storage", "capabilities": ["file_listing", "schema_inference"]},
        "kafka_profile": {"adapter": "messaging_streaming", "capabilities": ["topics", "consumer_groups"]},
        "databricks_profile": {"adapter": "compute_processing", "capabilities": ["jobs", "notebooks", "lineage"]}
    }
    @classmethod
    def get_profile_mapping(cls, profile_name: str) -> Dict[str, Any]:
        return cls.REGISTRY.get(profile_name, {})

def generate_planner_scope() -> str:
    return json.dumps(vault.get_filtered_aliases())


class ManifestGovernanceController:
    @classmethod
    def process_and_filter(cls, context: DiscoveryRunContext, raw_manifest: Dict[str, Any]) -> Dict[str, Any]:
        mode = context.execution_mode
        risk_map = {
            "validate": "LOW", "schema": "LOW_MEDIUM", "listing": "MEDIUM", 
            "sampling": "MEDIUM", "topics": "MEDIUM", "compute_history": "MEDIUM_HIGH", 
            "lineage": "HIGH"
        }
        
        if mode == "DRY_RUN":
            print("[GOVERNANCE CONTROL] Dry run activated. No tasks released for execution.")
            return {"status": "DRY_RUN_HELD", "tasks": []}
            
        filtered_tasks = []
        for task in raw_manifest.get("tasks", []):
            task_risk = risk_map.get(task.get("phase"), "HIGH")
            alias = task.get("node_alias")
            
            node_meta = vault.get_node_metadata(alias)
            if not node_meta:
                task_risk = "HIGH"
            
            if mode == "INTERACTIVE":
                print(f"[MANIFEST APPROVAL GATE] Task for '{alias}' held. Awaiting human manual approval pass.")
                task["governance_status"] = "HELD_FOR_MANUAL_SIGN_OFF"
            elif mode == "SUPERVISED" and task_risk in ["MEDIUM_HIGH", "HIGH"]:
                print(f"[MANIFEST APPROVAL GATE] High-risk task ({task_risk}) for '{alias}' blocked under SUPERVISED mode.")
                task["governance_status"] = "HELD_RISK_BREACH"
            elif mode == "READ_ONLY_AUDIT" and task.get("mutation_intent", False):
                print(f"[GOVERNANCE CONTROL] Blocked mutating task for '{alias}' under READ_ONLY_AUDIT mode.")
                task["governance_status"] = "REJECTED_MUTATION_DENIED"
            else:
                task["governance_status"] = "RELEASED"
                filtered_tasks.append(task)
                
        return {"status": "RELEASED_TO_CORE", "tasks": filtered_tasks}


class ManifestDiscoveryExecutor:
    def __init__(self, context: DiscoveryRunContext):
        self.ctx = context

    def execute_manifest(self, final_manifest: Dict[str, Any]) -> Dict[str, Any]:
        self.ctx.total_tool_calls += 1
        if not self.ctx.check_budget_safety():
            return {"status": "DISCOVERY_EXHAUSTED"}

        results = []
        tasks_to_run = final_manifest.get("tasks", [])

        if self.ctx.execution_mode == "RECOVERY_ONLY":
            failed_keys = command_cache.keys_matching_failure(self.ctx.tenant_id, self.ctx.workflow_id)
            if not failed_keys:
                return {"status": "COMPLETED", "batch_results": []}

        for task in tasks_to_run:
            alias = task.get("node_alias")
            phase = task.get("phase")
            cmd_sig = f"scan_target_signature:{alias}"
            
            node_meta = vault.get_node_metadata(alias)
            profile_name = node_meta.get("profile")
            mapping = ConnectorCapabilityRegistry.get_profile_mapping(profile_name)
            
            if not mapping:
                results.append({
                    "node_alias": alias, "status": "CONNECTOR_NOT_FOUND"
                })
                continue

            cache_key = command_cache.generate_key(self.ctx.tenant_id, self.ctx.workflow_id, alias, phase, cmd_sig)
            
            if self.ctx.execution_mode == "RECOVERY_ONLY" and cache_key not in command_cache.keys_matching_failure(self.ctx.tenant_id, self.ctx.workflow_id):
                continue

            cached_record = command_cache.get(cache_key)
            if cached_record and self.ctx.execution_mode != "RECOVERY_ONLY":
                if cached_record["status"] == "SUCCESS":
                    results.append(cached_record["data"])
                    continue

            computed_timeout = latency_resolver.calculate_timeout(cache_key)
            
            # --- FR-108: Just-In-Time Ephemeral Secret Injection Runtime ---
            s_ref = node_meta.get("secret_ref")
            runtime_token = RelixSecretProvider.resolve_secret_ref(s_ref)
            
            start_ts = time.time()
            adapter_type = mapping["adapter"]
            payload = {"node": alias, "adapter_type": adapter_type, "status": "SUCCESS", "phase": phase}
            
            # Simulates secure delivery to execution container driver
            # Driver utilizes runtime_token['decrypted_token'] out-of-scope, dropping it immediately post-execution
            if adapter_type == "object_storage":
                payload["metadata"] = {"bucket": "prod-sales-lake", "prefix": "curated/sales/"}
                payload["inferred_schema"] = {"format": "parquet", "columns": [{"field": "revenue", "type": "NUMERIC"}]}
            elif adapter_type == "compute_processing":
                payload["discovered_compute"] = {
                    "jobs": {"etl_sales_sync_daily": {"inputs": ["customer_s3_lake"], "outputs": ["prod_sales_pg"]}}
                }

            # Volatile variable cleanup
            del runtime_token 

            duration_ms = (time.time() - start_ts) * 1000
            latency_resolver.record_execution(cache_key, duration_ms, was_timeout=False)
            
            payload["latency_profile"] = latency_resolver.get_profile(cache_key)
            command_cache.set_success(cache_key, payload)
            results.append(payload)

        return {"status": "COMPLETED", "batch_results": results}
class SecurityException(Exception): pass

```

---

### 3.6. Knowledge Store & Evidence Graph (`graph_model.py`)

```python
# graph_model.py
from typing import List, Dict, Any

class RelixEvidenceGraphStore:
    def __init__(self):
        self.draft_nodes: List[Dict[str, Any]] = []
        self.draft_edges: List[Dict[str, Any]] = []
        self.evidence_ledger: Dict[str, Dict[str, Any]] = {}
        self.approved_graph: List[Dict[str, Any]] = []

    def register_draft_edge(self, edge_id: str, source: str, target: str, rel: str):
        self.draft_edges.append({"id": edge_id, "source": source, "target": target, "relation": rel})

    def attach_evidence(self, edge_id: str, run_id: str, adapter: str, confidence: float, reason: str, payload: list):
        # FR-108: Validates no active secret leakage occurs inside saved graph parameters
        clean_payload = self._sanitize(payload)
        self.evidence_ledger[edge_id] = {
            "run_id": run_id, "adapter_type": adapter, "confidence": confidence, "reason": reason, "evidence_payload": clean_payload
        }

    def commit_to_approved_store(self, edge_id: str):
        edge = next((e for e in self.draft_edges if e["id"] == edge_id), None)
        if edge and edge not in self.approved_graph: self.approved_graph.append(edge)

    def _sanitize(self, data: Any) -> Any:
        if isinstance(data, dict):
            return {k: "[REDACTED]" if "secret" in k.lower() or "token" in k.lower() else self._sanitize(v) for k, v in data.items()}
        elif isinstance(data, list):
            return [self._sanitize(i) for i in data]
        return data

relix_store = RelixEvidenceGraphStore()

```

---

### 3.7. Comprehensive Pipeline Execution Loop (`app.py`)

```python
# app.py
import json
from google.adk.agents import LlmAgent
from google.adk.runtime import AgentRuntime
from config_loader import vault, DiscoveryRunContext
from tools import generate_planner_scope, ManifestGovernanceController, ManifestDiscoveryExecutor
from graph_model import relix_store

def run_production_pipeline():
    run_context = DiscoveryRunContext(workflow_id="topology_discovery_v0_1")
    
    instruction = """
    You are the Lead Relix Discovery Planner Agent.
    Your responsibility is to check configuration targets and emit a structured Task Manifest JSON.
    You do NOT call network sockets or infrastructure elements directly.
    """

    planner_agent = LlmAgent(
        model="gemini-2.5-flash", name="RelixManifestPlanner", instruction=instruction, tools=[generate_planner_scope]
    )

    runtime = AgentRuntime()
    runtime.register_agent(planner_agent)

    print(f"[{run_context.tenant_id.upper()}] Running Phase 1: Planning Manifest Generation...")
    agent_output = planner_agent.ask(
        "Generate tasks for: customer_s3_lake (phase: listing), compute_prod_databricks (phase: compute_history), and unsupported_legacy_system."
    )

    raw_manifest_text = agent_output.text.replace("```json", "").replace("```", "").strip()
    manifest_data = json.loads(raw_manifest_text)
    
    print(f"[{run_context.tenant_id.upper()}] Routing Manifest to Phase 2 Governance & Approval Controllers...")
    cleared_manifest = ManifestGovernanceController.process_and_filter(run_context, manifest_data)
    
    if cleared_manifest["status"] == "DRY_RUN_HELD":
        return

    executor = ManifestDiscoveryExecutor(context=run_context)
    raw_results = executor.execute_manifest(cleared_manifest)

    if raw_results.get("status") == "COMPLETED":
        print(f"[{run_context.tenant_id.upper()}] Phase 3: Committing Approved Facts & Registering Uncertain Elements...")
        
        for batch_item in raw_results.get("batch_results", []):
            alias = batch_item.get("node")
            if batch_item.get("status") == "CONNECTOR_NOT_FOUND":
                continue

            adapter = batch_item.get("adapter_type")
            
            if adapter == "object_storage":
                edge_bucket = f"edge_{alias}_bucket"
                relix_store.register_draft_edge(edge_bucket, alias, "prod-sales-lake", "CONTAINS")
                relix_store.commit_to_approved_store(edge_bucket)

            elif adapter == "compute_processing":
                compute_data = batch_item.get("discovered_compute", {})
                for job_name, job_meta in compute_data.get("jobs", {}).items():
                    edge_job = f"edge_{alias}_{job_name}"
                    relix_store.register_draft_edge(edge_job, alias, job_name, "CONTAINS")
                    relix_store.commit_to_approved_store(edge_job)

    print(f"\nPipeline Finished under Mode: {run_context.execution_mode}")
    print(f"Approved Production System Graph: {relix_store.approved_graph}")

if __name__ == "__main__":
    run_production_pipeline()

```

---

## 4. Platform Unified Graph Model Ontology

The Unified Graph model standardizes nodes and edges across every supported technology stack, turning raw technical footprints into an interconnected operational landscape.

### 4.1. Complete Node Type Classifications

| Node Type | Domain Integration | Functional Description |
| --- | --- | --- |
| `SaaSSystem` | FR-101 | Standard enterprise cloud SaaS deployment instance (e.g., Salesforce, Workday). |
| `APIService` | FR-101 | Custom, private, or vendor network interface cluster endpoint footprint. |
| `Endpoint` | FR-101 | A unique operations route pathway tracking access signatures (e.g., `/v1/charges`). |
| `Method` | FR-101 | HTTP request execution verb type mapping (e.g., `GET`, `POST`, `DELETE`). |
| `Resource` | FR-101 | Abstract business object layer exposure target (e.g., `Account` entity record layout). |
| `RequestSchema` | FR-101 | Structural input argument payload definition mapping requirements. |
| `ResponseSchema` | FR-101 | Structural output message payload definition mapping signatures. |
| `ObjectStore` | FR-102 | Root infrastructure file storage platform wrapper (e.g., AWS S3, GCS, Azure Blob). |
| `Bucket` | FR-102 | Isolated root document directory partition tracking namespace instances. |
| `Container` | FR-102 | Explicit logical folder boundary tracking files on Azure Blob systems. |
| `Prefix` | FR-102 | Nested logical virtual folder pathway path string configurations. |
| `ObjectFile` | FR-102 | Physical file component instance located during sampling passes (e.g., `part-0.parquet`). |
| `DataLakeTable` | FR-102 | Virtual structured database table catalog tracked inside external metastores. |
| `Partition` | FR-102 | Partitioning scheme or index routing criteria definitions. |
| `FileFormat` | FR-102 | Underlying compression format encoding types (e.g., Delta, Iceberg, Hudi, CSV). |
| `MessageBroker` | FR-103 | Core real-time asynchronous data event routing engine instance (e.g., Kafka Cluster). |
| `Topic` | FR-103 | Persistent log-based streaming category channel (e.g., `telemetry.ingress`). |
| `Queue` | FR-103 | Sequential point-to-point data ingestion target buffer channel (e.g., AMQP Queue). |
| `ConsumerGroup` | FR-103 | Coordinated pool of application processes pulling streams in parallel. |
| `Subscription` | FR-103 | Explicit link properties routing data events down to targets. |
| `ComputeCluster` | FR-104 | Distributed compute processing environments or query planes (e.g., Databricks Workspace). |
| `Job` | FR-104 | Orchestrated workflow execution container configuration (e.g., Airflow DAG, Databricks Job). |
| `Task` | FR-104 | Atomic transformation processing step executed inside a parent Job. |
| `Notebook` | FR-104 | Interleaved documentation and executable transformation codebase entity. |
| `Schema` | Core Model | Structural configuration dictionary detailing structural attributes. |
| `Field` | Core Model | Individual structural record node tracking an atomic, typed column element. |

---

## 5. Multi-Tenant Cache & Failure Memory Classification Matrix

The Command Cache works alongside the execution layer to categorize and track the following state behaviors:

| Target System Status | Cache Record Type | Retention Policy (TTL) | Operational Behavior |
| --- | --- | --- | --- |
| **`SUCCESS`** | Data Present | 86,400 sec (24 Hours) | Skips network execution loops entirely and returns cached assets if configurations remain static. |
| **`TIMEOUT`** | Network Anomaly | 300 sec (5 Mins) | Halts network traffic toward the affected path during the cooldown period, permitting retries only after the timeout clears. |
| **`CONNECTOR_NOT_FOUND`** | Functional Fault | 3,600 sec (1 Hour) | Blocks retry paths completely until structural registry updates or platform version changes are verified. |
| **`ACCESS_DENIED`** | Security Gate | 1,800 sec (30 Mins) | Postpones system query logic until credential vault references or security access tokens are explicitly updated. |
| **`SCHEMA_CHANGED`** | Validation Signal | 0 sec (Evict Immediately) | Overrides existing cache layers and triggers immediate fresh scans to re-verify metadata topologies. |

---

## 6. Dynamic Adaptive Timeout Engine Specification

Instead of deploying static configuration timeouts globally, the **Latency Profile Resolver** tracks runtime performance variations per individual tenant, target node, and operational command phase using an exponential moving average.

### 6.1. Timeout Calculation Formula

The dynamic timeout threshold is adjusted using the $99\text{th}$ percentile latency metric multiplied by an integrated safety buffer, bounded by a global floor value:

$$\text{recommended\_timeout\_ms} = \max\left(\text{configured\_min\_timeout\_ms}, \;\; \text{p99\_latency\_ms} \times \text{safety\_factor}\right)$$

### 6.2. Stability Classification Rules

* **Under-Threshold Latency Volatility:** Network anomalies resulting in execution timeouts *below* the recommended timeout ceiling are flagged as transient infra spikes, leaving the command history profile intact.
* **Over-Threshold Latency Breaches:** Probes that exceed calculated performance limits trigger immediate degradation state steps, marking the target engine as `UNSTABLE`.
* **Sustained Failures:** If a path times out consistently across multiple runs, it is suppressed entirely and placed on a cooldown holding track, protecting network bandwidth from systemic failures.

---

## 7. Knowledge Processing & Governance Approval Gates

Data structures require different levels of human verification depending on the certainty of the discovery process:

```text
Discovery Source Data
    │
    ├── Fine-Grained Deterministic Facts ──> [Auto-Approved Store] (Neo4j Backend)
    │   (Bucket names, Region strings, Broker topics, Job names, native metadata schemas)
    │
    ├── Sampled Infrastructure Formats  ──> [Evidence Store] ──> [Human Review Queue]
    │   (Footer file parsing, OpenAPI parsing)
    │
    └── Probabilistic Trace Assertions   ──> [Evidence Store] ──> [Human Review Queue]
        (Name correlations, log query hints, cross-system ETL links)

```

* **Automated Approval Pass:** Highly certain structure properties obtained via native metadata schemas (such as active Kafka partition counts, bucket regions, Databricks Job configurations, or table constraints) bypass verification tracks completely and write instantly to the production graph store with a confidence score of $1.0$.
* **Evidence-Backed Verification Pass:** Structural variations derived by actively sampling files (such as footers from raw `.parquet` binary files or schema parameters from a running OpenAPI contract map) are compiled alongside verification details and routed to the queue.
* **Human Review Pass:** Highly probabilistic dependencies—including cross-system pipeline linkages inferred from logging files, transformation source components, directory names, or string matches—must be preserved inside the `Evidence Store` and require manual engineering sign-off before hitting production storage.

---

## 8. Strategic Roadmap Architecture Integration

### 8.1. FR-104 — Compute & Processing Discovery Implementation (v0.6.1 Integrated)

The inclusion of `compute_processing` nodes extends the platform to trace transient data computation tasks, distributed processing platforms, and scheduled workflows. This capability interfaces directly with external job managers to reconstruct lineage dependencies.

* **Target Platforms:** Databricks Workflow Clusters, Apache Spark Cluster states, Apache Airflow DAG Engines, AWS Glue Metastore Registries, Azure Data Factory Pipelines, EMR Core infrastructure configurations, Google Cloud Dataflow Jobs.
* **Operational Execution Process:** The executor bypasses intermediate query structures, reading the runtime history payload straight from the orchestrator API. Discovered job inputs and outputs are isolated into structured transformation records and sent to the lineage assembler.

### 8.2. FR-106 — Model Context Protocol (MCP) Tool Gateway Integration (v0.6.1 Option)

The platform architecture establishes a strict governance rule for the integration of third-party systems via the Model Context Protocol (MCP). **MCP servers operate strictly as execution tools, never as planning authorities.** * **Decoupled Topology Boundary:** The Phase 1 Planner Agent remains completely decoupled from the transport tier and has no visibility into MCP discovery loops. It outputs standard declarative manifests.

* **Governance Wrapper Layer:** The Relix Executor interacts with the `Connector Profile Layer` to dispatch tasks. MCP serves as an optional connector transport layer sitting directly behind a Relix-owned governance wrapper (`MCP Adapter`). This setup ensures that Relix uniformly enforces structural budgets, `secret_ref` masking, policy scopes, multi-tenant caching, latency profiling, token rate-limiting, audit logging, and evidence rules across both native and protocol-driven pipelines.

---

## 9. FR-107 — Agent Governance and Execution Mode Classification

### 9.1. Core Philosophy

Agent autonomy is not binary. To maintain a strict enterprise security baseline, authority is classified into a matrix structured by task risk, tenant configuration maturity, connector health, and overall discovery path depth.

> **Structural Security Lock:** Autonomy configurations control planning and execution scope privileges exclusively. They never bypass configuration scope boundaries, the component registry, caching layers, safety rate thresholds, or the Phase 3 evidence review queue.

### 9.2. Governance Authority Classes

The framework segments authority levels into six distinct operational execution blocks:

| Class | Mode | Approving Authority | Network Execution Pass | Optimal Production Placement |
| --- | --- | --- | --- | --- |
| **G0** | `DRY_RUN` | None Required | Completely Disabled | Independent manifest validation, target configuration scoping, and budget testing passes. |
| **G1** | `INTERACTIVE` | Human Engineer before execution loop | Blocked until manual sign-off | First-time tenant initialization, new cluster profiles, or sensitive connector rollouts. |
| **G2** | `SUPERVISED` | Human review required for high-risk flags | Allowed automatically for low/medium metrics | Standard Enterprise UAT and system tenant onboarding environments. |
| **G3** | `AUTONOMOUS_READ_ONLY` | Pre-approved workspace policy templates | Enabled (Strict Mutation Lockout) | Recurring, production-safe schema capture and structural inventory checks. |
| **G4** | `AUTONOMOUS_DEEP` | Pre-approved policies + strict budget windows | Full Autonomous Access | Deep data lake footer sampling and performance analysis inside trusted environments. |
| **G5** | `RECOVERY_ONLY` | Pre-analyzed policy rulesets | Confined strictly to cached failure paths | Post-failure automated reruns, targeting network timeouts and connection anomalies. |

### 9.3. Dynamic Strategic Decision Matrix

Operational runtime tracking maps target conditions to recommended execution modes seamlessly:

```text
       Tenant Security Phase
         ├── Brand New Tenant / Profile ─────────> INTERACTIVE (G1)
         ├── Validation & Testing Passes ────────> DRY_RUN (G0)
         ├── Enterprise Onboarding / UAT ────────> SUPERVISED (G2)
         │
         └── Mature Production Baseline
               ├── Scheduled Metadata Ingress ───> AUTONOMOUS_READ_ONLY (G3)
               ├── Lineage Inference Pipelines ──> SUPERVISED (G2) or AUTONOMOUS_DEEP (G4)
               └── Infrastructure Reruns ────────> RECOVERY_ONLY (G5)

```

### 9.4. Task Operational Risk Taxonomy

Specific structural targets trigger immediate operational constraints inside the **Execution Mode Controller**:

| Task Type | Risk Level | Default Mode Minimum | Governance Guard Behavior |
| --- | --- | --- | --- |
| List Inventory Aliases / Config Check | Low | `DRY_RUN` / `INTERACTIVE` | Evaluation passes without network transport generation. |
| Database Schema Discovery | Low-Medium | `AUTONOMOUS_READ_ONLY` | Reads system catalog tables; strict mutation lock applied. |
| Object Storage Ingress | Medium | `SUPERVISED` | Bounded file list parsing limited by configured object budgets. |
| Deep Data Lake File Sampling | Medium | `SUPERVISED` | Target extraction strictly throttled by the Adaptive Timeout calculation engine. |
| API / SaaS Metadata Collection | Medium | `SUPERVISED` | Executed behind Token-Bucket protection under explicit scope limits. |
| Messaging Topology Traversal | Medium | `SUPERVISED` | Isolation of topic properties; active consumer groups are not perturbed. |
| Distributed Compute Job Tracing | Medium-High | `SUPERVISED` | Retains workflow execution logs without impacting running workflows. |
| Graph Lineage Synthesis | High | `SUPERVISED` / `AUTONOMOUS_DEEP` | Mandatory insertion of relationship context artifacts into the Human Review Queue. |
| Unsupported Target Fallback | High | No Execution | Execution terminates on target loop; path marked as `UNSUPPORTED_DISCOVERY_TARGET`. |

---

## 10. FR-108 — Credential Security, Secret Isolation & Access Governance

### 10.1. Zero-Trust Access Paradigm

To satisfy enterprise compliance benchmarks, the platform separates the intelligence planning process from secret storage layers. **The raw target credentials are never accessible to, or managed by, the LLM-driven runtime systems.**

### 10.2. Cryptographic Isolation Rules

The framework enforces strict operational boundaries across all modules to eliminate risk vectors:

* **Planner Decoupling Boundary:** The Phase 1 Planner Agent operates strictly within systemic dictionary parameters. It never requests or reviews raw infrastructure keys.
* **Manifest Disconnect:** Task Manifest data objects maintain structural properties containing only unique logical identities and `secret_ref` pointers.
* **Cache Isolation Guard:** Decrypted strings are completely prohibited from entering database or file memory tables. Cache keys rely solely on public workflow configurations.
* **Log and Evidence Scrubbing Matrix:** An automated serialization interceptor strips out variable combinations matching high-risk signatures (such as password parameters, access hashes, token blocks, or session values) from execution dumps, audit streams, error logs, and the evidence repository.

### 10.3. Dynamic Just-In-Time Secret Resolution Controls

Credentials pass through a strict verification lifecycle inside the non-LLM execution segment:

| Control Target | Structural Implementation Blueprint | Operational Security Value |
| --- | --- | --- |
| **`secret_ref` Exclusivity** | Configuration parameters index string tags pointing to an external Vault system (e.g., `vault://tenant/target`). | Eradicates plain-text configuration storage vulnerabilities. |
| **Executor-Only Resolution** | Real decryption occurs exclusively inside the bounded execution process thread right before execution. | Prevents LLMs, prompt injections, or trace dumps from accessing raw secrets. |
| **Read-Only Service Isolation** | Integration profiles enforce the use of minimal, read-only discovery permissions. | Prevents unauthorized data modifications or cluster resource usage. |
| **Just-In-Time Lifecycles** | Decrypted strings exist as short-lived volatile memory references and are scrubbed post-execution. | Limits the lifespan of credentials in active system memory. |
| **Zero Persistence Policy** | Decrypted secrets are never committed to permanent storage, temp folders, or internal tables. | Eliminates exposure via system snapshots or disk logs. |
| **Rotation Trigger Validation** | Updating a key's secret version invalidates its cache entries, triggering an immediate scan. | Guarantees telemetry continuity during credential rotations. |
| **Reference Audit Trail** | Log architectures track the access use of the `secret_ref` identifier without printing secrets. | Provides compliance accountability without risk exposure. |

### 10.4. Secure Model Context Protocol (MCP) Token Ingestion Flow

When integrating external utilities via the Model Context Protocol, Relix blocks the direct exposure of structural enterprise credentials to unverified third-party MCP target configurations.

```text
  [Relix Discovery Executor]
              │
              ▼ (1) Reads system vault pointer reference
  [Relix Secret Provider] ──> Resolves root credentials from external Vault
              │
              ▼ (2) Generates short-lived, low-privilege scoped token
  [Connector Governance Wrapper]
              │
              ▼ (3) Injects restricted transient token session
     [MCP Adapter Gateway] ──> Safely routes access queries to third-party tools

```

This multi-layered approach ensures that the Relix framework retains absolute ownership of the transport session, protecting target infrastructure systems from exposure.

---

## 11. Architecture Freeze Verification Criteria

The platform meets freeze requirements and satisfies all compliance checks when:

1. Every technology type maps cleanly via the `Connector Capability Registry` to standard adapter implementations, keeping the `Planner Agent` single, simple, and isolated from technology changes.
2. If an unsupported combination is requested, the executor flags it as a `CONNECTOR_NOT_FOUND` state, and the agent logs it as an `UNSUPPORTED_DISCOVERY_TARGET` instead of halting the runner loop.
3. The cache engine filters commands by matching combinations of tenant IDs, the explicit `workflow_id`, target nodes, and command signatures, preventing redundant network queries across runs that share a design schema.
4. Adaptive timeouts calculate thresholds dynamically based on running performance percentiles, shielding external APIs and networks from request spikes.
5. Inferred lineage paths and sampled data lake properties are tagged with structural evidence context and held for human verification before hitting production.

---

## Final Freeze Baseline Status

**System Status:** ARCHITECTURE FROZEN | APPROVED

The baseline specification is established and frozen under the following operating guarantees:

* **One Planner:** Centralized task layout generation isolated from system endpoints.
* **One Executor:** Code-driven, deterministic manifest runtime router.
* **One Registry:** Uniform capabilities profiling layer mapping software engines.
* **Many Adapters:** Modular technology drivers extending execution pathways natively or through secure protocol gateways.
* **Evidence Governance:** Segregation of deterministic facts from probabilistic dependencies.
* **Adaptive Intelligence:** Dynamic cache routing with continuous latency profiling and timeout adjustment.
* **Zero-Trust Access:** Decoupled secret token lifecycle tracking sitting behind a strict data isolation boundary.

```text
Relix Enterprise Metadata Discovery Platform v0.6.1 Architecture Freeze
Status: APPROVED

```

---

## 12. Implementation Requirements Tracker & Phase Plan

To guide next steps following this formal architecture freeze, the baseline requirements are mapped directly to a three-tier milestone implementation strategy.

### 12.1. Feature Requirements Matrix Traceability

| Requirement ID | Architectural Core Component | Verification Gateway | Implementation Target |
| --- | --- | --- | --- |
| **FR-101** | Standard SaaS & Custom API Drivers | Contract Map Parser Check | Milestone 2 (v0.6.1 Core) |
| **FR-102** | Object Storage & Data Lake Catalog | Schema Inference Extractor | Milestone 2 (v0.6.1 Core) |
| **FR-103** | Streaming & Message Log Buffers | Consumer Group Matrix Mapper | Milestone 3 (v0.6.1 Event) |
| **FR-104** | Distributed Compute Core Tracing | Job Ingestion Pipeline Trace | Milestone 1 (v0.6.1 Baselines) |
| **FR-105** | Command Cache & Latency Engine | Dynamic Percentile Timeout Formula | Milestone 2 (v0.6.1 Core) |
| **FR-107** | Execution Mode Governance Controller | Task Risk Interceptor Gate | Milestone 1 (v0.6.1 Baselines) |
| **FR-108** | Cryptographic Vault Secret Protection | Just-In-Time Decryption Thread | Milestone 1 (v0.6.1 Baselines) |

### 12.2. Roadmap Execution Timeline Plan

```text
  MILESTONE 1: Foundation Baseline Setup (v0.6.1 Core) ──> CURRENT FROZEN BASELINE
    ├── Build decoupled Phase 1 LLM Planner Agent & YAML Policy Config Loader
    ├── Construct Phase 2 Manifest Execution Engine with hardcoded capability checks
    ├── Integrate FR-107 Execution Controller (DRY_RUN, SUPERVISED risk gates)
    └── Implement FR-108 cryptographic Vault runtime isolation & automated log redaction
  
  MILESTONE 2: Target Storage & Optimization Engine Expansion (v0.6.1 Engine)
    ├── Deliver FR-101 (SaaS OpenAPI Contract Maps) & FR-102 (S3 Parquet Footer Samplers)
    └── Release FR-105 Multi-Tenant Command Cache & Adaptive Timeout Latency Profilers
  
  MILESTONE 3: Complex Event Systems & Compute Lineage Synthesis (v0.6.1/v0.6.1 Track)
    ├── Roll out FR-103 Streaming Log Topologies (Kafka Topic Cluster Metadata extraction)
    └── Integrate FR-104 Advanced Compute Pipelines (Databricks Workflows / Lineage Ingestion)

```

---

## 13. Scope Boundary & Subsystem Decoupling

The architectural definitions and code scaffolds established in this document are strictly confined to the **Relix Topology, Schema & Lineage Discovery** subsystem.

```text
┌────────────────────────────────────────────────────────────────────────┐
│               RELIX METADATA DISCOVERY SUBSYSTEM (In Scope)            │
│  Planner Agent ──> Manifest ──> Governance Gate ──> Discovery Executor │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
                                    ▼ Outputs
                        ┌──────────────────────┐
                        │ Approved Graph Store │
                        │ Evidence Store       │
                        │ Topology Metadata    │
                        └───────────┬──────────┘
                                    │
                                    ▼ Consumed By
┌───────────────────────────────────┴────────────────────────────────────┐
│              EXTERNAL OPERATIONAL WORKFLOWS (Out of Scope)             │
│   Migration  •  Backup/Recovery  •  Reconciliation  •  Validation Logs │
└────────────────────────────────────────────────────────────────────────┘

```

### 13.1. Explicit Domain Boundaries

* **In-Scope Boundaries:** The isolated Phase 1 Planner Agent, Agent Governance Policies (FR-107), Manifest Approval Gates, JIT Credential Isolation (FR-108), the Discovery Executor, the Connector Capability Registry, multi-tenant command caching (FR-105), dynamic adaptive latency profiling, and the Phase 3 Graph Inference/Human Review Engine.
* **Out-of-Scope Boundaries:** Cross-tenant migration orchestration, backup/restore enforcement plans, transactional data reconciliation engines, automated environment validation, and macro-level operational automation runs.

### 13.2. Downstream Consumption Pattern

Downstream operational systems and external automation pipelines may freely ingest the persistent states generated by this engine—specifically the **Approved Graph Store**, the **Evidence Store**, and structural **Topology Metadata**. However, the agent frameworks, deterministic software routines, policy boundaries, and approval criteria for those distinct downstream processes are isolated inside their respective solution-level design specifications and do not impact the frozen state of this discovery engine.

---

## 14. Public API Boundary

The discovery subsystem exposes public API contracts to orchestrate and query its internal operations. To avoid overloading this systemic baseline specification, explicit endpoint schemas, full JSON body payloads, concrete HTTP/gRPC status codes, specific RBAC definitions, and pagination implementations are kept out of scope here and are maintained separately in `discovery_api_contract.md`.

### 14.1. Core API Categories & Allowed Operations

External callers interact with the subsystem through four restricted gateway surfaces:

* **Planning & Run Lifecycle Management:**
* Request the generation of a new declarative `Task Manifest` for a given tenant profile seed.
* Initialize an isolated asynchronous `Discovery Run Context` (`run_id`).
* Query the real-time execution metrics, tool budget usage, and execution status of an active run.


* **Governance Manifest Authorization:**
* Retrieve a generated manifest awaiting sign-off under `INTERACTIVE` or `SUPERVISED` execution modes.
* Submit approval, partial rejection, or targeted task modifications to clear the `Manifest Approval Gate`.


* **Evidence Ledger & Human Review Queue:**
* Fetch unverified, probabilistic, or sampled assertions (edges and schema updates) stored inside the `Evidence Store`.
* Commit approval or manual dismissal overrides for pending queue records.


* **Discovery Graph Retrieval:**
* Pull verified, auto-approved metadata topologies directly from the `Approved Graph Store`.
* Stream fine-grained asset metadata lineages to downstream systems.



### 14.2. Ownership & Security Boundary Constraints

* **Auth Isolation:** Every public API gateway invocation requires a validated multi-tenant context token. External callers cannot bypass tenant boundaries.
* **Secret Masking Guarantee:** No API category exposes decrypted credentials or raw structural secrets. Calls inspecting logs, runs, manifests, or evidence payloads receive strictly scrubbed outputs in accordance with zero-trust access principles.
* **Write Lockout:** Mutation operations through the public API boundary are restricted exclusively to manifest scheduling, governance overrides, and evidence review actions. The underlying infrastructure states cannot be modified through this discovery subsystem channel.

---

```text
Relix Discovery Subsystem Isolation Boundary & Public API Split
Status: VERIFIED & APPENDED TO BASELINE

```
