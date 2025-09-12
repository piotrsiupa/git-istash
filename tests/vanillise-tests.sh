#!/usr/bin/env sh

set -eu

print_help() {
	printf 'This replaces all calls to the "istash" in tests with the classic "stash".\n'
	printf '(A lot of tests will fail, which is the point - specifically, the point is to\nsee how many tests would still pass.)\n'
	printf 'So, what'\''s all that for? Curiosity, mostly.\n'
	printf '\n'
	printf 'Usage: %s [-h | --help | -v | --version]\n' "$(basename "$0")"
	printf 'Options:\n'
	printf '    -h, --help\t\t- Print this help text.\n'
	printf '    -v, --version\t- Print a version information and exit.\n'
}

print_version() {
	printf 'test vanillisation script version 1.0.0\n'
}

getopt_short_options='hv'
getopt_long_options='help,version'
getopt_result="$(getopt -o"$getopt_short_options" --long="$getopt_long_options" -n"$(basename "$0")" -ssh -- "$@")"
eval set -- "$getopt_result"
while true
do
	case "$1" in
	-h|--help)
		print_help
		exit 0
		;;
	-v|--version)
		print_version
		exit 0
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
	printf 'Non-option arguments are not allowed!\n' 1>&2
	exit 1
fi

cd "$(dirname "$0")"

printf 'Warning: This script will irreversibly "break" all the test scripts!\n' 1>&2
printf '(This can be reversed only manually or using Git commands like "restore".)\n' 1>&2
printf 'Do you want to continue? ' 1>&2
if ! head -n 1 | grep -Exiq 'y(es)?'
then
	exit 2
fi

#shellcheck disable=SC2016
./list.sh | tr '\n' '\0' \
| xargs -0 -- sed -E -i \
	-e 's/\<istash(\s+(\$APPLY_OPERATION\>|"\$APPLY_OPERATION"|apply\>|pop\>|(['\''"](apply|pop)['\''"])))/stash\1 --index/' \
	-e 's/\<istash\>/stash/'
