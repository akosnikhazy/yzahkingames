$HTMLtemplatePath = "index-template.html"
$PosttemplatePath = "post-template.html"
$RSStemplatePath = "rss-template.xml"
$SitemaptemplatePath = "sitemap-template.xml"

$contentFolderPath = "posts"

$HTMLOutput = "index.html"
$RSSOutput = "rss.xml"
$SitemapOutput = "sitemap.xml"

$HTMLtemplateContent = Get-Content -Path $HTMLtemplatePath -Raw
$RSStemplateContent = Get-Content -Path $RSStemplatePath -Raw
$SitemaptemplateContent = Get-Content -Path $SitemaptemplatePath -Raw
$postContent = Get-Content -Path $PosttemplatePath -Raw

$directories = Get-ChildItem -Path $contentFolderPath -Directory | Sort-Object Name -Descending

$htmlFiles = @()

foreach ($dir in $directories) {
    $htmlFiles += Get-ChildItem -Path $dir.FullName -Filter "*.html"
}

$HTMLListContent = ""
$RSSListContent = ""
$SitemapListContent = ""

$postCount = 0

foreach ($htmlFile in $htmlFiles) {
   
    $containingFolder = $htmlFile.Directory.Name
    
    $htmlContent = Get-Content -Path $htmlFile.FullName -Raw
     
    $h1Text = "No Title"
    if ($htmlContent -match '<h1>(.*?)</h1>') {
        $h1Text = $matches[1]
    }

    $pText = 'A post about ' + $h1Text
    if ($htmlContent -match '<p>(.*?)</p>') {
        $pText = $matches[1]
    }

    $relativePath = "$containingFolder/$htmlFile"

    $postText = $postContent

    $postText = $postText -replace "\{\{path\}\}",$relativePath
    $postText = $postText -replace "\{\{title\}\}", $h1Text
    $postText = $postText -replace "\{\{date\}\}", $containingFolder
    $postText = $postText -replace "\{\{text\}\}", $pText

    $HTMLListContent +=   $postText

    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $guid =  [BitConverter]::ToString($sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($h1Text + $containingFolder + $relativePath))) -replace '-'

    $pText = $pText -replace '<[^>]*>', ''
    $RSSListContent += '<item><guid isPermaLink="false">' + $guid + '</guid><title>' + $h1Text + '</title><link>https://yzahkin.games/blog/posts/' + $relativePath + '</link><description>' + $pText + '</description></item>' 

    $SitemapListContent += "<url><loc>https://yzahkin.games/blog/posts/$containingFolder</loc><lastmod>$containingFolder</lastmod></url>"

    $postCount++
}

$HTMLtemplateContent = $HTMLtemplateContent -replace "\{\{list\}\}", $HTMLListContent
$RSStemplateContent = $RSStemplateContent -replace "\{\{items\}\}", $RSSListContent
$SitemaptemplateContent = $SitemaptemplateContent -replace "\{\{urls\}\}", $SitemapListContent

Set-Content -Path $HTMLOutput -Value $HTMLtemplateContent
Set-Content -Path $RSSOutput -Value $RSStemplateContent
Set-Content -Path $SitemapOutput -Value $SitemaptemplateContent
Write-Host "$HTMLOutput, $RSSOutput and $SitemapOutput built with $postCount post(s)"