#!/usr/bin/env sh

set -e

print_help() {
	printf '%s - An installation script for "git istash".\n' "$(basename "$0")"
	printf '    It copies files to the appropriate places and sets up the PATH variable if\n    needed. '
	printf     'With the "--uninstall" flag, it can also undo the changes it made.\n'
	printf '    (Hardcore terminal dwellers may prefer to do it their own way, but for\n    everyone else, this script should be more than sufficient.)\n'
	printf '\n'
	printf 'In a case you'\''re not sure what the script does, just run it!\n'
	printf 'It will list all the pending operations and ask for confirmation before making\nany changes to the system.\n'
	printf '\n'
	printf 'Usage: %s [<option>...]\n' "$(basename "$0")"
	printf '\n'
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help text and exit.\n'
	printf '\t--version\t- Print version information and exit.\n'
	printf '    -g, --global\t- Install for all users. (Requires root access rights.)\n'
	#shellcheck disable=SC2016
	printf '    -c, --custom-dir=X\t- Use a custom installation directory instead of\n\t\t\t  "$HOME/.local" or "/usr/local".\n'
	printf '    -C, --create-dir=X\t- Like "--custom-dir" but the directory is created if\n\t\t\t  it doesn'\''t exist.\n'
	printf '    -u, --uninstall\t- Undo all the changes that the script would have made\n\t\t\t  when run with the same flags (excluding this one).\n'
}

print_version() {
	printf 'installer version 1.0.0\n'
}

is_windows() {
	test "$OS" = 'Windows_NT'
}

check_root() {
	if { ! is_windows && [ "$(id -u)" -eq 0 ] ; } || { is_windows && net session 1>/dev/null 2>&1 ; }
	then
		is_root=y
		if is_windows && [ -n "$custom_dir" ]
		then
			printf 'error: Installation in a custom directory is not suppported on Windows.\n' 1>&2
			exit 1
		fi
		if [ "$global" = n ]
		then
			printf 'error: You'\''ve attempted to install / uninstall "git istash" for a single user using a root access.\n' 1>&2
			printf 'hint: Did you mean "install.sh --global"?\n' 1>&2
			exit 1
		fi
	else
		is_root=n
		if is_windows && [ "$global" = n ]
		then
			printf 'error: Installation without the option "--global" is not suppported on Windows.\n' 1>&2
			exit 1
		fi
		if [ "$global" = y ]
		then
			printf 'error: You'\''ve attempted to install / uninstall "git istash" for for all users without a root access.\n' 1>&2
			if is_windows
			then
				printf 'hint: Try to right click on the script and "run as administrator".\n' 1>&2
			else
				printf 'hint: Try to rerun the command with "sudo".\n' 1>&2
			fi
			exit 1
		fi
	fi
}

prepare_man() {
	if command -v man 1>/dev/null 2>&1
	then
		'./man-src/build.sh'
		if [ "$is_root" = y ]
		then
			#shellcheck disable=SC2012
			chown -R "$(ls -nd './man-src' | awk '{print $3":"$4}')" './share'
		fi
		man_present=y
	else
		man_present=n
	fi
}

make_target_path() { # source_path
	if [ -n "$custom_dir" ]
	then
		printf '%s' "$custom_dir"
	elif is_windows
	then
		printf '/usr'
	elif [ "$global" = y ]
	then
		printf '/usr/local'
	else
		printf '%s/.local' "$HOME"
	fi
	if [ -n "$1" ]
	then
		printf '/%s' "$1"
	fi
}

make_profile_path() {
	if [ "$global" = y ]
	then
		printf '/etc/profile'
	else
		printf '%s/.profile' "$HOME"
	fi
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

are_foreign_files_in_target() { # source_path
	source_path="$1"
	target_path="$(make_target_path "$source_path")"
	test "$(
			find "$target_path" -mindepth 1 \
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

are_foreign_files_in_root_target() {
	are_foreign_files_in_target 'bin' \
	|| are_foreign_files_in_target 'lib' \
	|| find "$(make_target_path '')" -mindepth 1 -maxdepth 1 | grep -qv '/\(bin\|lib\)$'
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
	if { [ -d "$(make_target_path "$1")" ] \
			&& {
				{ [ -z "$1" ] && ! are_foreign_files_in_root_target ; } \
				|| { [ -n "$1" ] && ! are_foreign_files_in_target "$1" ; }
			}
		} || [ "$debug" = y ]
	then
		printf 'rmdir_%s\n' "$1"
	fi
}
print_remove_directory_task() { # source_path
	printf 'The (now empty) directory "%s" will be removed.\n' "$(make_target_path "$1")"
}
execute_remove_directory_task() { # source_path
	rmdir "$(make_target_path "$1")"
}

make_copy_files_task() { # source_path
	find "$1" -mindepth 1 -maxdepth 1 \
	| while read -r f
	do
		if ! are_files_correct_in_target "$f" || [ "$debug" = y ]
		then
			printf 'copy_%s\n' "$f"
		fi
	done
}
print_copy_files_task() { # source_path
	printf 'The "%s" will be copied to "%s".\n' "$1" "$(make_target_path "$(dirname "$1")")"
}
execute_copy_files_task() { # source_path
	cp -fr "$1" "$(make_target_path "$(dirname "$1")")"
}

make_remove_files_tasks() { # source_path
	source_path="$1"
	target_path="$(make_target_path "$source_path")"
	find "$source_path" -mindepth 1 -maxdepth 1 \
	| while read -r f
	do
		if [ -e "$(switch_prefix "$source_path" "$target_path" "$f")" ] || [ "$debug" = y ]
		then
			if [ -f "$f" ]
			then
				printf 'delete_%s\n' "$f"
			else
				make_remove_files_tasks "$f"
				if ! are_foreign_files_in_target "$f"
				then
					printf 'rmdir_%s\n' "$f"
				fi
			fi
		fi
	done
}
print_remove_files_task() { # source_path
	printf 'The file "%s" will be deleted.\n' "$(make_target_path "$1")"
}
execute_remove_files_task() { # source_path
	rm -f '"%s"\n' "$(make_target_path "$1")"
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
	if { is_target_in_PATH "$1" && ! are_foreign_files_in_target "$1" ; } || [ "$debug" = y ]
	then
		printf 'remove-path_%s\n' "$1"
	fi
}
print_remove_from_profile_task() { # source_path
	printf 'The line in "%s" that appends "%s" to PATH will be removed.\n' "$(make_profile_path)" "$(make_target_path "$1")"
}
execute_remove_from_profile_task() { # source_path
	delete_regex='\(^\|\n\?\n\)\([\t ]*#[^\n]*\n\)\?\s*'"$(make_profile_insertion "$(make_target_path "$1")" | tail -n 1 | head -c -1 | sed -e 's/[^^]/[&]/g' -e 's/\^/\\^/g')"'[\t ]*'
	sed -i -e ':s ; $! { N ; bs }' -e "\$s;$delete_regex;;" "$(make_profile_path)"
}

gather_tasks() {
	tasks="$(
		if [ "$uninstall" = n ]
		then
			make_create_directory_task ''
			make_create_directory_task 'lib'
			make_copy_files_task 'lib'
			make_create_directory_task 'bin'
			make_copy_files_task 'bin'
			if ! is_windows ; then make_add_to_profile_task 'bin' ; fi
			if [ "$man_present" = y ]
			then
				make_create_directory_task 'share/man/man1'
				make_copy_files_task 'share/man/man1'
			fi
		else
			if [ "$man_present" = y ]
			then
				make_remove_files_tasks 'share/man'
				make_remove_directory_task 'share/man'
			fi
			if [ -n "$custom_dir" ] || [ "$global" = n ] ; then make_remove_from_profile_task 'bin' ; fi
			make_remove_files_tasks 'bin'
			if [ -n "$custom_dir" ] || [ "$global" = n ] ; then make_remove_directory_task 'bin' ; fi
			make_remove_files_tasks 'lib'
			if [ -n "$custom_dir" ] || [ "$global" = n ] ; then make_remove_directory_task 'lib' ; fi
			if { [ -n "$custom_dir" ] && [ "$create_custom_dir" = y ] ; } || { [ -z "$custom_dir" ] && [ "$global" = n ] ; }
			then
				make_remove_directory_task ''
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
	check_root
	prepare_man
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

getopt_result="$(getopt -o'hgc:C:u' --long='help,version,global,custom-dir:,create-dir:,uninstall,debug' -n"$(basename "$0")" -- "$@")"
eval set -- "$getopt_result"
global=n
uninstall=n
debug=n
custom_dir=''
set_custom_dir() { # dir
	if [ -n "$custom_dir" ]
	then
		printf 'error: Cannot specify multiple custom directories.\n' 1>&2
		exit 1
	fi
	if printf '%s' "$1" | grep -q '^/'
	then
		custom_dir="$1"
	else
		custom_dir="$(pwd)/$1"
	fi
}
create_custom_dir=n
while true
do
	case "$1" in
	-h|--help)
		print_help
		exit 0
		;;
	--version)
		print_version
		exit 0
		;;
	-g|--global)
		global=y
		;;
	-c|--custom-dir)
		shift
		if [ ! -d "$1" ]
		then
			printf 'fatal: "%s" doesn'\''t exist.\n' "$1" 1>&2
			printf 'hint: Did you mean "--create-dir"?\n' 1>&2
			exit 1
		fi
		set_custom_dir "$1"
		;;
	-C|--create-dir)
		shift
		set_custom_dir "$1"
		create_custom_dir=y
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
