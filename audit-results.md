# Reporte de Auditoria Estatica

**Fecha:** 2026-06-24 12:51:04
**Duracion:** 2.7342004 segundos
**Fuente auditada:** .\DemoAuditApp
**Checks totales:** 6 | **Aprobados:** 0 | **Fallidos:** 6 | **Tasa:** 0%
**Umbral minimo:** 80%
**Resultado:** RECHAZADO

---

## Hallazgos Detallados

| Categoria | ID | Descripcion | Estado | Riesgo | Recomendacion |
|-----------|----|-------------|--------|-------|---------------|
| Estandares de Codigo | C01 | Clase no usa PascalCase en Program.cs | NO FAIL | Medio | Renombrar clase con PascalCase |
| Seguridad Basica | S01 | Uso de Parse sin validacion ni TryParse en Program.cs | NO FAIL | Alto | Usar TryParse con validacion y try-catch |
| Seguridad Basica | S03 | Entrada de usuario sin bloque try-catch en Program.cs | NO FAIL | Alto | Envolver en bloque try-catch y validar entradas |
| Mantenibilidad | M05 | No se encontraron proyectos o archivos de prueba unitaria | NO FAIL | Alto | Agregar proyecto de tests (xUnit/NUnit/MSTest) con cobertura minima |
| Documentacion | D04 | No se encontro archivo README en el proyecto | AV WARN | Bajo | Crear README.md con instrucciones de uso, compilacion y despliegue |
| Cumplimiento DevOps | V01 | La compilacion fallo con errores o advertencias tratadas como errores | NO FAIL | Alto | Corregir errores de compilacion. Revisar AnalysisLevel y TreatWarningsAsErrors |

---

## Resumen por Categoria

| Categoria | Total | Aprobados | Fallidos | % Cumplimiento |
|-----------|-------|-----------|----------|----------------|
| Estandares de Codigo | 1 | 0 | 1 | 0% |
| Seguridad Basica | 2 | 0 | 2 | 0% |
| Mantenibilidad | 1 | 0 | 1 | 0% |
| Documentacion | 1 | 0 | 1 | 0% |
| Cumplimiento DevOps | 1 | 0 | 1 | 0% |

## Riesgos Identificados

### Altos
- **Seguridad Basica / S01:** Uso de Parse sin validacion ni TryParse en Program.cs
- **Seguridad Basica / S03:** Entrada de usuario sin bloque try-catch en Program.cs
- **Mantenibilidad / M05:** No se encontraron proyectos o archivos de prueba unitaria
- **Cumplimiento DevOps / V01:** La compilacion fallo con errores o advertencias tratadas como errores


## Recomendaciones Prioritarias

1. Reemplazar int.Parse con int.TryParse y agregar try-catch.
2. Toda interaccion con el usuario debe estar en bloques try-catch.
3. Extraer logica de negocio fuera de Main() en metodos con responsabilidad unica.
4. Agregar proyecto de tests con cobertura minima del 70%.
5. Agregar comentarios XML y README.md.
6. Reemplazar numeros magicos con constantes nombradas.
7. Mantener el pipeline de auditoria como gate de calidad.

---
*Reporte generado automaticamente por audit-script.ps1 | Basado en IEEE 1028*
