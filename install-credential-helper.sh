#!/bin/bash

declare -r script_dir=$(cd "$( dirname "$0" )" && pwd)
declare -r script_name=`basename "$0"`

declare storage_dir="$script_dir/store"
declare secure_credential_file="false"

function usage() {
	echo "./$script_name [options]"
	echo "	-d|--store-dir=[DIR]	Store the Git Credentials in DIR"
	echo "	-s|--secure		If set, enables GnuPG encryption for the credentials file"
	echo "	-h|--help		Print this usage"
}

function parse_command_line() {
	local TEMP=$(getopt -o 'd:sh' --long 'store-dir:,secure,help' -n '$script_name' -- "$@")
	
	eval set -- "$TEMP"
	
	if [ $? -ne 0 ]; then
		usage
		exit 1
	fi
	
	while true; do
		case "$1" in
			'-h'|'--help')
				usage
				exit 0
			;;
			'-d'|'--store-dir')
				storage_dir="$2"
				shift 2
				continue
			;;
			'-s'|'--secure')
				secure_credential_file="true"
				shift
				continue
			;;
			'--')
				shift
				break
			;;
			*)
				echo 'Unknown param: $1' >&2
				usage
				exit 1
			;;
		esac
	done
}

function main() {
	parse_command_line "$@"
	
	local current_credential_helper=$(git config --global --get credential.helper)
	local old_credential_helper_file="$script_dir/.old-credential.helper"
	
	if [[ "$current_credential_helper" != *"enhanced-credential-helper"* ]]; then
		echo "$current_credential_helper" > "$old_credential_helper_file"
	fi
	
	local credential_helper_script="$script_dir/enhanced-credential-helper.sh"
	local credential_helper="$credential_helper_script $storage_dir"
	
	if [ "$secure_credential_file" == "true" ]; then
		credential_helper="$credential_helper true"
	else
		credential_helper="$credential_helper false"
	fi
	
	if ! git config --global credential.helper "$credential_helper"; then
		return 1
	fi
	
	echo "Git credential helper changed to: '$credential_helper'"
	
	return 0
}

main "$@" || exit 1
