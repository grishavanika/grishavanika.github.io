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
# New-DumpInMarkdown 04.04.25_ue5.5.txt '?application_version=5.5' 03.06.25_ue5.6.txt '?application_version=5.6'
# New-DumpInMarkdown 04.04.25_ue5.5.txt '?application_version=5.5' 13.09.25_ue5.6.txt '?application_version=5.6'
# ------------------------

# New-DumpInMarkdown 04.04.25_ue5.0.txt '?application_version=5.0' 13.09.25_ue5.0.txt '?application_version=5.0'
# New-DumpInMarkdown 04.04.25_ue5.1.txt '?application_version=5.1' 13.09.25_ue5.1.txt '?application_version=5.1'
# New-DumpInMarkdown 04.04.25_ue5.2.txt '?application_version=5.2' 13.09.25_ue5.2.txt '?application_version=5.2'
# New-DumpInMarkdown 04.04.25_ue5.3.txt '?application_version=5.3' 13.09.25_ue5.3.txt '?application_version=5.3'
# New-DumpInMarkdown 04.04.25_ue5.4.txt '?application_version=5.4' 13.09.25_ue5.4.txt '?application_version=5.4'
# New-DumpInMarkdown 04.04.25_ue5.5.txt '?application_version=5.5' 13.09.25_ue5.5.txt '?application_version=5.5'

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
# New-DumpAllLinksToMarkdown 04.04.25_ue5.5.txt '?application_version=5.5'
# New-DumpAllLinksToMarkdown 03.06.25_ue5.6.txt '?application_version=5.6'
# New-DumpAllLinksToMarkdown 13.09.25_ue5.6.txt '?application_version=5.6'

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
# New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/V1Y6/unreal-engine-mocap-manager-tutorial'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/89n2/unreal-engine-setting-up-a-curve-atlas-for-a-stylized-banding'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/y0r9/unreal-engine-creating-stylized-comic-fx-pt-1-smoke-trails'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/courses/QQv/unreal-engine-building-an-rpg-with-gameplay-ability-system/zBvq/unreal-engine-introduction-to-building-an-rpg-with-gameplay-ability-system'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/talks-and-demos/raDl/unreal-engine-unreal-fest-2025-modular-metahumans-materials'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/5XYd/mythen-aufdecken-best-practices-in-der-unreal-engine'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/oWda/unreal-engine-current-graphics-considerations-in-ue5-ue5-3'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/knowledge-base/oWRa/unreal-engine-blueprint-pass-by-reference-a-brief-summary'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/knowledge-base/DBLR/unreal-engine-tech-note-errors-when-compiling-the-unreal-automation-tool-in-5-6'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/talks-and-demos/DBL1/unreal-engine-unreal-fest-2025-heads-tails-with-sequencer'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/WD6y/unreal-engine-fortnite-introduction-to-game-design-and-development'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/knowledge-base/xBvk/unreal-engine-experimental-an-introduction-to-the-multiserver-replication-plugin'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/ywD1/unreal-engine-best-practices-for-networked-movement-abilities-cmc'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/9Xjd/unreal-engine-chaos-cloth-outfit-asset-resizing-addendum'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/a6lz/unreal-engine-chaos-destruction-optimizations'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/lydy/unreal-engine-using-chaos-callbacks-for-a-custom-gravity-system-working-with-round-worlds'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/ra15/unreal-engine-fortnite-importing-blender-grease-pencil-sketches-into-the-epic-ecosystem'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/epLR/unreal-engine-how-to-merge-a-metahuman-animator-head-onto-a-body-using-a-custom-anim-blueprint'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/GjnV/unreal-engine-epic-games-store-ecommerce'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/talks-and-demos/XYDP/unreal-engine-unreal-fest-2025-control-rig-tips-tricks-for-games'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/raPD/unreal-engine-blueprint-module-controlling-niagara-particles-part-2'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/m6JM/unreal-engine-blueprint-module-controlling-niagara-effects-part-3'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/vaEw/unreal-engine-blueprint-module-controlling-niagara-particles-part-1'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/Zmdv/unreal-engine-niagara-module-smoke-effect'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/0zRx/unreal-engine-niagara-module-fire-explosion'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/knowledge-base/1beo/unreal-engine-5-6-behaviortree-crash-when-recompiling-bt-node-bps-during-pie'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/raKx/unreal-engine-import-customization-with-interchange'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/knowledge-base/qBx7/unreal-engine-fortnite-nanite-compute-material-optimizations'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/knowledge-base/raq5/materials-quality-of-life-updates-in-unreal-engine-5-6'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/knowledge-base/DB00/unreal-engine-realityscan-a-handy-workaround-for-organizing-teams-in-the-dev-portal'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/RZwB/unreal-engine-chaos-flesh-muscle-simulation-tutorial-5-6'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/talks-and-demos/wPrj/unreal-engine-fortnite-epic-secondary-educator-summit-may-17-2025'
New-MakrdownLinkFromLearningUrl 'https://dev.epicgames.com/community/learning/tutorials/ep4k/unreal-engine-handling-ui-navigation-with-mvvm-and-common-activatable-widgets'
