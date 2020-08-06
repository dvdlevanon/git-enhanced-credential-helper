#!/bin/bash

function main() {
	local current_credential_helper=$(git config --global --get credential.helper)
	
	if [ ! -r ".old-credential.helper" ]; then
		echo "Unable to resotre credential helper .old-credential.helper is missing"
		echo "You may set it manually as follow 'git config --global credential.helper store'"
		return 1
	fi
		 
	local old_credentail_helper=$(cat .old-credential.helper)
		
	if ! git config --global credential.helper $old_credentail_helper; then
		return 1
	fi
	
	echo "Old credential helper was: $current_credential_helper"
	echo "Credentail helper restored successfully ($old_credentail_helper)"
	return 0
}

main "$@" || exit 1
