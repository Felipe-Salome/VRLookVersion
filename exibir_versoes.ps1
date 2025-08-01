param(
    [string]$jarPath
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Função para analisar o conteúdo de um arquivo .properties
function Convert-PropertiesContent($content) {
    $dict = [ordered]@{}
    $reader = [System.IO.StringReader]::new($content)
    
    try {
        while ($line = $reader.ReadLine()) {
            $line = $line.Trim()
            if (-not [string]::IsNullOrWhiteSpace($line) -and -not $line.StartsWith('#')) {
                $index = $line.IndexOf('=')
                if ($index -gt 0) {
                    $key = $line.Substring(0, $index).Trim()
                    $value = $line.Substring($index + 1).Trim()
                    $dict[$key] = $value
                }
            }
        }
    }
    finally {
        $reader.Dispose()
    }
    return $dict
}

# Função para formatar a versão
function Format-Version($dict) {
    $version = "$($dict['versao.major']).$($dict['versao.minor']).$($dict['versao.release'])-$($dict['versao.build'])"
    if ($dict['versao.beta'] -ne "0") {
        $version += "b$($dict['versao.beta'])"
    }
    return $version
}

try {
    # Verificar se o arquivo existe
    if (-not (Test-Path $jarPath)) {
        [System.Windows.Forms.MessageBox]::Show("Arquivo JAR não encontrado: $jarPath", "Erro")
        exit 1
    }

    # Criar interface de carregamento
    $loadingForm = New-Object System.Windows.Forms.Form
    $loadingForm.Text = "Carregando versões..."
    $loadingForm.Size = New-Object System.Drawing.Size(300, 100)
    $loadingForm.StartPosition = "CenterScreen"
    $loadingForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $loadingForm.TopMost = $true
    $loadingForm.ControlBox = $false

    $loadingLabel = New-Object System.Windows.Forms.Label
    $loadingLabel.Text = "Analisando arquivo JAR..."
    $loadingLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $loadingLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $loadingForm.Controls.Add($loadingLabel)

    # Mostrar a tela de carregamento
    $loadingForm.Show()
    $loadingForm.Refresh()
    [System.Windows.Forms.Application]::DoEvents()

    $results = @()
    $totalFiles = 0
    $processedFiles = 0
    
    try {
        # Abrir o arquivo JAR
        $zip = [System.IO.Compression.ZipFile]::OpenRead($jarPath)
        
        # Filtrar e contar arquivos
        $entries = $zip.Entries | Where-Object { $_.Name -like 'vr*.properties' }
        $totalFiles = $entries.Count
        
        if ($totalFiles -eq 0) {
            $results += "Nenhum arquivo vr*.properties encontrado."
        }
        else {
            foreach ($entry in $entries) {
                $processedFiles++
                $loadingLabel.Text = "Processando ($processedFiles/$totalFiles)..."
                $loadingForm.Refresh()
                [System.Windows.Forms.Application]::DoEvents()
                
                # Ler conteúdo diretamente na memória
                $stream = $entry.Open()
                $reader = [System.IO.StreamReader]::new($stream)
                $content = $reader.ReadToEnd()
                $reader.Dispose()
                $stream.Dispose()
                
                $dict = Convert-PropertiesContent $content
                $libName = [System.IO.Path]::GetFileNameWithoutExtension($entry.Name)
                
                if ($dict['versao.major'] -and $dict['versao.minor'] -and $dict['versao.release'] -and $dict['versao.build']) {
                    $version = Format-Version $dict
                    $results += "${libName}: $version"
                }
                else {
                    $results += "${libName}: versão incompleta"
                }
            }
        }
    }
    catch {
        $results += "Erro ao processar JAR: $($_.Exception.Message)"
    }
    finally {
        if ($zip) { $zip.Dispose() }
        $loadingForm.Close()
    }

    if ($results.Count -eq 0) {
        $results = @("Nenhuma versão encontrada nos arquivos.")
    }

    # Criar e mostrar a janela de resultados
    $resultForm = New-Object System.Windows.Forms.Form
    $resultForm.Text = "Versões das Bibliotecas"
    $resultForm.Size = New-Object System.Drawing.Size(600, 400)
    $resultForm.StartPosition = "CenterScreen"
    $resultForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $resultForm.MaximizeBox = $false

    $textbox = New-Object System.Windows.Forms.TextBox
    $textbox.Multiline = $true
    $textbox.Dock = [System.Windows.Forms.DockStyle]::Fill
    $textbox.ReadOnly = $true
    $textbox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $textbox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $textbox.Text = $results -join "`r`n"

    $resultForm.Controls.Add($textbox)
    $resultForm.Topmost = $true
    $resultForm.Add_Shown({ $resultForm.Activate() })
    $resultForm.ShowDialog()
}
catch {
    if ($loadingForm) { $loadingForm.Close() }
    [System.Windows.Forms.MessageBox]::Show("Erro ao processar JAR: `n$($_.Exception.Message)", "Erro", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}