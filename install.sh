#!/usr/bin/env sh

set -e

source_path='./scripts'
target_path_relative_to_home='.local/bin'
target_path="$HOME/$target_path_relative_to_home"
profile_path="$HOME/.profile"

print_help() {
	printf '%s - A simple installation script.\n' "$(basename "$0")"
	#shellcheck disable=SC2016
	printf '    Basically, all it does is copying the files to "%s" and\n    making sure this directory is in "$PATH" (by editing "%s").\n' "\$HOME/$target_path_relative_to_home" "\$HOME/.profile"
	printf '    (Hardcore terminal dwellers will probably want to do it their way but this\n    is more than good enough for a casual user.)\n'
	printf '\n'
	printf 'usage: %s [<option>...]\n' "$(basename "$0")"
	printf '\n'
	printf 'options:\n'
	printf '    -h, --help\t\t- Show this help text.\n'
	printf '    -u, --uninstall\t- Undo all the changes that the install script would\n\t\t\t  made without this flag.\n'
}

gather_tasks() {
	tasks="$(
		if [ "$uninstall" = n ]
		then
			if [ ! -e "$target_path" ]
			then
				printf 'create-home-local-bin\n'
			fi
			if [ -n "$(find "$source_path" -type f | while read -r script ; do if ! cmp -s "$script" "$target_path$(printf '%s' "$script" | cut -c$((${#source_path} + 1))-)" ; then printf 'c' ; fi ; done)" ]
			then
				printf 'copy-to-home-local-bin\n'
			fi
			if ! printf '%s' "$PATH" | tr ':' '\n' | grep -qFx "$HOME/.local/bin"
			then
				printf 'add-home-local-bin-to-path\n'
			fi
		else
			if [ -z "$(find "$target_path" -type f | while read -r f ; do if [ ! -e "$source_path$(printf '%s\n' "$f" | cut -c$((${#target_path} + 1))-)" ] ; then printf 'x' ; break ; fi ; done)" ]
			then
				printf 'remove-home-local-bin-from-path\n'
			fi
			if [ -n "$(find "$source_path" -type f | while read -r script ; do if [ -e "$target_path$(printf '%s' "$script" | cut -c$((${#source_path} + 1))-)" ] ; then printf 'e' ; fi ; done)" ]
			then
				printf 'delete-from-home-local-bin\n'
			fi
			if [ -z "$(find "$target_path" -type f | while read -r f ; do if [ ! -e "$source_path$(printf '%s\n' "$f" | cut -c$((${#target_path} + 1))-)" ] ; then printf 'x' ; break ; fi ; done)" ]
			then
				printf 'remove-home-local-bin\n'
			fi
		fi
	)"
}

show_tasks() {
	printf 'Installing "git-istash" for the current user (%s)...\n' "$(id -nu)"
	printf 'Operations that are to be performed:\n'
	printf '%s\n' "$tasks" \
	| while read -r task
	do
		printf '  - '
		case "$task" in
			create-home-local-bin)
				printf 'A directory "%s" will be created.\n' "$target_path"
				;;
			copy-to-home-local-bin)
				printf 'The contents of the directory "%s" will be copied to\n    "%s".\n' "$source_path" "$target_path"
				;;
			add-home-local-bin-to-path)
				#shellcheck disable=SC2016
				printf '"%s" will be added to "$PATH" by appending\n    a line to the "%s".\n' "$target_path" "$profile_path"
				;;
			remove-home-local-bin-from-path)
				#shellcheck disable=SC2016
				printf 'The line in "%s" that appends\n    "%s" to "$PATH" will be removed.\n' "$profile_path" "$target_path"
				;;
			delete-from-home-local-bin)
				printf 'The contents of the directory "%s" will be deleted from\n    "%s".\n' "$source_path" "$target_path"
				;;
			remove-home-local-bin)
				printf 'The (now empty) directory "%s" will be removed.\n' "$target_path"
				;;
			*)
				printf 'fatal: Unknown task "%s".' "$task" 1>&2
				exit 1
				;;
		esac
	done
}

ask_confirmation() {
	printf '\nDo you want to continue? [y/N]\n'
	while read -r answer
	do
		if printf '%s' "$answer" | grep -qix 'y\|yes'
		then
			return 0
		elif [ -z "$answer" ] || printf '%s' "$answer" | grep -qix 'n\|no'
		then
			return 1
		else
			printf 'Answer "y" or "n".\n' 1>&2
		fi
	done
	return 1
}

print_export_path() {
	printf '\n'
	printf '# add user'\''s private bin directory to PATH\n'
	#shellcheck disable=SC2016
	printf 'export PATH="$HOME/%s:$PATH"\n' "$target_path_relative_to_home"
}

run_tasks() {
	printf '%s\n' "$tasks" \
	| while read -r task
	do
		case "$task" in
			create-home-local-bin)
				mkdir -p "$target_path"
				;;
			copy-to-home-local-bin)
				cp -fr "$source_path"/* "$target_path"
				;;
			add-home-local-bin-to-path)
				print_export_path >>"$profile_path"
				;;
			remove-home-local-bin-from-path)
				delete_regex='\(^\|\n\?\n\)\([\t ]*#[^\n]*\n\)\?\s*'"$(print_export_path | tail -n 1 | head -c -1 | sed -e 's/[^^]/[&]/g' -e 's/\^/\\^/g')"'[\t ]*'
				sed -i -e ':s;$!{N;bs}' -e "\$s;$delete_regex;;" "$profile_path"
				;;
			delete-from-home-local-bin)
				find "$source_path" -type f \
				| while read -r script
				do
					rm -f '"%s"\n' "$target_path$(printf '%s' "$script" | cut -c$((${#source_path} + 1))-)"
				done
				;;
			remove-home-local-bin)
				rmdir -p "$target_path"
				;;
			*)
				printf 'fatal: Unknown task "%s"!' "$task" 1>&2
				exit 1
				;;
		esac
	done
}

do_the_install_thing() {
	gather_tasks
	if [ -n "$tasks" ]
	then
		show_tasks
		if ask_confirmation
		then
			run_tasks
			printf '\n'
			printf 'Installation finished successfully.\n'
			exit 0
		else
			printf 'Installation aborted\n'
			printf 'Nothing was changed in the system.\n'
			exit 2
		fi
	else
		if [ "$uninstall" = n ]
		then
			printf 'Nothing to do. Everything is up to date.\n'
		else
			printf 'Nothing to do. Everything is already removed.\n'
		fi
		exit 0
	fi
}

getopt_result="$(getopt -o'hu' --long='help,uninstall' -n"$(basename "$0")" -- "$@")"
eval set -- "$getopt_result"
uninstall=n
while true
do
	case "$1" in
	-h|--help)
		print_help
		exit 0
		;;
	-u|--uninstall)
		uninstall=y
		;;
	--)
		shift
		break
		;;
	esac
	shift
done
if [ $# -ne 0 ]
then
	printf 'Too many arguments. (Actually there should be none.)\n' 1>&2
	exit 1
fi

cd "$(dirname "$0")"

do_the_install_thing
