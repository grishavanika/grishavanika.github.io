# [Console]::OuputEncoding = [Text.Encoding]::UTF8

function New-MakrdownLinkFromUrl($url)
{
	$text = $url.Remove($url.IndexOf('?'))
	$text = $text.Substring($text.LastIndexOf('/') + 1)
	$text = $text.Replace('-', ' ')
	return "[$($text)]($($url))"
}

function New-MakrdownLinkFromLearningUrl($url)
{
	$title = $url.Substring($url.LastIndexOf('/') + 1)
	$title = $title.Replace('-', ' ')
	$p = $title.IndexOf('unreal engine')
	if ($p -eq 0)
	{
		$title = $title.Substring('unreal engine'.Length + 1)
	}
	$s = $url.IndexOf('/learning/') + '/learning/'.Length
	$e = $url.IndexOf('/', $s + 1)
	$kind = $url.Substring($s, $e - $s)
	return "|$($kind)| [$($title)]($($url))"
}

function New-Dump($old, $old_version, $new, $new_version)
{
	$links_old=cat $old
	$links_old=$links_old | % {$_.Replace($old_version, "")}
	$links_new=cat $new
	$links_new=$links_new | % {$_.Replace($new_version, "")}
	$diff = Compare-Object -ReferenceObject $links_old -DifferenceObject $links_new
	$removed_links=@($diff | Where {$_.SideIndicator -eq '<='})
	$added_links=@($diff | Where {$_.SideIndicator -eq '=>'})
	$removed_links = $removed_links | % {$_.InputObject + $old_version}
	$added_links = $added_links | % {$_.InputObject + $new_version}

	Write-Warning " ---- REMOVED LINKS - $($removed_links.Count)"
	$removed_links | Format-List

	Write-Warning " ---- ADDED LINKS - $($added_links.Count)"
	$added_links | Format-List
}

# New-Dump 04.04.25_ue5.0.txt '?application_version=5.0' 04.04.25_ue5.1.txt '?application_version=5.1'
# New-Dump 04.04.25_ue5.1.txt '?application_version=5.1' 04.04.25_ue5.2.txt '?application_version=5.2'
# New-Dump 04.04.25_ue5.2.txt '?application_version=5.2' 04.04.25_ue5.3.txt '?application_version=5.3'
# New-Dump 04.04.25_ue5.3.txt '?application_version=5.3' 04.04.25_ue5.4.txt '?application_version=5.4'
# New-Dump 04.04.25_ue5.4.txt '?application_version=5.4' 04.04.25_ue5.5.txt '?application_version=5.5'

function New-DumpInMarkdown($old, $old_version, $new, $new_version)
{
	$old_title = $old_version.Substring($old_version.IndexOf('=') + 1)
	$new_title = $new_version.Substring($new_version.IndexOf('=') + 1)
	$links_old=cat $old
	$links_old=$links_old | % {$_.Replace($old_version, "")}
	$links_new=cat $new
	$links_new=$links_new | % {$_.Replace($new_version, "")}
	$diff = Compare-Object -ReferenceObject $links_old -DifferenceObject $links_new
	$removed_links=@($diff | Where {$_.SideIndicator -eq '<='})
	$added_links=@($diff | Where {$_.SideIndicator -eq '=>'})
	$removed_links = $removed_links | % {$_.InputObject + $old_version}
	$added_links = $added_links | % {$_.InputObject + $new_version}

	$file_name = "utf16-ue_diff_$($old_title)_vs_$($new_title).md"

	"## Removed in $($new_title) (vs $($old_title)) = $($removed_links.Count) links" > $file_name
	"" >> $file_name
	foreach ($link in $removed_links)
	{
		$url = New-MakrdownLinkFromUrl $link
		" * $($url)" >> $file_name
	}
	"" >> $file_name
	"" >> $file_name


	"## Added in $($new_title) (vs $($old_title)) = $($added_links.Count) links" >> $file_name
	"" >> $file_name
	foreach ($link in $added_links)
	{
		$url = New-MakrdownLinkFromUrl $link
		" * $($url)" >> $file_name
	}

	$new_file = "ue_diff_$($old_title)_vs_$($new_title).md"
	Get-Content $file_name | Set-Content -Encoding utf8 $new_file
	Remove-Item $file_name -Force | Out-Null
	# & "pandoc" $new_file -o "ue_diff_$($old_title)_vs_$($new_title).html"
	# Remove-Item $new_file -Force | Out-Null
}


# New-DumpInMarkdown 04.04.25_ue5.0.txt '?application_version=5.0' 04.04.25_ue5.1.txt '?application_version=5.1'
# New-DumpInMarkdown 04.04.25_ue5.1.txt '?application_version=5.1' 04.04.25_ue5.2.txt '?application_version=5.2'
# New-DumpInMarkdown 04.04.25_ue5.2.txt '?application_version=5.2' 04.04.25_ue5.3.txt '?application_version=5.3'
# New-DumpInMarkdown 04.04.25_ue5.3.txt '?application_version=5.3' 04.04.25_ue5.4.txt '?application_version=5.4'
# New-DumpInMarkdown 04.04.25_ue5.4.txt '?application_version=5.4' 04.04.25_ue5.5.txt '?application_version=5.5'

function New-DumpAllLinksToMarkdown($links_file, $version)
{
	$title = $version.Substring($version.IndexOf('=') + 1)	
	$links = cat $links_file
	$file_name = "utf16-ue_$($title).md"

	"## Topics in Unreal Engine UE$($title) = $($links.Count) links" > $file_name
	"" >> $file_name
	foreach ($link in $links)
	{
		$url = New-MakrdownLinkFromUrl $link
		" * $($url)" >> $file_name
	}
	"" >> $file_name
	"" >> $file_name

	$new_file = "ue_$($title).md"
	Get-Content $file_name | Set-Content -Encoding utf8 $new_file
	Remove-Item $file_name -Force | Out-Null
	# & "pandoc" $new_file -o "ue_$($title).html"
	# Remove-Item $new_file -Force | Out-Null
}

# New-DumpAllLinksToMarkdown 04.04.25_ue4.27.txt '?application_version=4.27'
# New-DumpAllLinksToMarkdown 04.04.25_ue5.0.txt '?application_version=5.0'
# New-DumpAllLinksToMarkdown 04.04.25_ue5.1.txt '?application_version=5.1'
# New-DumpAllLinksToMarkdown 04.04.25_ue5.2.txt '?application_version=5.2'
# New-DumpAllLinksToMarkdown 04.04.25_ue5.3.txt '?application_version=5.3'
# New-DumpAllLinksToMarkdown 04.04.25_ue5.4.txt '?application_version=5.4'

function New-DumpLearningLinksToMarkdown($links_file)
{
	$links = cat $links_file
	$file_name = "utf16-ue_learning.md"

	"## Learning links = $($links.Count)" > $file_name
	"" >> $file_name
	foreach ($link in $links)
	{
		$url = New-MakrdownLinkFromLearningUrl $link
		" * $($url)" >> $file_name
	}
	"" >> $file_name
	"" >> $file_name

	$new_file = "ue_learning.md"
	Get-Content $file_name | Set-Content -Encoding utf8 $new_file
	Remove-Item $file_name -Force | Out-Null
	# & "pandoc" $new_file -o "ue_$($title).html"
	# Remove-Item $new_file -Force | Out-Null
}

# New-DumpLearningLinksToMarkdown 04.04.25_ue_learnings.txt