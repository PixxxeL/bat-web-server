# Убедитесь, что вы запускаете PowerShell с правами администратора

# Укажите порт и путь к директории, которую хотите обслуживать
param (
    [int]$port = 8080
)
#$path = $PWD.Path
$path = Split-Path -Path $MyInvocation.MyCommand.Path -Parent

# Создаем HttpListener и начинаем слушать
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$port/")
$listener.Start()
Write-Host "Сервер запущен на http://127.0.0.1:$port/"
Write-Host "и слушает папку: $path/"

try {
    while ($true) {
        # Ожидание запроса
        $context = $listener.GetContext()
        
        # Получаем путь к запрашиваемому файлу
        $requestedFile = Join-Path -Path $path -ChildPath $context.Request.Url.AbsolutePath.TrimStart('/')

        if (Test-Path $requestedFile) {
            # Определяем тип контента по расширению файла
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

            # Отправляем файл
            $fileStream = [System.IO.File]::OpenRead($requestedFile)
            $fileStream.CopyTo($context.Response.OutputStream)
            $fileStream.Close()
            $context.Response.StatusCode = 200
        } else {
            # Если файл не найден, отправляем 404
            $context.Response.StatusCode = 404
            $context.Response.ContentType = "text/plain"
            $responseString = "404 Not Found"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseString)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
        }

        # Закрываем ответ
        $context.Response.Close()
    }
} catch {
    Write-Host "Произошла ошибка: $_"
} finally {
    # Останавливаем сервер при завершении работы
    $listener.Stop()
}
