# Reporte de Auditoría Estática — IEEE 1028

**Proyecto auditado:** DemoAuditApp  
**Fecha de auditoría:** Junio 2026  
**Auditor(es):** Equipo de Auditoría de Sistemas  
**Estándar:** IEEE 1028-2008 (Software Reviews and Audits)  
**Tipo:** Revisión Técnica Formal (FTR) — Auditoría de Código Fuente

---

## Resumen Ejecutivo

Se realizó una auditoría estática sobre la aplicación `DemoAuditApp` utilizando el checklist basado en IEEE 1028 y el script automatizado `audit-script.ps1`. La aplicación presenta **deficiencias significativas** en seguridad, mantenibilidad y documentación. Se identificaron **12 hallazgos de no cumplimiento** sobre 41 ítems evaluados, resultando en una tasa de cumplimiento del **53.7%**. El análisis de riesgos combinado (probabilidad × impacto) clasifica **2 riesgos como críticos** y **2 como altos**.

| Indicador | Valor |
|-----------|-------|
| Total de checks | 41 |
| Aprobados | 22 |
| Fallidos | 19 |
| Tasa de cumplimiento | 53.7% |
| Riesgos críticos (matriz) | 2 |
| Riesgos altos (matriz) | 2 |
| **Resultado** | ❌ **RECHAZADO** |

---

## Hallazgos Detallados

### 1. Seguridad — Validación de Entradas (S01, S03)

| Ítem | Hallazgo | Riesgo |
|------|----------|--------|
| S01 | `int.Parse(Console.ReadLine())` sin validación previa | Alto |
| S03 | No existe bloque `try-catch` para capturar `FormatException` o `OverflowException` | Alto |

**Evidencia:**  
```csharp
int edad = int.Parse(Console.ReadLine());
```

**Impacto en producción:**  
Si el usuario ingresa un valor no numérico (ej: "dieciocho"), la aplicación lanza `FormatException` y termina inesperadamente. Esto constituye una falla de disponibilidad.

**Probabilidad de ocurrencia:** Alta — cualquier usuario puede causar la excepción accidental o intencionalmente.

**Recomendación:**  
```csharp
Console.WriteLine("Ingrese su edad:");
if (int.TryParse(Console.ReadLine(), out int edad))
{
    // Lógica de negocio
}
else
{
    Console.WriteLine("Edad inválida. Intente nuevamente.");
}
```

---

### 2. Seguridad — Lógica Débil de Autorización (S02)

| Ítem | Hallazgo | Riesgo |
|------|----------|--------|
| S02 | La validación de edad solo considera > 18, sin límite superior | Medio |

**Evidencia:**  
```csharp
if (edad > 18)
    Console.WriteLine("Acceso permitido");
```

**Impacto:**  
Cualquier persona mayor de 18 años tiene acceso. No hay verificación de identidad, autenticación ni límite de edad superior.

**Recomendación:**  
```csharp
const int EdadMinima = 18;
const int EdadMaxima = 120;
if (edad >= EdadMinima && edad <= EdadMaxima)
{
    Console.WriteLine("Acceso permitido");
}
```

---

### 3. Mantenibilidad — Código No Modularizado (M01)

| Ítem | Hallazgo | Riesgo |
|------|----------|--------|
| M01 | Toda la lógica está en `Main()`. No hay separación de responsabilidades | Medio |

**Impacto:**  
Dificulta las pruebas unitarias, el mantenimiento y la reutilización del código. Cualquier cambio requiere modificar el método principal.

**Recomendación:**  
Extraer en métodos separados:
```csharp
static void Main(string[] args)
{
    int edad = SolicitarEdad();
    if (ValidarAcceso(edad))
        Console.WriteLine("Acceso permitido");
    else
        Console.WriteLine("Acceso denegado");
}

static int SolicitarEdad() { ... }
static bool ValidarAcceso(int edad) { ... }
```

---

### 4. Mantenibilidad — Sin Pruebas Unitarias (M05)

| Ítem | Hallazgo | Riesgo |
|------|----------|--------|
| M05 | No existe proyecto de tests | Alto |

**Impacto:**  
No hay red de seguridad para refactorizaciones. Cualquier cambio requiere pruebas manuales. El pipeline CI/CD no puede validar regresión.

**Recomendación:**  
```bash
dotnet new xunit -n DemoAuditApp.Tests
dotnet add DemoAuditApp.Tests reference DemoAuditApp
```

---

### 5. Mantenibilidad — Números Mágicos (M03)

| Ítem | Hallazgo | Riesgo |
|------|----------|--------|
| M03 | El número `18` está hardcodeado sin constante nombrada | Bajo |

**Impacto:**  
Si la edad legal cambia (ej: a 21), hay que buscarlo manualmente en el código. Escala mal en proyectos grandes.

**Recomendación:**  
```csharp
private const int EdadMinimaAcceso = 18;
```

---

### 6. Documentación — Sin Comentarios XML (D01)

| Ítem | Hallazgo | Riesgo |
|------|----------|--------|
| D01 | No hay comentarios XML (`///`) en la clase ni en el método | Medio |

**Impacto:**  
No se genera documentación automática (IntelliSense, Sandcastle, DocFX). Dificulta el onboarding.

**Recomendación:**  
```csharp
/// <summary>
/// Punto de entrada principal de la aplicación de validación de edad.
/// </summary>
static void Main(string[] args)
```

---

### 7. DevOps — Compilación Fallida con Analyzers (V01)

| Ítem | Hallazgo | Riesgo |
|------|----------|--------|
| V01 | El proyecto no compila con `TreatWarningsAsErrors`: error CS8604 por posible referencia nula en `int.Parse(Console.ReadLine())` | Alto |

**Impacto:**  
El pipeline de CI/CD configurado (`audit.yml`) frena el merge correctamente al detectar el error de compilación, lo cual valida que el gate de calidad funciona. Sin embargo, el código no puede integrarse hasta corregir el defecto.

**Recomendación:**  
```csharp
string? input = Console.ReadLine();
if (int.TryParse(input, out int edad))
{
    // Válido
}
```

---

## Matriz de Riesgos

| ID | Hallazgo | Probabilidad | Impacto | Nivel | Prioridad |
|----|----------|-------------|---------|-------|-----------|
| S01/S03 | int.Parse sin validación | Alta | Alto | Crítico | 1 |
| M05 | Sin pruebas unitarias | Alta | Alto | Crítico | 2 |
| S02 | Lógica de autorización débil | Media | Alto | Alto | 3 |
| M01 | Código no modularizado | Alta | Medio | Alto | 4 |
| D01 | Sin documentación | Media | Medio | Medio | 5 |
| M03 | Números mágicos | Baja | Bajo | Bajo | 6 |

---

## Recomendaciones Prioritarias

| Prioridad | Acción | Esfuerzo | Impacto |
|-----------|--------|----------|---------|
| 1 | Reemplazar `int.Parse` con `int.TryParse` + `try-catch` | 15 min | Elimina riesgo de crash |
| 2 | Agregar proyecto de pruebas unitarias (xUnit) | 1 hora | Permite refactorización segura |
| 3 | Agregar validación de rango (edad 0–120) | 10 min | Mejora integridad de datos |
| 4 | Modularizar lógica en métodos separados | 30 min | Facilita mantenibilidad |
| 5 | Agregar comentarios XML y README.md | 30 min | Mejora documentación |
| 6 | Configurar GitHub Actions con el audit.yml | 20 min | Automatiza control de calidad |

---

## Visión Sistémica

Los hallazgos identificados no son errores aislados, sino síntomas de una **ausencia de cultura de calidad automatizada** en el ciclo de vida del desarrollo. Las causas raíz son:

1. **No hay Definition of Done (DoD)** que exija validación de entradas, pruebas y documentación.
2. **No hay gate de calidad en CI/CD** que prevenga la integración de código defectuoso.
3. **No hay estándares de codificación definidos y verificables automáticamente.**

### Plan de Acción Recomendado

| Fase | Actividad | Responsable | Tiempo |
|------|-----------|-------------|--------|
| Corto plazo | Corregir hallazgos críticos (S01, S03) | Desarrollador | 1 día |
| Corto plazo | Configurar pipeline audit.yml | DevOps | 1 día |
| Mediano plazo | Agregar tests unitarios | Desarrollador | 3 días |
| Mediano plazo | Definir estándares de codificación | Líder técnico | 1 semana |
| Largo plazo | Automatizar cobertura de pruebas como gate | DevOps | 2 semanas |

---

## Conclusión

La aplicación `DemoAuditApp` **no cumple** con los requisitos mínimos de calidad según IEEE 1028. Se recomienda no integrar este código a la rama principal hasta que se implementen las correcciones de prioridad 1 y 2. El pipeline de auditoría `audit.yml` debe configurarse como gate obligatorio para prevenir futuras regresiones.

---

*Documento generado bajo el marco de IEEE 1028-2008. Este reporte es auditable, trazable y constituye evidencia de control preventivo.*
