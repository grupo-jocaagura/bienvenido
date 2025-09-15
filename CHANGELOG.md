# CHANGELOG Jocaagura Domain

This document follows the guidelines of [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.2] - 2025-09-14
- **CI/CD (GitHub Actions):**
  - `validate_commits_and_lints.yaml`: valida firmas de commits, formatea y analiza con Flutter, verifica `dependency_overrides` y usa caché de dependencias (excluye `develop`, `master` y `rev/**` en push).
  - `validate_pr.yaml` (PR → `develop`): exige actualización de `CHANGELOG.md`, ejecuta `format/analyze/test` y realiza *version bump* automático según etiquetas del PR (`major`, `minor`, `patch`) para PRs del mismo repo.
  - `validate_pr_master.yaml` (PR → `master`): ejecuta formato, análisis estricto, tests con cobertura, verifica ausencia de `dependency_overrides` y que la versión de `pubspec.yaml` sea mayor a la de `master`.
- **Happy roadmap verified**

## [0.0.1] – 2025-07-23

### Added
- 💼 **Proyecto inicial**
  - Scaffold de Flutter con nombre `bienvenido`
  - Organización: `com.jocaagura`
  - Plataformas habilitadas: Android, Web y Windows
  - Descripción del proyecto: “Un marketplace solidario”
- ⚙️ **Configuración de CI/CD**
  - Workflow para validación de Pull Requests: `.github/workflows/validate_pr.yaml`
  - Workflow para validación de la rama de producción (`master`): `.github/workflows/validate_pr_master.yaml`
- 📑 **Archivos de configuración**
  - Reglas de lint en `analysis_options.yaml`
  - Plantilla de `.gitignore` para Flutter, Android, iOS y artefactos comunes
- 📘 **Documentación inicial**
  - `README.md` con descripción del proyecto, tecnologías, flujo GitFlow y guía de contribución
  - Badges de CI y licencia MIT
- 📝 **Licencia**
  - Archivo `LICENSE` con Licencia MIT
