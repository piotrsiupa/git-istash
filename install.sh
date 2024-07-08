#!/usr/bin/env sh

set -e

print_help() {
	printf '%s - An installation script for "git istash".\n' "$(basename "$0")"
	#shellcheck disable=SC2016
	printf '    It copies files to the appropriate places and sets up the PATH variable if\n    needed. '
	printf     'With the flag "--uninstall", it can also undo the changes it makes.\n'
	printf '    (Hardcore terminal dwellers will may want to do it their own way but for\n    everyone else this script should be more than good enough.)\n'
	printf '\n'
	printf 'usage: %s [<option>...]\n' "$(basename "$0")"
	printf '\n'
	printf 'options:\n'
	printf '    -h, --help\t\t- Show this help text.\n'
	printf '    -u, --uninstall\t- Undo all the changes that the install script would\n\t\t\t  made without this flag.\n'
}

make_target_path() { # source_path
	printf '%s/.local/%s' "$HOME" "$1"
}

make_profile_path() {
	printf '%s/.profile' "$HOME"
}

switch_prefix() { # old_prefix new_prefix string
	printf '%s' "$2"
	printf '%s' "$3" | cut -c$((${#1} + 1))-
}

are_files_correct_in_target() { # source_path
	source_path="$1"
	target_path="$(make_target_path "$source_path")"
	test "$(
			find "$source_path" -type f \
			| while read -r f
			do
				if ! cmp -s "$f" "$(switch_prefix "$source_path" "$target_path" "$f")"
				then
					printf 'x'
					break
				fi
			done
		)" != 'x'
}

are_knows_files_in_target() { # source_path
	source_path="$1"
	target_path="$(make_target_path "$source_path")"
	test "$(
			find "$source_path" -type f \
			| while read -r f
			do
				if [ -e "$(switch_prefix "$source_path" "$target_path" "$f")" ]
				then
					printf 'x'
					break
				fi
			done
		)" = 'x'
}

are_foreign_files_in_target() { # source_path
	source_path="$1"
	target_path="$(make_target_path "$source_path")"
	test "$(
			find "$target_path" -type f \
			| while read -r f
			do
				if [ ! -e "$(switch_prefix "$target_path" "$source_path" "$f")" ]
				then
					printf 'x'
					break
				fi
			done
		)" = 'x'
}

is_target_in_PATH() { # source_path
	printf '%s' "$PATH" | tr ':' '\n' | grep -qFx "$(make_target_path "$1")"
}

make_profile_insertion() { # path
	printf '\n'
	printf '# add user'\''s private bin directory to PATH\n'
	#shellcheck disable=SC2016
	printf 'export PATH="%s:$PATH"\n' "$1"
}

get_task_path() { # task
	printf '%s' "$1" | cut -d_ -f2-
}

make_create_directory_task() { # source_path
	source_path="$1"
	target_path="$(make_target_path "$source_path")"
	if [ ! -e "$target_path" ] || [ "$debug" = y ]
	then
		printf 'mkdir_%s\n' "$source_path"
	elif [ ! -d "$target_path" ]
	then
		printf 'fatal: "%s" already exists but it'\''s not a directory.\n' "$target_path" 1>&2
		return 1
	fi
}
print_create_directory_task() { # source_path
	printf 'A directory "%s" will be created.\n' "$(make_target_path "$1")"
}
execute_create_directory_task() { # source_path
	mkdir -p "$(make_target_path "$1")"
}

make_remove_directory_task() { # source_path
	if ! are_foreign_files_in_target "$1" || [ "$debug" = y ]
	then
		printf 'rmdir_%s\n' "$1"
	fi
}
print_remove_directory_task() { # source_path
	printf 'The (now empty) directory "%s" will be removed.\n' "$(make_target_path "$1")"
}
execute_remove_directory_task() { # source_path
	rmdir -p "$(make_target_path "$1")"
}

make_copy_files_task() { # source_path
	if ! are_files_correct_in_target "$1" || [ "$debug" = y ]
	then
		printf 'copy_%s\n' "$1"
	fi
}
print_copy_files_task() { # source_path
	printf 'The contents of the directory "%s" will be copied to "%s".\n' "$1" "$(make_target_path "$1")"
}
execute_copy_files_task() { # source_path
	cp -fr "$1"/* "$(make_target_path "$1")"
}

make_remove_files_task() { # source_path
	if are_knows_files_in_target "$1" || [ "$debug" = y ]
	then
		printf 'delete_%s\n' "$1"
	fi
}
print_remove_files_task() { # source_path
	printf 'The contents of the directory "%s" will be deleted from "%s".\n' "$1" "$(make_target_path "$1")"
}
execute_remove_files_task() { # source_path
	source_path="$1"
	target_path="$(make_target_path "$source_path")"
	find "$source_path" -mindepth 1 -maxdepth 1 \
	| while read -r f
	do
		rm -rf '"%s"\n' "$(switch_prefix "$source_path" "$target_path" "$f")"
	done
}

make_add_to_profile_task() { # source_path
	if ! is_target_in_PATH "$1" || [ "$debug" = y ]
	then
		printf 'add-path_%s\n' "$1"
	fi
}
print_add_to_profile_task() { # source_path
	printf '"%s" will be added to PATH by appending the "%s".\n' "$(make_target_path "$1")" "$(make_profile_path)"
}
execute_add_to_profile_task() { # source_path
	make_profile_insertion "$(make_target_path "$1")" >>"$(make_profile_path)"
}

make_remove_from_profile_task() { # source_path
	if ( is_target_in_PATH "$1" && ! are_foreign_files_in_target "$1" ) || [ "$debug" = y ]
	then
		printf 'remove-path_%s\n' "$1"
	fi
}
print_remove_from_profile_task() { # source_path
	printf 'The line in "%s" that appends "%s" to PATH will be removed.\n' "$(make_profile_path)" "$(make_target_path "$1")"
}
execute_remove_from_profile_task() { # source_path
	delete_regex='\(^\|\n\?\n\)\([\t ]*#[^\n]*\n\)\?\s*'"$(make_profile_insertion "$(make_target_path "$1")" | tail -n 1 | head -c -1 | sed -e 's/[^^]/[&]/g' -e 's/\^/\\^/g')"'[\t ]*'
	sed -i -e ':s;$!{N;bs}' -e "\$s;$delete_regex;;" "$(make_profile_path)"
}

gather_tasks() {
	tasks="$(
		if [ "$uninstall" = n ]
		then
			make_create_directory_task 'lib'
			make_copy_files_task 'lib'
			make_create_directory_task 'bin'
			make_copy_files_task 'bin'
			make_add_to_profile_task 'bin'
		else
			make_remove_from_profile_task 'bin'
			make_remove_files_task 'bin'
			make_remove_directory_task 'bin'
			make_remove_files_task 'lib'
			make_remove_directory_task 'lib'
		fi
	)"
}

show_tasks() {
	printf 'Installing "git-istash" for the current user (%s)...\n' "$(id -nu)"
	printf 'Operations that are to be performed:\n'
	printf '%s\n' "$tasks" \
	| while read -r task
	do
		printf ' - '
		source_path="$(get_task_path "$task")"
		case "$task" in
			mkdir_*) print_create_directory_task "$source_path" ;;
			copy_*) print_copy_files_task "$source_path" ;;
			add-path_*) print_add_to_profile_task "$source_path" ;;
			rmdir_*) print_remove_directory_task "$source_path" ;;
			delete_*) print_remove_files_task "$source_path" ;;
			remove-path_*) print_remove_from_profile_task "$source_path" ;;
			*) printf 'fatal: Unknown task "%s".' "$task" 1>&2 ; exit 1 ;;
		esac
	done
	if [ "$debug" = y ]
	then
		printf '\nWARNING: This is a debug mode. Tasks were not validated!\n(All of them were indiscriminately put on the list above.)\n' 1>&2
	fi
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

run_tasks() {
	printf '%s\n' "$tasks" \
	| while read -r task
	do
		source_path="$(get_task_path "$task")"
		case "$task" in
			mkdir_*) execute_create_directory_task "$source_path" ;;
			copy_*) execute_copy_files_task "$source_path" ;;
			add-path_*) execute_add_to_profile_task "$source_path" ;;
			rmdir_*) execute_remove_directory_task "$source_path" ;;
			delete_*) execute_remove_files_task "$source_path" ;;
			remove-path_*) execute_remove_from_profile_task "$source_path" ;;
			*) printf 'fatal: Unknown task "%s".' "$task" 1>&2 ; exit 1 ;;
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
			if [ "$uninstall" = n ]
			then
				printf 'Installation finished successfully.\n'
			else
				printf 'Uninstall finished successfully.\n'
			fi
			if printf '%s\n' "$tasks" | grep -q '^\(add\|remove\)-path_'
			then
				printf '\nPATH was modified. Restart the session to apply those changes.\n'
			fi
			exit 0
		else
			if [ "$uninstall" = n ]
			then
				printf 'Installation aborted\n'
			else
				printf 'Uninstall aborted\n'
			fi
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

getopt_result="$(getopt -o'hu' --long='help,uninstall,debug' -n"$(basename "$0")" -- "$@")"
eval set -- "$getopt_result"
uninstall=n
debug=n
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
	--debug)
		debug=y
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
