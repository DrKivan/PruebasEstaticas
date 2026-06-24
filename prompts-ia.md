# Evidencia de Uso de IA Generativa

## Prompt 1: Generación del Checklist IEEE 1028

**Prompt enviado:**

```
Actúa como auditor de sistemas y experto en IEEE 1028.
Necesito un checklist de pruebas estáticas para auditar una aplicación C#.
El checklist debe evaluar:
- estándares de codificación
- seguridad básica
- mantenibilidad
- documentación
- buenas prácticas C#
- buenas prácticas DevOps

Cada sección debe tener al menos 5 ítems con ID único, descripción clara y espacio para evidencia.
El formato debe ser Markdown para incluirlo en un repositorio de auditoría.
Basado en IEEE 1028-2008 (Software Reviews and Audits).
```

**Respuesta de la IA:**

```
# Checklist de Auditoría Estática — IEEE 1028

## 1. Estándares de Código
| ID | Ítem |
|----|------|
| C01 | El código sigue convención de nomenclatura consistente (PascalCase, camelCase) |
| C02 | Los nombres de identificadores son descriptivos |
| C03 | No existen líneas comentadas sin justificación |
| C04 | El .csproj define AnalysisLevel y TreatWarningsAsErrors |
| C05 | No hay más de una clase por archivo |
| C06 | La indentación es uniforme |
| C07 | No hay bloques duplicados |
| C08 | No hay variables no utilizadas |

## 2. Seguridad Básica
| ID | Ítem |
|----|------|
| S01 | No se usa int.Parse() sin validación |
| S02 | Entradas de usuario validadas |
| S03 | Existe manejo de excepciones try-catch |
| S04 | No se exponen datos sensibles |
| S05 | Credenciales no hardcodeadas |
| S06 | Comparación de strings con OrdinalIgnoreCase |
| S07 | Sin inyección de código |

## 3. Mantenibilidad
| ID | Ítem |
|----|------|
| M01 | Código modularizado, responsabilidad única |
| M02 | Lógica separada de presentación |
| M03 | Sin números mágicos |
| M04 | Baja complejidad ciclomática |
| M05 | Pruebas unitarias existentes |
| M06 | Dependencias inyectadas |
| M07 | Sin acoplamientos innecesarios |

## 4. Documentación
| ID | Ítem |
|----|------|
| D01 | Comentarios XML en miembros públicos |
| D02 | README con instrucciones |
| D03 | Decisiones técnicas documentadas |
| D04 | Documentación de ejecución/despliegue |
| D05 | Código explica el por qué |

## 5. Buenas Prácticas C#
| ID | Ítem |
|----|------|
| B01 | Uso correcto de var |
| B02 | Métodos async con sufijo Async |
| B03 | Uso de nameof() |
| B04 | Interfaces en lugar de tipos concretos |
| B05 | Sin #region |
| B06 | Preferir LINQ sobre loops |
| B07 | Uso de IsNullOrWhiteSpace |

## 6. Cumplimiento DevOps
| ID | Ítem |
|----|------|
| V01 | Compilación sin errores ni advertencias |
| V02 | Pipeline CI/CD configurado |
| V03 | Análisis estático automático en pipeline |
| V04 | Pipeline frena merge si falla |
| V05 | Reporte automático generado |
| V06 | Sin secretos en repositorio |
| V07 | Pipeline incluye restore, build y análisis |
```

---

## Prompt 2: Conversión del Checklist a Reglas Automatizables

**Prompt enviado:**

```
Convierte el siguiente checklist de auditoría C# en reglas automatizables para un script PowerShell.
Para cada ítem, indica:
1. Cómo detectarlo automáticamente (regex, comando, herramienta)
2. Nivel de severidad (Crítico, Alto, Medio, Bajo)
3. Mensaje de salida estándar

Enfócate en reglas que se puedan ejecutar sin compilar (análisis estático sobre el código fuente).
Ítems a convertir:
- C01: Convención de nomenclatura
- C08: Variables no usadas
- S01: int.Parse sin validación
- S03: Falta try-catch
- S05: Credenciales hardcodeadas
- M01: Código no modularizado
- M03: Números mágicos
- M05: Falta de pruebas unitarias
- D01: Falta comentarios XML
- B05: Uso de #region
- V06: Secretos en repositorio
```

**Respuesta de la IA:**

```
| ID | Regla | Detección | Severidad |
|----|-------|-----------|-----------|
| C01 | PascalCase en clases | regex 'class\s+[a-z]' | Medio |
| C08 | Variables sin uso | Contar referencias vs declaración | Bajo |
| S01 | Parse sin TryParse | Buscar int.Parse sin try-catch | Alto |
| S03 | Falta try-catch | Entrada sin bloque try | Alto |
| S05 | Hardcode de credenciales | password|secret|token seguido de = " | Crítico |
| M01 | Solo método Main | Solo static void Main sin otros métodos | Medio |
| M03 | Números mágicos | Literales numéricos sin constante | Medio |
| M05 | Sin tests | No existe carpeta Tests/*Test* | Alto |
| D01 | Sin XML comments | public sin /// <summary> | Medio |
| B05 | #region | Buscar '#region' en el código | Bajo |
| V06 | Secretos en repo | password|connectionstring = " | Crítico |
```

---

## Prompt 3: Generación de Código para el Script de Auditoría

**Prompt enviado:**

```
Genera una función en PowerShell que implemente las siguientes reglas de auditoría estática
sobre archivos C#:

1. Buscar archivos .cs en una ruta dada
2. Detectar uso de int.Parse() sin try-catch (S01/S03)
3. Detectar credenciales hardcodeadas (S05)
4. Detectar números mágicos (M03)
5. Detectar falta de comentarios XML (D01)
6. Detectar falta de pruebas unitarias (M05)

La función debe devolver objetos con propiedades: Category, CheckId, Description, Status, Risk, Recommendation.
Usa Select-String y regex para las detecciones.
```

**Respuesta de la IA:**

```powershell
function Invoke-SecurityAudit {
    param([string]$SourcePath)
    $findings = @()
    $csFiles = Get-ChildItem $SourcePath -Filter *.cs -Recurse
    foreach ($file in $csFiles) {
        $content = Get-Content $file.FullName -Raw
        if ($content -match 'int\.Parse' -and $content -notmatch 'try\s*\{') {
            $findings += [PSCustomObject]@{
                Category = 'Seguridad'
                CheckId = 'S01'
                Description = "int.Parse sin try-catch en $($file.Name)"
                Status = 'FAIL'
                Risk = 'Alto'
                Recommendation = 'Usar TryParse + try-catch'
            }
        }
        if ($content -match '(password|secret|token)\s*[:=]\s*["\']') {
            $findings += [PSCustomObject]@{
                Category = 'Seguridad'
                CheckId = 'S05'
                Description = "Credencial hardcodeada en $($file.Name)"
                Status = 'FAIL'
                Risk = 'Crítico'
                Recommendation = 'Usar variables de entorno'
            }
        }
    }
    return $findings
}
```

---

## Prompt 4: Mejora del Script de Auditoría

**Prompt enviado:**

```
Tengo un script PowerShell de auditoría estática. ¿Qué mejorías sugieres para hacerlo más robusto?

1. ¿Cómo manejar errores cuando no existe la ruta?
2. ¿Cómo integrar la compilación de .NET en el script?
3. ¿Cómo generar un reporte en Markdown profesional?
4. ¿Cómo hacer que el script funcione como gate en CI/CD?

Mi script actual tiene funciones separadas por categoría pero no tiene manejo de errores ni reporte.
```

**Respuesta de la IA:**

```
1. Manejo de errores:
   - Validar Test-Path al inicio, exit 1 si no existe
   - try-catch en Invoke-DotNetBuild
   - $ErrorActionPreference = "Stop"

2. Integración compilación .NET:
   - Usar Push-Location al directorio del .csproj
   - Ejecutar dotnet restore y dotnet build
   - Capturar $LASTEXITCODE
   - Parsear output con Select-String para errores/advertencias

3. Reporte Markdown profesional:
   - Incluir metadatos: fecha, duración, fuente
   - Tabla de hallazgos con estado (✅ ❌ ⚠️)
   - Resumen por categoría con porcentajes
   - Sección de riesgos clasificados (Crítico/Alto/Medio/Bajo)
   - Recomendaciones prioritarias numeradas
   - Resultado final: APROBADO/RECHAZADO con umbral configurable

4. Gate CI/CD:
   - exit 0 si pasa, exit 1 si falla
   - Parámetro -MinimumPassRate (default 80%)
   - Generar reporte en artifact path
   - Compatible con GitHub Actions, Azure DevOps
```

---

## Prompt 5: Configuración de GitHub Actions

**Prompt enviado:**

```
Genera un archivo audit.yml para GitHub Actions que:
1. Se ejecute en push y pull_request
2. Use .NET 8.0
3. Ejecute el script audit-script.ps1 con PowerShell
4. Frene el merge si el script falla (exit code != 0)
5. Suba el reporte como artifact

La estructura del repo es:
/auditoria-estatica
  ├── audit-script.ps1
  ├── DemoAuditApp/Program.cs
  └── .github/workflows/audit.yml
```

**Respuesta de la IA:**

```yaml
name: Auditoria Estatica IEEE 1028
on: [push, pull_request]
jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup .NET
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: '8.0.x'
      - name: Run Static Audit
        run: |
          pwsh -File auditoria-estatica/audit-script.ps1 `
            -SourcePath auditoria-estatica/DemoAuditApp `
            -ReportPath auditoria-estatica/audit-results.md `
            -MinimumPassRate 80
      - name: Upload Audit Report
        uses: actions/upload-artifact@v4
        with:
          name: audit-report
          path: auditoria-estatica/audit-results.md
      - name: Fail if audit failed
        if: failure()
        run: exit 1
```

---

## Prompt 6: Análisis de Hallazgos y Recomendaciones

**Prompt enviado:**

```
Actúa como auditor de sistemas senior. He ejecutado una auditoría estática sobre
el siguiente código C# y tengo estos hallazgos:

Código auditado:
```csharp
using System;
namespace DemoAuditApp {
    class Program {
        static void Main(string[] args) {
            Console.WriteLine("Ingrese su edad:");
            int edad = int.Parse(Console.ReadLine());
            if (edad > 18)
                Console.WriteLine("Acceso permitido");
            else
                Console.WriteLine("Acceso denegado");
        }
    }
}
```

Hallazgos:
1. int.Parse sin validación (S01) - Riesgo Alto
2. Sin try-catch (S03) - Riesgo Alto
3. Sin documentación XML (D01) - Riesgo Medio
4. Sin pruebas unitarias (M05) - Riesgo Alto
5. Código no modularizado (M01) - Riesgo Medio
6. Número mágico 18 (M03) - Riesgo Medio

Genera un análisis de riesgos con:
- Impacto en producción
- Probabilidad de ocurrencia
- Recomendaciones por prioridad
- Visión sistémica (causa raíz)
```

**Respuesta de la IA:**

```
## Análisis de Riesgos

### 1. int.Parse sin validación (S01/S03)
- Impacto: Crítico - Si el usuario ingresa texto no numérico, la aplicación lanza FormatException y termina.
- Probabilidad: Alta - Ocurre en cada ejecución si el usuario comete un error de tipeo.
- Causa raíz: Falta de cultura de validación de entradas. No hay estándar de manejo de errores.

### 2. Sin pruebas unitarias (M05)
- Impacto: Alto - Cualquier cambio puede romper la funcionalidad sin detección temprana.
- Probabilidad: Alta - Sin tests, no hay red de seguridad.
- Causa raíz: No hay requisito de calidad en el pipeline DevOps.

### 3. Sin documentación (D01)
- Impacto: Medio - Dificulta el onboarding y mantenimiento.
- Probabilidad: Media - Código pequeño pero escala mal.
- Causa raíz: No hay estándar de documentación en el equipo.

### 4. Número mágico 18 (M03)
- Impacto: Bajo - No crítico ahora, pero si la edad legal cambia hay que buscarlo manualmente.
- Probabilidad: Baja - Cambios regulatorios poco frecuentes.
- Causa raíz: Falta de uso de constantes con nombre significativo.

### Recomendaciones por Prioridad
1. Urgente: Reemplazar int.Parse con int.TryParse + try-catch
2. Alta: Agregar proyecto de tests unitarios
3. Media: Agregar documentación XML y README
4. Media: Extraer constantes (const int EDAD_MINIMA = 18)
5. Baja: Modularizar lógica en métodos

### Visión Sistémica
La causa raíz de todos los hallazgos es la ausencia de un estándar de calidad
definido y automatizado en el ciclo de vida del desarrollo. Sin gate de calidad
en CI/CD, los defectos pasan a producción. La solución no es técnica sino de
proceso: definir un Definition of Done que incluya validación, tests y
documentación, y automatizarlo con el pipeline de auditoría.
```

---

**Nota:** Los prompts y respuestas aquí documentados representan la interacción real con el modelo de IA generativa utilizado como apoyo para la elaboración de los entregables de esta actividad. Los resultados fueron revisados, adaptados y mejorados por el equipo de auditoría.
