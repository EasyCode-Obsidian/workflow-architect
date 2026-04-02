# Analysis Protocol — 项目分析启发式协议

> This document defines the heuristic rules for detecting technology stacks, frameworks,
> project scale, and directory exclusions during Phase 1 analysis.
> Referenced by [phase-1-analysis.md](phase-1-analysis.md) Step 1.

<!-- 本文档定义 Phase 1 分析中用于检测技术栈、框架、项目规模和目录排除的启发式规则。 -->

---

## Tech Stack Detection Heuristics（技术栈检测启发式）

### Ecosystem Identification Table

<!-- 按生态系统列出 manifest、lockfile、入口点、包管理器、测试框架和构建工具。 -->

| Ecosystem | Manifest File(s) | Lockfile(s) | Entry Point(s) |
|---|---|---|---|
| **Node.js / TypeScript** | `package.json` | `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` | `index.js`, `index.ts`, `app.js`, `app.ts`, `server.js`, `server.ts` |
| **Python** | `pyproject.toml`, `setup.py`, `setup.cfg`, `requirements.txt` | `Pipfile.lock`, `poetry.lock`, `uv.lock` | `main.py`, `app.py`, `__main__.py`, `manage.py` |
| **Go** | `go.mod` | `go.sum` | `main.go`, `cmd/*/main.go` |
| **Rust** | `Cargo.toml` | `Cargo.lock` | `src/main.rs`, `src/lib.rs` |
| **Java (Maven)** | `pom.xml` | — | `src/main/java/**/Application.java`, `src/main/java/**/Main.java` |
| **Java (Gradle)** | `build.gradle`, `build.gradle.kts` | `gradle.lockfile` | `src/main/java/**/Application.java`, `src/main/java/**/Main.java` |
| **Kotlin** | `build.gradle.kts` | `gradle.lockfile` | `src/main/kotlin/**/Application.kt`, `src/main/kotlin/**/Main.kt` |
| **.NET / C#** | `*.csproj`, `*.sln` | `packages.lock.json` | `Program.cs`, `Startup.cs` |
| **Ruby** | `Gemfile` | `Gemfile.lock` | `config.ru`, `bin/rails`, `app.rb` |
| **PHP** | `composer.json` | `composer.lock` | `public/index.php`, `index.php`, `artisan` |
| **Swift** | `Package.swift` | `Package.resolved` | `Sources/*/main.swift` |
| **Elixir** | `mix.exs` | `mix.lock` | `lib/*/application.ex` |

### Package Manager Detection

<!-- 按生态系统检测包管理器。 -->

| Ecosystem | Package Manager | Detection |
|---|---|---|
| Node.js | npm | `package-lock.json` present |
| Node.js | Yarn (Classic) | `yarn.lock` present, no `.yarnrc.yml` |
| Node.js | Yarn (Berry) | `yarn.lock` + `.yarnrc.yml` present |
| Node.js | pnpm | `pnpm-lock.yaml` present |
| Node.js | Bun | `bun.lockb` present |
| Python | pip | `requirements.txt` present, no other manager |
| Python | Pipenv | `Pipfile` present |
| Python | Poetry | `pyproject.toml` with `[tool.poetry]` section |
| Python | uv | `uv.lock` present, or `pyproject.toml` with `[tool.uv]` |
| Python | conda | `environment.yml` or `conda.yaml` present |
| Ruby | Bundler | `Gemfile` present |
| PHP | Composer | `composer.json` present |
| Rust | Cargo | `Cargo.toml` present |
| Go | Go Modules | `go.mod` present |
| Java | Maven | `pom.xml` present |
| Java | Gradle | `build.gradle` or `build.gradle.kts` present |
| .NET | NuGet | `*.csproj` with `<PackageReference>` |

### Build Tool Detection

<!-- 检测构建工具。 -->

| Build Tool | Detection File(s) |
|---|---|
| Webpack | `webpack.config.*` |
| Vite | `vite.config.*` |
| Rollup | `rollup.config.*` |
| esbuild | `esbuild` in `package.json` scripts or dependencies |
| SWC | `.swcrc` or `swc` in dependencies |
| Turbopack | `turbo.json` |
| Parcel | `.parcelrc` |
| tsc (TypeScript) | `tsconfig.json` |
| Babel | `babel.config.*`, `.babelrc` |
| Make | `Makefile` |
| CMake | `CMakeLists.txt` |
| Meson | `meson.build` |
| Bazel | `BUILD`, `WORKSPACE` |
| Gradle | `build.gradle`, `build.gradle.kts` |
| Maven | `pom.xml` |
| MSBuild | `*.csproj`, `*.sln` |

### Test Framework Detection

<!-- 检测测试框架。 -->

| Test Framework | Detection |
|---|---|
| Jest | `jest.config.*`, or `jest` in package.json devDependencies |
| Vitest | `vitest.config.*`, or `vitest` in package.json devDependencies |
| Mocha | `.mocharc.*`, or `mocha` in package.json devDependencies |
| Jasmine | `jasmine.json`, or `jasmine` in devDependencies |
| AVA | `ava` in package.json, or `.ava.config.*` |
| Playwright | `playwright.config.*` |
| Cypress | `cypress.config.*`, `cypress/` directory |
| Pytest | `pytest.ini`, `conftest.py`, `[tool.pytest]` in pyproject.toml |
| unittest | `test_*.py` files with `import unittest` |
| Go test | `*_test.go` files |
| Rust test | `#[cfg(test)]` in source, `tests/` directory |
| RSpec | `.rspec`, `spec/` directory |
| Minitest | `test/` directory with `require "minitest"` |
| JUnit | `src/test/java/`, JUnit imports in test files |
| xUnit | `*.Tests.csproj`, xUnit imports |
| NUnit | NUnit imports in test projects |
| PHPUnit | `phpunit.xml`, `phpunit.xml.dist` |

### Linter / Formatter Detection

<!-- 检测代码质量工具。 -->

| Tool | Detection |
|---|---|
| ESLint | `.eslintrc.*`, `eslint.config.*` |
| Prettier | `.prettierrc.*`, `prettier.config.*` |
| Biome | `biome.json` |
| StandardJS | `standard` in package.json |
| Stylelint | `.stylelintrc.*` |
| Pylint | `.pylintrc`, `pylintrc` |
| Flake8 | `.flake8`, `setup.cfg [flake8]` |
| Black | `[tool.black]` in pyproject.toml |
| Ruff | `ruff.toml`, `[tool.ruff]` in pyproject.toml |
| isort | `[tool.isort]` in pyproject.toml |
| mypy | `mypy.ini`, `[tool.mypy]` in pyproject.toml |
| golangci-lint | `.golangci.yml`, `.golangci.yaml` |
| Clippy | Rust — `cargo clippy` in CI config |
| RuboCop | `.rubocop.yml` |
| PHP_CodeSniffer | `phpcs.xml`, `.phpcs.xml` |
| PHP-CS-Fixer | `.php-cs-fixer.php`, `.php-cs-fixer.dist.php` |

---

## Framework Detection Heuristics（框架检测启发式）

### Dependency-Based Detection

<!-- 通过 manifest 文件中的依赖名检测框架。 -->

Scan the manifest file's `dependencies` / `devDependencies` (or equivalent) for these framework identifiers:

#### Frontend Frameworks

| Framework | Dependency Name(s) | Additional Signals |
|---|---|---|
| React | `react`, `react-dom` | `jsx`/`tsx` files |
| Next.js | `next` | `next.config.*`, `pages/` or `app/` directory |
| Vue.js | `vue` | `.vue` files |
| Nuxt | `nuxt` | `nuxt.config.*` |
| Angular | `@angular/core` | `angular.json`, `src/app/` |
| Svelte | `svelte` | `.svelte` files |
| SvelteKit | `@sveltejs/kit` | `svelte.config.js` |
| Solid.js | `solid-js` | — |
| Astro | `astro` | `astro.config.*` |
| Remix | `@remix-run/react` | `remix.config.*` |
| Gatsby | `gatsby` | `gatsby-config.*` |

#### Backend Frameworks

| Framework | Dependency Name(s) | Additional Signals |
|---|---|---|
| Express | `express` | `app.use(`, `app.get(` patterns |
| Fastify | `fastify` | — |
| Koa | `koa` | — |
| NestJS | `@nestjs/core` | `nest-cli.json` |
| Hono | `hono` | — |
| Django | `django` | `manage.py`, `settings.py`, `urls.py` |
| Flask | `flask` | `app = Flask(` pattern |
| FastAPI | `fastapi` | `app = FastAPI(` pattern |
| Spring Boot | `spring-boot-starter` | `@SpringBootApplication` annotation |
| Rails | `rails` | `config.ru`, `Rakefile`, `config/routes.rb` |
| Laravel | `laravel/framework` | `artisan`, `routes/web.php` |
| Gin | `github.com/gin-gonic/gin` (in go.mod) | — |
| Echo | `github.com/labstack/echo` (in go.mod) | — |
| Fiber | `github.com/gofiber/fiber` (in go.mod) | — |
| Actix | `actix-web` (in Cargo.toml) | — |
| Axum | `axum` (in Cargo.toml) | — |
| ASP.NET Core | `Microsoft.AspNetCore.*` | `Program.cs` with `WebApplication.CreateBuilder` |
| Phoenix | `phoenix` (in mix.exs) | — |

#### Mobile Frameworks

| Framework | Detection |
|---|---|
| React Native | `react-native` in dependencies |
| Flutter | `pubspec.yaml` with `flutter` SDK |
| Expo | `expo` in dependencies |
| SwiftUI | `.swift` files with `import SwiftUI` |
| Kotlin Android | `build.gradle.kts` with `com.android.application` plugin |

### Directory-Structure-Based Detection

<!-- 通过目录结构特征检测框架。 -->

| Directory Pattern | Inferred Framework |
|---|---|
| `pages/` + `next.config.*` | Next.js (Pages Router) |
| `app/` + `next.config.*` + `layout.tsx` | Next.js (App Router) |
| `src/app/` + `angular.json` | Angular |
| `routes/` + `svelte.config.*` | SvelteKit |
| `src/routes/` + `+page.svelte` | SvelteKit |
| `pages/` + `nuxt.config.*` | Nuxt |
| `src/` + `gatsby-config.*` | Gatsby |

---

## Project Scale Classification（项目规模分级）

<!-- 根据文件数和行数对项目进行规模分级，并匹配分析策略。 -->

| Scale | File Count | Line Count | Analysis Strategy |
|---|---|---|---|
| **Small** | < 50 | < 5,000 | Full scan — read every source file |
| **Medium** | 50 – 200 | 5,000 – 50,000 | Tiered scan — Grep all, Read top 40, Deep analyze top 15 |
| **Large** | 200 – 1,000 | 50,000 – 200,000 | Sampling + Grep — Grep all, Read entry points + hot files only |
| **Very Large** | > 1,000 | > 200,000 | Grep-only + entry points — no bulk file reading |

### Strategy Details

#### Small Projects (< 50 files)
- Read all source files (skip binary, generated, and dependency files)
- Full dependency graph construction
- Comprehensive architecture analysis
- No sampling needed

#### Medium Projects (50-200 files)
- Tier 1: Grep all source files for patterns
- Tier 2: Read the top 40 files by relevance (entry points, highest import count, Tier 1 hit density)
- Tier 3: Deep analysis of top 15 files (cross-file data flow, dependency chain tracing)

#### Large Projects (200-1000 files)
- Grep scan all source files
- Read only: entry points, manifest files, key configuration
- Read files flagged by Grep (high hit density)
- Rely on directory structure analysis for architecture inference
- Skip deep cross-file analysis — too many files

#### Very Large Projects (> 1000 files)
- Grep-only scan (no bulk file reading)
- Read only entry points and manifest files
- Architecture inferred purely from directory structure + manifest
- Dependency health via audit tools only (no manual cross-referencing)
- Warn user: "Project is very large. Analysis will be high-level. Consider scoping to specific modules."

---

## Directory Exclusion List（目录排除列表）

<!-- 在扫描和统计时排除这些目录。 -->

The following directories MUST be excluded from all scans, file counting, and line counting:

### Universal Exclusions

```
node_modules/
vendor/
.git/
dist/
build/
__pycache__/
.tox/
target/
bin/obj/
.next/
.nuxt/
coverage/
.idea/
.vscode/
```

### Ecosystem-Specific Exclusions

| Ecosystem | Additional Exclusions |
|---|---|
| Node.js | `.cache/`, `.parcel-cache/`, `.turbo/`, `.vercel/`, `.output/` |
| Python | `*.egg-info/`, `.eggs/`, `.mypy_cache/`, `.pytest_cache/`, `venv/`, `.venv/`, `env/` |
| Go | — (Go vendor is covered by `vendor/`) |
| Rust | `target/` (already in universal) |
| Java | `.gradle/`, `.m2/`, `out/` |
| .NET | `bin/`, `obj/`, `packages/` (NuGet local) |
| Ruby | `.bundle/` |
| PHP | — (covered by `vendor/`) |

### Generated File Exclusions

Also exclude files that are clearly generated:

- `*.min.js`, `*.min.css` — Minified files
- `*.map` — Source maps
- `*.d.ts` in `node_modules/` — Type declarations from packages
- `*.pb.go`, `*.pb.ts` — Protocol buffer generated code
- `*.generated.*` — Explicitly marked as generated
- Files with `// Code generated` or `# This file is generated` in first 5 lines

---

## Multi-Ecosystem Projects（多生态系统项目）

<!-- 当检测到多个生态系统时的处理规则。 -->

When multiple ecosystem manifests are detected in the same project:

1. **Monorepo Detection**: If `packages/`, `apps/`, or workspace config is present → treat as monorepo
   - Scan each workspace/package independently
   - Report tech stack per workspace
2. **Polyglot Project**: If different manifests are at the same level → treat as polyglot
   - Report all detected ecosystems
   - Primary ecosystem = the one with most source files
3. **Frontend + Backend**: Common pattern (e.g., `package.json` + `go.mod`)
   - Detect if there's a `frontend/` or `client/` directory → split analysis
   - Report frontend and backend stacks separately
