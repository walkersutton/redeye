#!/usr/bin/env zsh
set -euo pipefail

usage() {
	printf '%s\n' "Usage: scripts/release-stats.sh [--grouped]"
	printf '%s\n' ""
	printf '%s\n' "Shows GitHub release asset download counts with release versions included."
	printf '%s\n' ""
	printf '%s\n' "Options:"
	printf '%s\n' "  --grouped  Print one section per release instead of a flat table"
}

grouped=false

while [[ $# -gt 0 ]]; do
	case "$1" in
		--grouped)
			grouped=true
			shift
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			printf 'Unknown option: %s\n' "$1" >&2
			usage >&2
			exit 1
			;;
	esac
done

if ! command -v gh >/dev/null 2>&1; then
	printf '%s\n' "GitHub CLI is required. Install gh and authenticate with: gh auth login" >&2
	exit 1
fi

if [[ "$grouped" == true ]]; then
	gh api repos/:owner/:repo/releases --paginate --jq '
		.[] |
		"## \(.tag_name)\nPublished: \(.published_at // .created_at // "unknown")\n" +
		(
			[
				.assets[] |
				"  \(.download_count)x\t\(.name)\tupdated \(.updated_at)"
			] | join("\n")
		) + "\n"
	'
else
	{
		printf 'VERSION\tPUBLISHED_AT\tASSET\tDOWNLOADS\tUPDATED_AT\n'
		gh api repos/:owner/:repo/releases --paginate --jq '
			.[] as $release |
			$release.assets[] |
			[
				$release.tag_name,
				($release.published_at // $release.created_at // ""),
				.name,
				(.download_count | tostring),
				(.updated_at // "")
			] |
			@tsv
		'
	} | column -t -s $'\t'
fi
