# Checklist de Auditoría Estática — IEEE 1028

**Proyecto:** DemoAuditApp  
**Estándar de Referencia:** IEEE 1028-2008 (Software Reviews and Audits)  
**Tipo:** Revisión Técnica Formal (FTR) / Auditoría de Código  
**Auditoría Versión:** 1.0  
**Fecha:** Junio 2026

---

## Instrucciones

Marcar con ✅ si cumple, ❌ si no cumple, o N/A si no aplica.
Cada ítem debe tener una evidencia o comentario asociado.

---

## 1. Estándares de Código

| ID  | Ítem                                                                 | Cumple | Evidencia |
|-----|----------------------------------------------------------------------|--------|-----------|
| C01 | El código sigue una convención de nomenclatura consistente (PascalCase para clases/métodos, camelCase para variables locales) | ✅ | `class Program` usa PascalCase correcto. `Main`, `args`, `edad` siguen convención .NET |
| C02 | Los nombres de identificadores son descriptivos y significativos      | ✅ | `Program`, `Main`, `edad` son nombres claros y autodescriptivos |
| C03 | No existen líneas de código comentadas sin justificación              | ✅ | No hay bloques de código comentados en el source |
| C04 | El archivo de proyecto (.csproj) define `AnalysisLevel` y `TreatWarningsAsErrors` | ✅ | `.csproj` incluye `<AnalysisLevel>latest</AnalysisLevel>` y `<TreatWarningsAsErrors>true</TreatWarningsAsErrors>` |
| C05 | No hay más de un `class` por archivo (excepto clases anidadas pequeñas) | ✅ | Solo existe `class Program` en `Program.cs` |
| C06 | La indentación y el espaciado son uniformes                           | ✅ | Indentación consistente con 4 espacios |
| C07 | No hay bloques de código duplicados                                   | ✅ | Sin código duplicado en el proyecto |
| C08 | Las variables no utilizadas o asignaciones muertas están ausentes      | ✅ | Todas las variables declaradas son utilizadas |

---

## 2. Seguridad Básica

| ID  | Ítem                                                                 | Cumple | Evidencia |
|-----|----------------------------------------------------------------------|--------|-----------|
| S01 | No se utilizan métodos inseguros como `int.Parse()` sin validación previa | ❌ | Línea 10: `int edad = int.Parse(Console.ReadLine());` sin validación ni TryParse |
| S02 | Todas las entradas de usuario son validadas (tipo, rango, longitud)    | ❌ | No hay validación de tipo (podría lanzar FormatException) ni de rango (edad negativa) |
| S03 | Existe manejo de excepciones con `try-catch`                         | ❌ | No hay bloque try-catch en Main a pesar de usar Console.ReadLine() y int.Parse() |
| S04 | No se exponen datos sensibles en mensajes de consola o logs           | ✅ | Solo se imprime "Ingrese su edad:" y estado de acceso |
| S05 | Las contraseñas o credenciales no están hardcodeadas en el código     | ✅ | No hay contraseñas, tokens ni API keys en el código |
| S06 | Se usa `StringComparison.OrdinalIgnoreCase` para comparaciones de strings | N/A | No hay comparaciones de strings en el código |
| S07 | No hay inyección de código o concatenación de strings sin sanear      | ✅ | No se construyen consultas ni comandos dinámicamente |

---

## 3. Mantenibilidad

| ID  | Ítem                                                                 | Cumple | Evidencia |
|-----|----------------------------------------------------------------------|--------|-----------|
| M01 | El código está modularizado en métodos/funciones con responsabilidad única | ❌ | Toda la lógica está en `Main()`. No hay métodos auxiliares separados |
| M02 | La lógica de negocio está separada de la lógica de presentación/I/O   | ❌ | La validación de edad está mezclada con Console.ReadLine/WriteLine |
| M03 | No existen números mágicos (literales sin constante nombrada)         | ❌ | `18` es un número mágico: `if (edad > 18)` debería ser `if (edad >= EdadMinima)` |
| M04 | Las clases tienen baja complejidad ciclomática (menos de 10 por método) | ✅ | `Main()` tiene complejidad ciclomática de 2 (un if-else), bien |
| M05 | Existen pruebas unitarias que cubren al menos los casos críticos      | ❌ | No existe proyecto de tests ni archivos de prueba en la solución |
| M06 | Las dependencias están inyectadas y no instanciadas directamente      | N/A | No hay dependencias externas que inyectar |
| M07 | El código no contiene acoplamientos innecesarios                      | ✅ | Sin acoplamientos, código autocontenido |

---

## 4. Documentación

| ID  | Ítem                                                                 | Cumple | Evidencia |
|-----|----------------------------------------------------------------------|--------|-----------|
| D01 | Las clases y métodos públicos tienen comentarios XML (`///`)          | ❌ | No hay ningún comentario XML en `class Program` ni en `Main()` |
| D02 | Existe un README o documentación de inicio del proyecto               | ❌ | No existe archivo README.md en la raíz del proyecto |
| D03 | Las decisiones técnicas complejas están documentadas inline           | N/A | No hay decisiones técnicas complejas que documentar |
| D04 | Existe documentación sobre cómo ejecutar y desplegar la aplicación    | ❌ | No hay instrucciones de compilación, ejecución ni despliegue |
| D05 | El código explica el "por qué", no solo el "qué"                      | ❌ | El código solo dice qué hace (Console.WriteLine), no por qué |

---

## 5. Buenas Prácticas C#

| ID  | Ítem                                                                 | Cumple | Evidencia |
|-----|----------------------------------------------------------------------|--------|-----------|
| B01 | Se usa `var` solo cuando el tipo es evidente (IDE0007 / IDE0008)      | ✅ | No se usa `var` en el código, lo cual es aceptable para este tamaño |
| B02 | Los métodos asíncronos están nombrados con sufijo `Async`             | N/A | No hay métodos asíncronos en el proyecto |
| B03 | Se usa `nameof()` en lugar de string literals para nombres de miembros | N/A | No se referencian nombres de miembros como strings |
| B04 | Las colecciones se declaran usando interfaces (`IEnumerable<T>`, `IList<T>`) en lugar de tipos concretos | N/A | No hay colecciones declaradas en el código |
| B05 | No se usan regiones (`#region`) para organizar código extenso         | ✅ | No hay `#region` en el código |
| B06 | Las expresiones LINQ se prefieren sobre buques imperativos cuando es legible | N/A | No hay operaciones de iteración en el código |
| B07 | Se usa `string.IsNullOrWhiteSpace()` en lugar de comparación manual   | N/A | No hay comparaciones de strings en el código |

---

## 6. Cumplimiento DevOps

| ID  | Ítem                                                                 | Cumple | Evidencia |
|-----|----------------------------------------------------------------------|--------|-----------|
| V01 | El proyecto compila sin errores ni advertencias                       | ❌ | Error CS8604: posible argumento nulo en `int.Parse(Console.ReadLine())` con TreatWarningsAsErrors |
| V02 | Existe un pipeline CI/CD configurado (GitHub Actions, Azure DevOps, etc.) | ✅ | Archivo `.github/workflows/audit.yml` configurado con push y pull_request |
| V03 | El pipeline ejecuta análisis estático automático                      | ✅ | El pipeline ejecuta `audit-script.ps1` + `dotnet build` con analyzers |
| V04 | El pipeline frena el merge si la auditoría falla                      | ✅ | `if: failure()` ejecuta `exit 1` bloqueando el merge |
| V05 | Se genera un reporte automático por cada ejecución                    | ✅ | `actions/upload-artifact@v4` sube `audit-results.md` como artifact |
| V06 | Las credenciales y secretos no están en el repositorio                | ✅ | No hay secrets, tokens ni connection strings en el código |
| V07 | El pipeline incluye restauración, compilación y análisis              | ✅ | Pipeline ejecuta `dotnet restore`, `dotnet build` y el script de auditoría |

---

## Resumen

| Categoría                     | Total Ítems | Aprobados | % Cumplimiento |
|-------------------------------|-------------|-----------|----------------|
| Estándares de Código          | 8           | 8         | 100%           |
| Seguridad Básica              | 7           | 3         | 42.9%          |
| Mantenibilidad                | 7           | 3         | 42.9%          |
| Documentación                 | 5           | 0         | 0%             |
| Buenas Prácticas C#           | 7           | 2         | 100% (*)       |
| Cumplimiento DevOps           | 7           | 6         | 85.7%          |
| **Total**                     | **41**      | **22**    | **53.7%**      |

> (*) 5 ítems marcados como N/A por no aplicar al proyecto; se consideran aprobados al no haber infracción.

---

*Documento generado bajo el marco de IEEE 1028-2008. Este checklist es auditable y trazable.*
