#!/bin/bash

# This scripts follows those guides:
#	https://git-scm.com/docs/git-credential#IOFMT
#	https://git-scm.com/docs/gitcredentials
#	https://git-scm.com/docs/api-credentials
#	https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage
#

declare -r script_dir=$(cd "$( dirname "$0" )" && pwd)
declare -r git_remote=$(git remote get-url --all origin)
declare -r git_repository_name=$(basename $git_remote)
declare -r git_server_path=$(dirname $git_remote)
declare -r git_server_path_dir=$(basename $git_server_path)

declare input_host=
declare input_protocol=
declare input_path=
declare input_username=
declare input_password=
declare input_url=

declare persistance_dir="$script_dir/store"
declare secure_param="false"

declare git_credential_helper_password_file="$script_dir/.password"
declare git_credential_helper_password=

function error() {
	echo "$@" 1>&2;
}

function read_credential_input() {
	local pipe_input_lines=$(</dev/stdin)

	for input_line in $pipe_input_lines; do
		local key=$(echo "$input_line" | awk -F "=" '{ print $1 }')
		local value=$(echo "$input_line" | awk -F "=" '{ print $2 }')
		
		if [ "$key" == "host" ]; then
			input_host="$value"
		elif [ "$key" == "protocol" ]; then
			input_protocol="$value"
		elif [ "$key" == "path" ]; then
			input_path="$value"
		elif [ "$key" == "username" ]; then
			input_username="$value"
		elif [ "$key" == "password" ]; then
			input_password="$value"
		elif [ "$key" == "url" ]; then
			input_url="$value"
		elif [ "$key" == "realm" ]; then
			:
		elif [ "$key" == "wwwauth[]" ]; then
			:
		elif [ "$key" == "capability[]" ]; then
			:
		else
			error "Unknown input line: $input_line"
		fi
	done
}

function validate_params() {
	if [ -n "$input_url" ]; then
		error "Unsupported input param url: $input_url"
		return 1
	fi
	
	if [ -n "$input_path" ]; then
		error "Unsupported input param path: $input_path"
		return 1
	fi
	
	if [ -z "$input_protocol" ]; then
		error "Missing mandatory protocol input"
		return 1
	fi
	
	if [ -z "$input_host" ]; then
		error "Missing mandatory host input"
		return 1
	fi
	
	if [ -z "$git_server_path_dir" ]; then
		error "Missing mandatory git path dir"
		return 1
	fi
			
	return 0
}

function get_persistance_file() {
	echo "$persistance_dir/$input_protocol$input_host$git_server_path_dir"
}

function get_credential() {
	local persistance_file=$(get_persistance_file)
	
	if [ "$secure_param" == "true" ]; then
		local persistance_file_encrypted=${persistance_file}.gpg
		
		if [ ! -r "$persistance_file_encrypted" ]; then
			return 0
		fi
		
		if ! gpg --quiet --decrypt-files --yes --batch "--passphrase=$git_credential_helper_password" "$persistance_file_encrypted"; then
			error "Error dycrypting persistance file: $persistance_file"
			return 1
		fi
		
		if [ ! -r "$persistance_file" ]; then
			error "Decrypted file not found: $persistance_file"
			return 1
		fi
	fi
	
	local credential_lines=$(cat $persistance_file)
	
	if [ "$secure_param" == "true" ]; then
		rm "$persistance_file"
	fi
	
	if [ -z "$credential_lines" ]; then
		return 0
	fi
	
	local credentail_username=
	local credentail_password=
	
	for credential_line in $credential_lines; do
		local key=$(echo "$credential_line" | awk -F "=" '{ print $1 }')
		local value=$(echo "$credential_line" | awk -F "=" '{ print $2 }')
		
		if [ "$key" == "username" ]; then
			credentail_username="$value"
		elif [ "$key" == "password" ]; then
			credentail_password="$value"
		else
			error "Unknown credential line: $credential_line"
		fi
	done
	
	if [ -n "$credentail_username" -a -n "$credentail_password" ]; then
		echo "username=$credentail_username"
		echo "password=$credentail_password"
		
		return 0
	fi
	
	return 0
}

function set_credential() {
	local persistance_file=$(get_persistance_file)
	local persistance_file_encrypted=${persistance_file}.gpg
	
	local persistance_directory=$(dirname $persistance_file)
	mkdir -p "$persistance_directory"
	
	echo "username=$input_username" > $persistance_file
	echo "password=$input_password" >> $persistance_file
	
	if [ "$secure_param" == "false" ]; then
		return 0
	fi
	
	if ! gpg --quiet --yes --batch "--passphrase=$git_credential_helper_password" -c $persistance_file; then
		error "Error encrypting persistance file: $persistance_file"
		return 1
	fi
	
	if [ ! -r "$persistance_file_encrypted" ]; then
		error "Encrypted file not found: $persistance_file_encrypted"
	fi
	
	rm "$persistance_file"
	
	return 0
}

function main() {
	persistance_dir=$1
	secure_param=$2
	local command=$3
	
	if [ ! -r "$git_credential_helper_password_file" ]; then
		error "Unable to encrypt/decrypt credentials, password file is missing"
		error "  Please put your password in: $git_credential_helper_password_file"
		return 1
	fi
	
	git_credential_helper_password=$(cat $git_credential_helper_password_file)
	
	read_credential_input
	
	if ! validate_params; then
		return 1
	fi
	
	if [ "$command" == "get" ]; then
		get_credential
	elif [  "$command" == "store" ]; then
		set_credential
	fi
	
	return 0
}

if [ "$skip_main" != "true" ]; then
	main "$@" || exit 1
fi
