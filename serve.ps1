$port = 8090
$root = "$PSScriptRoot\build\web"
$mime = @{
    '.html' = 'text/html'
    '.js'   = 'application/javascript'
    '.css'  = 'text/css'
    '.json' = 'application/json'
    '.png'  = 'image/png'
    '.ico'  = 'image/x-icon'
    '.svg'  = 'image/svg+xml'
    '.wasm' = 'application/wasm'
}
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$port/")
$listener.Start()
Write-Host "Serving at http://127.0.0.1:$port"
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $path = $ctx.Request.Url.AbsolutePath
    if ($path -eq '/') { $path = '/index.html' }
    $file = Join-Path $root $path.Replace('/', '\')
    if (Test-Path $file) {
        $ext = [System.IO.Path]::GetExtension($file)
        $ctx.Response.ContentType = $mime[$ext] -replace '^$', 'application/octet-stream'
        $data = [System.IO.File]::ReadAllBytes($file)
        $ctx.Response.ContentLength64 = $data.Length
        $ctx.Response.OutputStream.Write($data, 0, $data.Length)
    } else {
        $ctx.Response.StatusCode = 404
    }
    $ctx.Response.Close()
}
