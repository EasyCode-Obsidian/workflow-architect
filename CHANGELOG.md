# Changelog

All notable changes to the Workflow Architect skill suite.

---

## [v2.0.0] — 2026-05-06

### Production-Grade Upgrade

This release fundamentally reorients all skills from MVP-level output to production-ready, shippable quality.

#### Core Change: NFRs Elevated from Optional to Mandatory

Previously, Non-Functional Requirements (performance, security, observability) were in the "desirable" category — only 3 of 5 desirable categories needed partial coverage. This meant production-critical concerns could be legally skipped.

**Now:**
- **Category 6 (Performance & Scalability)** — MANDATORY, must reach "clear"
- **Category 7 (Security & Compliance)** — MANDATORY, must reach "clear"  
- **Category 9 (Observability & Operations)** — desirable, must reach at least "partial"
- Coverage threshold raised from "3/5 partial" to "4/5 partial"

#### New: Production Architecture (Phase 2, Section 5)

Phase 2 draft gains a dedicated Production Architecture section with BS-8 brainstorm trigger, covering:
- Deployment architecture (containers, orchestration, infrastructure diagrams)
- Observability design (metrics, logging, tracing, health checks, alerting)
- Security hardening (network segmentation, secrets management, TLS, vuln scanning)
- Data protection (backup strategy, encryption, RPO/RTO, PII handling)
- Scaling & resilience (auto-scaling, rate limiting, circuit breakers, graceful degradation)
- CI/CD pipeline (build → test → scan → deploy, rollback strategy)
- Runbooks & operations (incident response, SLI/SLO, on-call)
- Infrastructure as Code (Terraform/Pulumi/CDK)

#### New: Production Readiness Verification

- Phase 3 verification gains **Check 7: Production Readiness Coverage** (6 sub-checks)
- Phase 4 completion protocol now includes security scan, performance benchmark, observability audit, deployment verification
- Phase 4 milestone checkpoints display production readiness status per phase
- Pre-Launch Checklist added to completion report

#### HARD-GATE Additions

- **Rule 9:** All deliverables target production-ready quality — not MVP or demo
- **Rule 10:** NFRs are NOT optional — categories 6 and 7 must reach "clear" before Phase 2
- **Rule 8 (project-surgeon):** Production-grade improvements — observability, security, and operations are part of every improvement

#### Taxonomy Expansion: 10 → 12 Categories

```
Before:                      After:
Mandatory (5):               Mandatory (7):
  1. Vision                    1. Vision
  2. Scope                     2. Scope
  3. Users                     3. Users
  4. Data                      4. Data
  5. Tech Stack                5. Tech Stack
                               6. Performance & Scalability  ← NEW mandatory
Desirable (5):                 7. Security & Compliance      ← NEW mandatory
  6. Integration              
  7. NFRs (perf/sec/scale)    Desirable (5):
  8. UX                        8. Integration
  9. Dev Constraints           9. Observability & Operations ← split from NFRs + CI/CD
  10. Edge Cases              10. UX
                              11. Development & Quality
                              12. Edge Cases, Risk & Disaster Recovery
```

#### Brainstorm Protocol

- New trigger point **BS-8** (Phase 2): Production readiness design review
- Phase 2 now runs 5 brainstorms (was 4)

#### All Skills Affected

- `workflow-architect` — full 5-phase protocol upgrade
- `project-surgeon` — 7-dimension review now includes production readiness; execution gains Production Hardening phase
- `workflow-architect-lite` — HARD-GATE adds production-grade output rule
- `project-surgeon-lite` — HARD-GATE adds production-grade improvements rule
- `codex/` variants — all synced

---

## [v1.4.0] — 2026-04-XX

- feat: add Phase 0 pre-research, Context Bus, and Task Research Agent
- fix: unlock DeepWiki cross-phase research and strengthen research infrastructure

## [v1.3.0] — 2026-04-XX

- feat: add deep-interview skill and enhance Phase 1 with PQCP protocol

## [v1.2.0] — 2026-04-XX

- feat: add code-reviewer skill with 10-dimension × 4-role fused audit

## [v1.1.0] — 2026-04-XX

- feat: add lite versions of workflow-architect and project-surgeon
- refactor: promote sub-skills to top-level directories for Claude Code discovery

## [v1.0.0] — 2026-04-XX

- feat: add project-surgeon skill for existing project takeover
- feat: split skill into Claude Code and Codex CLI versions
- Initial release: Workflow Architect skill for Claude Code
