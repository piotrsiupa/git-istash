#!/usr/bin/env sh

set -e

add_line_numbers_to_script() ( # script_file
	comment_regex='#[^]*'
	end_of_command_regex='\s*[;]|\s*'"$comment_regex"
	parameter_expansion_regex='\$\{[^}]+\}'
	single_quoted_string_regex="'[^']*'"
	not_very_special_things_regex='([-+_.!=/[:alnum:][:space:]]|\[|\]|[<>]&?|\\.|(\||\|\||&&)[[:space:]]*|\(\)|'"$parameter_expansion_regex|$single_quoted_string_regex"')+'
	start_double_quoted_string_regex="\""
	double_quoted_string_insides_regex='([^$\\"]|\$[^(]|\\.|'"$parameter_expansion_regex"')+'
	end_double_quoted_string_regex='"'
	start_command_substitution_regex='\$\('
	start_block_regex='\$?\(|\{'
	end_block_regex='[)}]'
	start_branching_instruction='\s*((el)?if|for\s+\w+\s+in|while)\>'
	end_branching_instruction='(\s|)*(then|do)\>'
	start_case_regex='\s*case\>.+\<in\s*[;]|\s*;;'
	end_case_regex='(\s|)*([^)]*\)|esac)'
	process_regex() { # regex
		printf '%s' "$script" \
		| sed -n -E 's/^('"$1"').*$/`\1`/ p' \
		| grep '.'
	}
	push_state() { # new_state
		state_stack="$state_stack$1"
	}
	pop_state() {
		state_stack="$(printf '%s' "$state_stack" | sed 's/.$//')"
	}
	# States:
	# - N - normal instructions
	# - S - start of command
	# - B - branching instruction condition
	# - E - end of branching instruction condition
	# - C - case
	# - D - double-quoted string
	script="$(cat "$1" | sed 's//___actual_bell___/g' | tr '\n' '')"
	state_stack=NS
	instruction='``'
	while true
	do
		printf '%s' "$instruction" | tr '' '\n' | sed -E -e '1 s/^`//' -e '$ s/`$//' -e 's/___actual_bell___//g'
		script="$(printf '%s' "$script" | tail -c+$((${#instruction} - 1)))"
		test -z "$script" && break
		current_state="$(printf '%s' "$state_stack" | tail -c1)"
		case "$current_state" in
		S)	printf ' printf '\''%%i\\n'\'' $LINENO 1>&2 ; '
			pop_state
			instruction='``'
			continue
			;;
		N|B)	instruction="$(process_regex "$start_branching_instruction")" &&
			{
				push_state B
				continue
			}
			instruction="$(process_regex "$start_case_regex")" &&
			{
				push_state C
				continue
			}
			instruction="$(process_regex "$end_of_command_regex")" &&
			{
				if [ "$current_state" = B ]
				then
					pop_state
					push_state E
				else
					push_state S
				fi
				continue
			}
			instruction="$(process_regex "$not_very_special_things_regex")" &&
				continue
			instruction="$(process_regex "$start_block_regex")" &&
			{
				push_state N
				continue
			}
			instruction="$(process_regex "$end_block_regex")" &&
			{
				pop_state
				continue
			}
			instruction="$(process_regex "$start_double_quoted_string_regex")" &&
			{
				push_state D
				continue
			}
			;;
		E)	instruction="$(process_regex "$end_branching_instruction")" &&
			{
				pop_state
				continue
			}
			;;
		C)	instruction="$(process_regex "$end_case_regex")" &&
			{
				pop_state
				if printf '%s' "$instruction" | grep -qE '\)$'
				then
					push_state S
				fi
				continue
			}
			;;
		D)	instruction="$(process_regex "$double_quoted_string_insides_regex")" &&
				continue
			instruction="$(process_regex "$end_double_quoted_string_regex")" &&
			{
				pop_state
				continue
			}
			instruction="$(process_regex "$start_command_substitution_regex")" &&
			{
				push_state N
				continue
			}
			;;
		esac
		printf '\nCannot process the script to add line information to it! (mode stack: "%s")\n' "$state_stack" 1>&2
		printf '"%s"...\n' "$(printf '%s' "$script" | sed 's/___actual_bell___//g' | head -n4 | head -c50)" 1>&2
		return 1
	done
	printf '\n'
)

add_line_numbers_to_script "$1"
