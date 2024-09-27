# ���������, ��� �� ���������� PowerShell � ������� ��������������

# ������� ���� � ���� � ����������, ������� ������ �����������
param (
    [int]$port = 8080
)
#$path = $PWD.Path
$path = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# ������� HttpListener � �������� �������
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$port/")
$listener.Start()
Write-Host "������ ������� �� http://127.0.0.1:$port/"
Write-Host "� ������� �����: $path/"

try {
    while ($true) {
        # �������� �������
        $context = $listener.GetContext()
        
        # �������� ���� � �������������� �����
        $requestedFile = Join-Path -Path $path -ChildPath $context.Request.Url.AbsolutePath.TrimStart('/')

        if (Test-Path $requestedFile) {
            # ���������� ��� �������� �� ���������� �����
            $extension = [System.IO.Path]::GetExtension($requestedFile).ToLower()
            switch ($extension) {
                ".html" { $context.Response.ContentType = "text/html" }
                ".css"  { $context.Response.ContentType = "text/css" }
                ".js"   { $context.Response.ContentType = "application/javascript" }
                ".png"  { $context.Response.ContentType = "image/png" }
                ".jpg"  { $context.Response.ContentType = "image/jpeg" }
                ".jpeg"  { $context.Response.ContentType = "image/jpeg" }
                ".gif"  { $context.Response.ContentType = "image/gif" }
                default { $context.Response.ContentType = "application/octet-stream" }
            }

            # ���������� ����
            $fileStream = [System.IO.File]::OpenRead($requestedFile)
            $fileStream.CopyTo($context.Response.OutputStream)
            $fileStream.Close()
            $context.Response.StatusCode = 200
        } else {
            # ���� ���� �� ������, ���������� 404
            $context.Response.StatusCode = 404
            $context.Response.ContentType = "text/plain"
            $responseString = "404 Not Found"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseString)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
        }

        # ��������� �����
        $context.Response.Close()
    }
} catch {
    Write-Host "��������� ������: $_"
} finally {
    # ������������� ������ ��� ���������� ������
    $listener.Stop()
}
