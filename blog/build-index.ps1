$HTMLtemplatePath = "index-template.html"
$RSStemplatePath = "rss-template.xml"
$SitemaptemplatePath = "sitemap-template.xml"

$contentFolderPath = "posts"

$HTMLOutput = "index.html"
$RSSOutput = "rss.xml"
$SitemapOutput = "sitemap.xml"


$CultureInfo = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US")
[System.Threading.Thread]::CurrentThread.CurrentCulture = $CultureInfo
[System.Threading.Thread]::CurrentThread.CurrentUICulture = $CultureInfo

$HTMLtemplateContent = Get-Content -Path $HTMLtemplatePath -Raw
$RSStemplateContent = Get-Content -Path $RSStemplatePath -Raw
$SitemaptemplateContent = Get-Content -Path $SitemaptemplatePath -Raw

$htmlFiles = Get-ChildItem -Path $contentFolderPath -Filter "*.html" -Recurse


$HTMLListContent = ""
$RSSListContent = ""
$SitemapListContent = ""


$formattedCurrentDate = $currentDate.ToString("ddd, dd MMM yyyy HH:mm:ss")



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

    $HTMLListContent += '<div><a href="posts/' + $relativePath + '"><div class="posttime">' + $containingFolder + '</div>' + $h1Text + '<br>'+ $pText + '</a></div>'
    
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $guid =  [BitConverter]::ToString($sha256.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($h1Text + $formattedCurrentDate))) -replace '-'

    $RSSListContent += '<item><guid isPermaLink="false">' + $guid + '</guid><title>' + $h1Text + '</title><link>https://yzahkin.games/blog/posts/' + $relativePath + '</link><description>' + $pText + '</description></item>'

    $SitemapListContent += "<url><loc>https://yzahkin.games/blog/posts/$containingFolder</loc><lastmod>$containingFolder</lastmod></url>"

}


$HTMLtemplateContent = $HTMLtemplateContent -replace "\{\{list\}\}", $HTMLListContent
$RSStemplateContent = $RSStemplateContent -replace "\{\{items\}\}", $RSSListContent
$SitemaptemplateContent = $SitemaptemplateContent -replace "\{\{urls\}\}", $SitemapListContent




Set-Content -Path $HTMLOutput -Value $HTMLtemplateContent
Set-Content -Path $RSSOutput -Value $RSStemplateContent
Set-Content -Path $SitemapOutput -Value $SitemaptemplateContent
Write-Host "Template updated and saved to $modifiedFilePath"

