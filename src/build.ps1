# Сборка статичных страниц: вшивает общие стили, шапку/подвал, логотипы (base64) и генерирует карточки статей из articles.tsv
param(
  [string]$Assets = "$PSScriptRoot\assets"
)
$ErrorActionPreference = 'Stop'
$src = $PSScriptRoot
$out = Split-Path $src -Parent
$utf8 = New-Object System.Text.UTF8Encoding($false)
function Read-Text($p) { [IO.File]::ReadAllText($p, $utf8) }

$UP = 'https://ltrstyle.ru/wp-content/uploads/'
$catName = @{ c = 'Окрашивание'; h = 'Стрижки и укладки'; u = 'Уход' }

# ---------- данные ----------
$i = 0
$arts = foreach ($line in (Read-Text "$src\articles.tsv") -split "`r?`n") {
  if (-not $line.Trim()) { continue }
  $f = $line -split "`t"
  [pscustomobject]@{
    i = $i++; slug = $f[0]; cat = $f[1]; title = $f[2]; img = $UP + $f[3]
    views = [int]$f[4]; ex = $f[6]
  }
}
function Url($a) { "https://ltrstyle.ru/articles/$($a.slug)/" }

function Card($a, [switch]$Lazy) {
  $load = if ($Lazy) { ' loading="lazy"' } else { '' }
@"
<a class="acard" href="$(Url $a)" data-cat="$($a.cat)" data-views="$($a.views)" data-i="$($a.i)">
  <div class="acard__pic"><img src="$($a.img)" alt=""$load decoding="async"><span class="acard__cat">$($catName[$a.cat])</span></div>
  <div class="acard__body">
    <h3 class="acard__title">$($a.title)</h3>
    <p class="acard__ex">$($a.ex)…</p>
    <span class="btn btn--navy acard__go">Читать</span>
  </div>
</a>
"@
}

# ---------- общие куски ----------
$common = @{
  '{{COMMON_CSS}}' = Read-Text "$src\common.css"
  '{{HEADER}}'     = Read-Text "$src\header.html"
  '{{FOOTER}}'     = Read-Text "$src\footer.html"
}
$assetsMap = @{}
foreach ($k in 'LOGO','FLOGO','WA','TG','ORDERPHOTO') { $assetsMap["{{$k}}"] = (Read-Text "$Assets\$k.txt").Trim() }

function Build($tpl, $dst, $vars) {
  $html = Read-Text "$src\$tpl"
  foreach ($k in $common.Keys) { $html = $html.Replace($k, $common[$k]) }
  foreach ($k in $vars.Keys)   { $html = $html.Replace($k, [string]$vars[$k]) }
  foreach ($k in $assetsMap.Keys) { $html = $html.Replace($k, $assetsMap[$k]) }
  $left = [regex]::Matches($html, '\{\{[A-Z_]+\}\}') | ForEach-Object Value | Select-Object -Unique
  if ($left) { throw "$dst — не заполнены: $($left -join ', ')" }
  [IO.File]::WriteAllText("$out\$dst", $html, $utf8)
  '{0,-14} {1,8:N0} KB' -f $dst, ((Get-Item "$out\$dst").Length / 1KB)
}

# ---------- Список статей ----------
$feat = $arts[0]

Build 'index.tpl.html' 'index.html' @{
  '{{CARDS}}'       = (($arts | ForEach-Object { Card $_ -Lazy:($_.i -ge 6) }) -join "`n")
  '{{F_URL}}'       = Url $feat
  '{{F_IMG}}'       = $feat.img
  '{{F_TITLE}}'     = $feat.title
  '{{F_EX}}'        = $feat.ex
  '{{F_CAT}}'       = $catName[$feat.cat]
  '{{N_ALL}}'       = $arts.Count
  '{{N_C}}'         = @($arts | Where-Object cat -eq 'c').Count
  '{{N_H}}'         = @($arts | Where-Object cat -eq 'h').Count
  '{{N_U}}'         = @($arts | Where-Object cat -eq 'u').Count
  '{{ORDER_TITLE}}' = 'Скидка 10% на&nbsp;первый визит'
  '{{ORDER_SUB}}'   = 'Оставьте имя и телефон — администратор перезвонит, подберёт мастера и удобное время. Скидка <b>10%</b> по промокоду «Сайт».'
}

# ---------- Статья ----------
$bySlug = @{}; $arts | ForEach-Object { $bySlug[$_.slug] = $_ }
$related = 'kak-podobrat-strizhku-po-forme-licza','osobennosti-ukladki-na-goryachij-instrument','trendovye-chelki-kak-najti-svoj-variant'
$share = @'
<a class="sh" data-share-to="vk" href="#" target="_blank" rel="noopener" aria-label="Поделиться во ВКонтакте">VK</a>
<a class="sh" data-share-to="ok" href="#" target="_blank" rel="noopener" aria-label="Поделиться в Одноклассниках">OK</a>
<a class="sh" data-share-to="tg" href="#" target="_blank" rel="noopener" aria-label="Поделиться в Telegram"><svg viewBox="0 0 20 20"><path d="M18 3 2 9.5l5.5 2L16 5.5 9.5 13l6 4.5L18 3Z"/></svg></a>
<a class="sh" data-share-to="wa" href="#" target="_blank" rel="noopener" aria-label="Поделиться в WhatsApp"><svg viewBox="0 0 20 20"><path d="M3 17l1.2-3.6A7.5 7.5 0 1 1 7 16.2L3 17Z"/><path d="M7.5 7.2c.3 2.4 2 4.4 4.6 5.3l1-1.1-1.6-.9-.7.7c-.9-.4-1.9-1.4-2.3-2.3l.7-.7-.9-1.6-1 .6Z"/></svg></a>
<button class="sh" type="button" data-copy aria-label="Скопировать ссылку"><svg viewBox="0 0 20 20"><path d="M8.5 11.5a3.5 3.5 0 0 0 5 0l2.5-2.5a3.5 3.5 0 0 0-5-5l-1 1"/><path d="M11.5 8.5a3.5 3.5 0 0 0-5 0L4 11a3.5 3.5 0 0 0 5 5l1-1"/></svg></button>
'@
Build 'article.tpl.html' 'article.html' @{
  '{{SHARE}}'       = $share
  '{{RELATED}}'     = (($related | ForEach-Object { Card $bySlug[$_] -Lazy }) -join "`n")
  '{{ORDER_TITLE}}' = 'Подберём стрижку без укладки'
  '{{ORDER_SUB}}'   = 'Оставьте телефон — администратор перезвонит и запишет на консультацию к стилисту. Новым клиентам <b>скидка 10%</b> по промокоду «Сайт».'
}
