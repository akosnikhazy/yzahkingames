$HTMLtemplatePath = "index-template.html"
$RSStemplatePath = "rss-template.xml"
$contentFolderPath = "posts"
$HTMLOutput = "index.html"
$RSSOutput = "rss.xml"


$CultureInfo = [System.Globalization.CultureInfo]::CreateSpecificCulture("en-US")
[System.Threading.Thread]::CurrentThread.CurrentCulture = $CultureInfo
[System.Threading.Thread]::CurrentThread.CurrentUICulture = $CultureInfo

$HTMLtemplateContent = Get-Content -Path $HTMLtemplatePath -Raw
$RSStemplateContent = Get-Content -Path $RSStemplatePath -Raw

$htmlFiles = Get-ChildItem -Path $contentFolderPath -Filter "*.html" -Recurse


$HTMLListContent = ""
$RSSListContent = ""

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
    $RSSListContent += '<item><title>' + $h1Text + '</title></item><link>https://yzahkin.games/blog/posts/' + $relativePath + '</link><description>' + $pText + '</description>'

    

}


$HTMLtemplateContent = $HTMLtemplateContent -replace "\{\{list\}\}", $HTMLListContent

$RSStemplateContent = $RSStemplateContent -replace "\{\{items\}\}", $RSSListContent

$currentDate = Get-Date
$formattedCurrentDate = $currentDate.ToString("ddd, dd MMM yyyy HH:mm:ss zzz")
$RSStemplateContent = $RSStemplateContent -replace "\{\{date\}\}", $formattedCurrentDate


Set-Content -Path $HTMLOutput -Value $HTMLtemplateContent
Set-Content -Path $RSSOutput -Value $RSStemplateContent
Write-Host "Template updated and saved to $modifiedFilePath"