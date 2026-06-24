<#
.SYNOPSIS
    Script de Auditoria Estatica Automatizada basado en IEEE 1028.
.DESCRIPTION
    Evalua codigo C# contra checklist de estandares de codigo, seguridad,
    mantenibilidad, documentacion, buenas practicas C# y cumplimiento DevOps.
    Genera un reporte en Markdown con hallazgos, riesgos y recomendaciones.
.PARAMETER SourcePath
    Ruta al directorio del codigo fuente a auditar.
.PARAMETER ReportPath
    Ruta donde se guardara el reporte generado.
.PARAMETER MinimumPassRate
    Porcentaje minimo de checks aprobados (0-100).
.EXAMPLE
    .\audit-script.ps1 -SourcePath ".\DemoAuditApp" -ReportPath ".\audit-results.md"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,
    [Parameter(Mandatory = $false)]
    [string]$ReportPath = "audit-results.md",
    [Parameter(Mandatory = $false)]
    [int]$MinimumPassRate = 80
)

$ErrorActionPreference = "Stop"
$Global:PassCount = 0
$Global:FailCount = 0
$Global:Findings = @()
$Global:StartTime = Get-Date

function Write-AuditLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] [$Level] $Message"
}

function Add-Finding {
    param(
        [string]$Category, [string]$CheckId, [string]$Description,
        [string]$Status, [string]$Risk, [string]$Recommendation
    )
    $Global:Findings += [PSCustomObject]@{
        Category       = $Category
        CheckId        = $CheckId
        Description    = $Description
        Status         = $Status
        Risk           = $Risk
        Recommendation = $Recommendation
    }
    if ($Status -eq "PASS") { $Global:PassCount++ }
    else { $Global:FailCount++ }
}

# 1. ESTANDARES DE CODIGO
function Invoke-CodeStandardsAudit {
    Write-AuditLog "Auditando: Estandares de Codigo..."
    $csFiles = Get-ChildItem -Path $SourcePath -Filter "*.cs" -Recurse -ErrorAction SilentlyContinue

    if ($csFiles.Count -eq 0) {
        Add-Finding -Category "Estandares de Codigo" -CheckId "C00" `
            -Description "No se encontraron archivos .cs en la ruta: $SourcePath" `
            -Status "FAIL" -Risk "Critico" -Recommendation "Agregar archivos de codigo fuente C#"
        return
    }

    $reClassLower = 'class\s+[a-z]'
    $reCommented = '(?s)/\*.*?\*/'

    foreach ($file in $csFiles) {
        $content = Get-Content -Path $file.FullName -Raw

        if ($content -match $reClassLower) {
            Add-Finding -Category "Estandares de Codigo" -CheckId "C01" `
                -Description "Clase no usa PascalCase en $($file.Name)" `
                -Status "FAIL" -Risk "Medio" `
                -Recommendation "Renombrar clase con PascalCase"
        }

        if ($content -match '^\s*//' -and $content -match $reCommented) {
            Add-Finding -Category "Estandares de Codigo" -CheckId "C03" `
                -Description "Bloques de codigo comentados en $($file.Name)" `
                -Status "WARN" -Risk "Bajo" `
                -Recommendation "Eliminar codigo comentado si no es necesario"
        }
    }

    $reVarDecl = '\b(var|int|string|bool|double|float)\s+\w+\s*='
    $unusedVars = Get-ChildItem -Path $SourcePath -Filter "*.cs" -Recurse | Select-String -Pattern $reVarDecl | ForEach-Object {
        $line = $_.Line
        $m = [regex]::Match($line, '\b(var|int|string|bool|double|float)\s+(\w+)\s*=')
        if ($m.Success) {
            $varName = $m.Groups[2].Value
            $fileContent = Get-Content $_.Path -Raw
            $usageCount = ([regex]::Matches($fileContent, "\b$varName\b")).Count
            if ($usageCount -le 1) {
                return [PSCustomObject]@{ File = $_.Path; Variable = $varName }
            }
        }
    }
    if ($unusedVars) {
        foreach ($uv in $unusedVars) {
            Add-Finding -Category "Estandares de Codigo" -CheckId "C08" `
                -Description "Variable posiblemente no utilizada: $($uv.Variable) en $($uv.File)" `
                -Status "WARN" -Risk "Bajo" `
                -Recommendation "Eliminar variable no utilizada"
        }
    }
}

# 2. SEGURIDAD BASICA
function Invoke-SecurityAudit {
    Write-AuditLog "Auditando: Seguridad Basica..."
    $csFiles = Get-ChildItem -Path $SourcePath -Filter "*.cs" -Recurse

    $reParse = '(int\.Parse|Convert\.ToInt32|double\.Parse)'
    $reTryParse = '(int\.TryParse|double\.TryParse)'
    $reTryBlock = 'try\s*\{'
    $reInput = 'Console\.ReadLine|\.Parse\('
    $reCreds = '(password|secret|token|apikey|api_key)\s*[:=]\s*[""'']'

    foreach ($file in $csFiles) {
        $content = Get-Content -Path $file.FullName -Raw

        if ($content -match $reParse) {
            $hasTryBlock = $content -match $reTryBlock
            $hasTryParse = $content -match $reTryParse
            if (-not $hasTryBlock -or -not $hasTryParse) {
                Add-Finding -Category "Seguridad Basica" -CheckId "S01" `
                    -Description "Uso de Parse sin validacion ni TryParse en $($file.Name)" `
                    -Status "FAIL" -Risk "Alto" `
                    -Recommendation "Usar TryParse con validacion y try-catch"
            }
        }

        if ($content -match $reInput -and $content -notmatch $reTryBlock) {
            Add-Finding -Category "Seguridad Basica" -CheckId "S03" `
                -Description "Entrada de usuario sin bloque try-catch en $($file.Name)" `
                -Status "FAIL" -Risk "Alto" `
                -Recommendation "Envolver en bloque try-catch y validar entradas"
        }

        if ($content -match $reCreds) {
            Add-Finding -Category "Seguridad Basica" -CheckId "S05" `
                -Description "Posible credencial hardcodeada en $($file.Name)" `
                -Status "FAIL" -Risk "Critico" `
                -Recommendation "Usar variables de entorno o secretos administrados"
        }
    }
}

# 3. MANTENIBILIDAD
function Invoke-MaintainabilityAudit {
    Write-AuditLog "Auditando: Mantenibilidad..."
    $csFiles = Get-ChildItem -Path $SourcePath -Filter "*.cs" -Recurse

    $reMainOnly = 'static void Main'
    $reOtherMethod = '(?<!Main)\b\w+\s*\('

    foreach ($file in $csFiles) {
        $content = Get-Content -Path $file.FullName -Raw

        if ($content -match $reMainOnly -and $content -notmatch $reOtherMethod) {
            Add-Finding -Category "Mantenibilidad" -CheckId "M01" `
                -Description "Solo existe un metodo (Main) en $($file.Name). Codigo no modularizado." `
                -Status "WARN" -Risk "Medio" `
                -Recommendation "Extraer logica en metodos con responsabilidad unica"
        }

        $reMagic = '\b([3-9]\d*|[2-9]\d{2,})\b'
        $magicNumbers = Select-String -Path $file.FullName -Pattern $reMagic | Where-Object {
            $_.Line -notmatch '(const|readonly|enum|new|\[|//)' -and
            $_.Line -notmatch '\d+\s*[<>!=]=\s*\d+' -and
            $_.Line -notmatch 'WriteLine\("'
        }
        if ($magicNumbers) {
            Add-Finding -Category "Mantenibilidad" -CheckId "M03" `
                -Description "Posibles numeros magicos en $($file.Name)" `
                -Status "WARN" -Risk "Medio" `
                -Recommendation "Reemplazar literales numericos con constantes nombradas"
        }
    }

    $testFiles = Get-ChildItem -Path $SourcePath -Filter "*Test*" -Recurse -ErrorAction SilentlyContinue
    if (-not $testFiles -or $testFiles.Count -eq 0) {
        $testFiles = Get-ChildItem -Path $SourcePath -Filter "*Tests*" -Recurse -ErrorAction SilentlyContinue
    }
    if (-not $testFiles -or $testFiles.Count -eq 0) {
        Add-Finding -Category "Mantenibilidad" -CheckId "M05" `
            -Description "No se encontraron proyectos o archivos de prueba unitaria" `
            -Status "FAIL" -Risk "Alto" `
            -Recommendation "Agregar proyecto de tests (xUnit/NUnit/MSTest) con cobertura minima"
    }
}

# 4. DOCUMENTACION
function Invoke-DocumentationAudit {
    Write-AuditLog "Auditando: Documentacion..."
    $csFiles = Get-ChildItem -Path $SourcePath -Filter "*.cs" -Recurse

    $rePublic = 'public\s+(class|void|int|string|bool|double|Task)'
    $reXmlDoc = '/// <summary>'

    foreach ($file in $csFiles) {
        $content = Get-Content -Path $file.FullName -Raw

        if ($content -match $rePublic -and $content -notmatch $reXmlDoc) {
            Add-Finding -Category "Documentacion" -CheckId "D01" `
                -Description "Faltan comentarios XML (///) en miembros publicos en $($file.Name)" `
                -Status "FAIL" -Risk "Medio" `
                -Recommendation "Agregar documentacion XML a clases y metodos publicos"
        }
    }

    $readmeFiles = Get-ChildItem -Path $SourcePath -Filter "README*" -ErrorAction SilentlyContinue
    if (-not $readmeFiles) {
        $readmeFiles = Get-ChildItem -Path (Split-Path $SourcePath -Parent) -Filter "README*" -ErrorAction SilentlyContinue
    }
    if (-not $readmeFiles -or $readmeFiles.Count -eq 0) {
        Add-Finding -Category "Documentacion" -CheckId "D04" `
            -Description "No se encontro archivo README en el proyecto" `
            -Status "WARN" -Risk "Bajo" `
            -Recommendation "Crear README.md con instrucciones de uso, compilacion y despliegue"
    }
}

# 5. BUENAS PRACTICAS C#
function Invoke-CSharpBestPracticesAudit {
    Write-AuditLog "Auditando: Buenas Practicas C#..."
    $csFiles = Get-ChildItem -Path $SourcePath -Filter "*.cs" -Recurse
    $reRegion = '#region'

    foreach ($file in $csFiles) {
        $content = Get-Content -Path $file.FullName -Raw

        if ($content -match $reRegion) {
            Add-Finding -Category "Buenas Practicas C#" -CheckId "B05" `
                -Description "Se usan #region en $($file.Name). Considerado antipatron." `
                -Status "WARN" -Risk "Bajo" `
                -Recommendation "Eliminar #region y organizar en archivos parciales o clases separadas"
        }
    }
}

# 6. CUMPLIMIENTO DEVOPS
function Invoke-DevOpsAudit {
    Write-AuditLog "Auditando: Cumplimiento DevOps..."

    $csprojFiles = Get-ChildItem -Path $SourcePath -Filter "*.csproj" -Recurse
    if ($csprojFiles.Count -eq 0) {
        Add-Finding -Category "Cumplimiento DevOps" -CheckId "V00" `
            -Description "No se encontro archivo .csproj en el proyecto" `
            -Status "FAIL" -Risk "Critico" `
            -Recommendation "Agregar archivo de proyecto .csproj"
    }

    $secretsPatterns = @(
        'password\s*=\s*"',
        'connectionstring\s*=\s*"',
        'apikey\s*=\s*"',
        'secret\s*=\s*"'
    )
    $csFiles = Get-ChildItem -Path $SourcePath -Filter "*.cs" -Recurse -ErrorAction SilentlyContinue
    if ($csFiles) {
        foreach ($file in $csFiles) {
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
            if ($content) {
                foreach ($pattern in $secretsPatterns) {
                    if ($content -match $pattern) {
                        Add-Finding -Category "Cumplimiento DevOps" -CheckId "V06" `
                            -Description "Posible secreto hardcodeado en $($file.Name)" `
                            -Status "FAIL" -Risk "Critico" `
                            -Recommendation "Mover secretos a GitHub Secrets o Azure Key Vault"
                        break
                    }
                }
            }
        }
    }
}

# 7. COMPILACION CON ANALYZERS
function Invoke-DotNetBuild {
    Write-AuditLog "Ejecutando compilacion con analyzers de .NET..."

    $csprojFiles = Get-ChildItem -Path $SourcePath -Filter "*.csproj" -Recurse
    if ($csprojFiles.Count -eq 0) {
        Write-AuditLog "No se encontro .csproj, omitiendo compilacion." "WARN"
        return
    }

    $projectDir = $csprojFiles[0].DirectoryName
    Push-Location $projectDir

    try {
        Write-AuditLog "Ejecutando: dotnet restore..."
        $restoreOutput = dotnet restore 2>&1 | Out-String
        Write-Host $restoreOutput

        Write-AuditLog "Ejecutando: dotnet build con analyzers..."
        $buildOutput = dotnet build --no-restore 2>&1 | Out-String
        Write-Host $buildOutput

        if ($LASTEXITCODE -ne 0) {
            Add-Finding -Category "Cumplimiento DevOps" -CheckId "V01" `
                -Description "La compilacion fallo con errores o advertencias tratadas como errores" `
                -Status "FAIL" -Risk "Alto" `
                -Recommendation "Corregir errores de compilacion. Revisar AnalysisLevel y TreatWarningsAsErrors"
        } else {
            Add-Finding -Category "Cumplimiento DevOps" -CheckId "V01" `
                -Description "Compilacion exitosa con analyzers activados" `
                -Status "PASS" -Risk "N/A" `
                -Recommendation "N/A"
        }
    } catch {
        Write-AuditLog "Error durante compilacion: $($_.Exception.Message)" "ERROR"
        Add-Finding -Category "Cumplimiento DevOps" -CheckId "V01" `
            -Description "Error: $($_.Exception.Message)" `
            -Status "FAIL" -Risk "Alto" `
            -Recommendation "Verificar que .NET SDK 8.0 este instalado"
    } finally {
        Pop-Location
    }
}

# GENERAR REPORTE
function New-AuditReport {
    param([string]$OutputPath)

    $endTime = Get-Date
    $duration = $endTime - $Global:StartTime
    $totalChecks = $Global:PassCount + $Global:FailCount
    $passRate = if ($totalChecks -gt 0) { [math]::Round(($Global:PassCount / $totalChecks) * 100, 2) } else { 0 }

    $reportLines = @()
    $reportLines += "# Reporte de Auditoria Estatica"
    $reportLines += ""
    $reportLines += "**Fecha:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    $reportLines += "**Duracion:** $($duration.TotalSeconds) segundos"
    $reportLines += "**Fuente auditada:** $SourcePath"
    $reportLines += "**Checks totales:** $totalChecks | **Aprobados:** $($Global:PassCount) | **Fallidos:** $($Global:FailCount) | **Tasa:** $passRate%"
    $reportLines += "**Umbral minimo:** $MinimumPassRate%"
    $resultEmoji = if ($passRate -ge $MinimumPassRate) { "APROBADO" } else { "RECHAZADO" }
    $reportLines += "**Resultado:** $resultEmoji"
    $reportLines += ""
    $reportLines += "---"
    $reportLines += ""
    $reportLines += "## Hallazgos Detallados"
    $reportLines += ""
    $reportLines += "| Categoria | ID | Descripcion | Estado | Riesgo | Recomendacion |"
    $reportLines += "|-----------|----|-------------|--------|-------|---------------|"

    $categories = $Global:Findings | Group-Object Category
    foreach ($cat in $categories) {
        foreach ($finding in $cat.Group) {
            $se = switch ($finding.Status) {
                "PASS" { "OK" }
                "FAIL" { "NO" }
                "WARN" { "AV" }
                default { "??" }
            }
            $escDesc = $finding.Description -replace '\|', '/'
            $escRec = $finding.Recommendation -replace '\|', '/'
            $reportLines += "| $($finding.Category) | $($finding.CheckId) | $escDesc | $se $($finding.Status) | $($finding.Risk) | $escRec |"
        }
    }

    $reportLines += ""
    $reportLines += "---"
    $reportLines += ""
    $reportLines += "## Resumen por Categoria"
    $reportLines += ""
    $reportLines += "| Categoria | Total | Aprobados | Fallidos | % Cumplimiento |"
    $reportLines += "|-----------|-------|-----------|----------|----------------|"

    foreach ($cat in $categories) {
        $total = $cat.Group.Count
        $passed = ($cat.Group | Where-Object { $_.Status -eq "PASS" }).Count
        $failed = $total - $passed
        $pct = [math]::Round(($passed / $total) * 100, 1)
        $reportLines += "| $($cat.Name) | $total | $passed | $failed | $pct% |"
    }

    $reportLines += ""
    $reportLines += "## Riesgos Identificados"
    $reportLines += ""
    $criticalRisks = $Global:Findings | Where-Object { $_.Risk -eq "Critico" }
    $highRisks = $Global:Findings | Where-Object { $_.Risk -eq "Alto" }

    if ($criticalRisks) {
        $reportLines += "### Criticos"
        foreach ($r in $criticalRisks) {
            $reportLines += "- **$($r.Category) / $($r.CheckId):** $($r.Description)"
        }
        $reportLines += ""
    }
    if ($highRisks) {
        $reportLines += "### Altos"
        foreach ($r in $highRisks) {
            $reportLines += "- **$($r.Category) / $($r.CheckId):** $($r.Description)"
        }
        $reportLines += ""
    }

    $reportLines += ""
    $reportLines += "## Recomendaciones Prioritarias"
    $reportLines += ""
    $reportLines += "1. Reemplazar int.Parse con int.TryParse y agregar try-catch."
    $reportLines += "2. Toda interaccion con el usuario debe estar en bloques try-catch."
    $reportLines += "3. Extraer logica de negocio fuera de Main() en metodos con responsabilidad unica."
    $reportLines += "4. Agregar proyecto de tests con cobertura minima del 70%."
    $reportLines += "5. Agregar comentarios XML y README.md."
    $reportLines += "6. Reemplazar numeros magicos con constantes nombradas."
    $reportLines += "7. Mantener el pipeline de auditoria como gate de calidad."
    $reportLines += ""
    $reportLines += "---"
    $reportLines += "*Reporte generado automaticamente por audit-script.ps1 | Basado en IEEE 1028*"

    $reportContent = $reportLines -join "`n"
    $reportContent | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-AuditLog "Reporte generado: $OutputPath"
}

# MAIN
function Invoke-Audit {
    Write-AuditLog "=== INICIO DE AUDITORIA ESTATICA IEEE 1028 ==="
    Write-AuditLog "Fuente: $SourcePath"
    Write-AuditLog "Umbral minimo: $MinimumPassRate%"

    if (-not (Test-Path $SourcePath)) {
        Write-AuditLog "ERROR: La ruta $SourcePath no existe." "ERROR"
        exit 1
    }

    Invoke-CodeStandardsAudit
    Invoke-SecurityAudit
    Invoke-MaintainabilityAudit
    Invoke-DocumentationAudit
    Invoke-CSharpBestPracticesAudit
    Invoke-DevOpsAudit
    Invoke-DotNetBuild

    New-AuditReport -OutputPath $ReportPath

    $totalChecks = $Global:PassCount + $Global:FailCount
    $passRate = if ($totalChecks -gt 0) { [math]::Round(($Global:PassCount / $totalChecks) * 100, 2) } else { 0 }

    Write-AuditLog "=== RESUMEN: $($Global:PassCount) aprobados, $($Global:FailCount) fallidos (${passRate}%) ==="
    Write-AuditLog "Reporte guardado en: $ReportPath"

    if ($passRate -lt $MinimumPassRate) {
        Write-AuditLog "RESULTADO: RECHAZADO - Tasa ($passRate%) por debajo del umbral ($MinimumPassRate%)" "ERROR"
        exit 1
    } else {
        Write-AuditLog "RESULTADO: APROBADO - Tasa ($passRate%) cumple con el umbral ($MinimumPassRate%)"
        exit 0
    }
}

Invoke-Audit
