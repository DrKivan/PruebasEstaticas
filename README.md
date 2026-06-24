# Auditoría Estática IEEE 1028

Mecanismo de auditoría automática basada en técnicas estáticas de prueba (IEEE 1028) integrado a CI/CD.

## Estructura

| Archivo | Descripción |
|---------|-------------|
| `checklist.md` | Checklist de auditoría IEEE 1028 (41 ítems) |
| `audit-script.ps1` | Script PowerShell de auditoría automatizada |
| `audit-report.md` | Reporte de auditoría con hallazgos y riesgos |
| `prompts-ia.md` | Evidencia de uso de IA generativa |
| `DemoAuditApp/` | Proyecto C# de ejemplo con defectos intencionales |
| `.github/workflows/audit.yml` | Pipeline CI/CD (GitHub Actions) |

## Requisitos

- .NET SDK 8.0
- PowerShell 5.1+

## Uso

```powershell
# Ejecutar auditoría local
./audit-script.ps1 -SourcePath "./DemoAuditApp" -ReportPath "./audit-results.md"
```

El pipeline `audit.yml` se ejecuta automáticamente en cada `push` y `pull_request` a `main`.
