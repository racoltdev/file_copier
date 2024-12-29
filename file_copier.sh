#! /usr/bin/bash

required_args=2
#exclude_dirs="-type f"
exclude_dirs="-type d ( -wholename /dev/null"
verbose=false
src=""
dest=""
while [ $# -gt 0 ]; do
	case $1 in
		-e|--exclude)
			exclude_dirs+=" -o -name $2"
			shift
			shift
			;;
		-v|--verbose)
			verbose=true
			shift
			;;
		*)
			if [[ -z  "$src" ]]; then
				src=$1
			elif [[ -z "$dest" ]] then
				dest=$1
			else
				echo "Too many arguments!"
				exit
			fi
			shift
			;;
	esac
done
exclude_dirs+=" ) -prune"
files="$(find "$src" $exclude_dirs -o -type f -print)"

for file in $files; do
	# Remove first two characters "./"
	file=${file:2}
	if [ $verbose = true ]; then
		echo "Copying: ""$file"
	fi

	# Separate the $file string by "/" delimeter
	IFS="/" read -ra split_name <<< "$file"
	# Remove last item to get the dir name
	# [@] means act on all elements of the array
	# #split_name[@] is the number of items in split_name
	dir="${split_name[@]::${#split_name[@]}-1}"

	# Sub " " separators back for "/"
	dir=$(echo $dir | tr " " "/")

	if [ -n "$dir" ]; then
		mkdir -p "$dest""$dir"  && \
		cp "$file" "$dest""$dir"
	else
		cp "$file" "$dest"
	fi

done
echo "Done!"
