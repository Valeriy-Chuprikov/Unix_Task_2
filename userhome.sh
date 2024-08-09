#!/bin/bash

file="/etc/passwd"
user="$USER"
f_small=0
user_changed=0
file_changed=0

if [[ $# -gt 3 ]]
then
	echo "Ошибка: слишком много аргументов" >&2
	exit 1
fi

for arg in "$@"
do
	if [[ $f_small -eq 1 ]]
	then
		if [[ "$arg" == -* ]]
		then
			file="./$arg"
		else
			file="$arg"
		fi
		if [[ -f "$file" ]]
		then
			f_small=0
			file_changed=1
		else
			echo "Ошибка: файл '$file' не существует"
			exit 6
		fi
		continue
	fi

	case "$arg" in
		-f)
			if [[ $file_changed -eq 0 ]]
			then
				f_small=1
			else
				echo "Ошибка: дважды указана опция -f" >&2
				exit 7
			fi
			;;
		-*)
			echo "Ошибка: опции $arg не существует" >&2
			exit 2
			;;

		*)
			if [[ $user_changed -eq 0 ]]
			then
				if id "$arg" >/dev/null 2>&1
				then
					user="$arg"
					user_changed=1
				else
					echo "Ошибка: пользователя с именем '$arg' не удаётся найти"
					exit 5
				fi
			else
				echo "Ошибка: аргумент user уже был введён" >&2
				exit 3
			fi
			;;
	esac
done

if [[ $f_small -eq 1 ]]
then
	echo "Ошибка: файл пароля не указан"
	exit 4
fi

echo `cut -d ':' -f 1,6 "$file" | grep -w "$user"":" | cut -d ':' -f 2`
exit 0

