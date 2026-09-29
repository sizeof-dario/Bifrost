#!/usr/bin/env bash
set -e

# Some ANSI escape codes for better output
ANSI_DEFAULT="\e[0m"
ANSI_BOLD="\e[1m"
ANSI_RED="\e[31m"

DEPENDENCIES=(bzip2 cmp gcc g++ makeinfo nasm tar wget xz)
missing=0
list=()
for tool in "${DEPENDENCIES[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
                list+=("$tool")
                missing=1  
        fi
done

if ((missing)); then
        echo -e \
"${ANSI_RED}You need to resolve the following dependencies:${ANSI_DEFAULT}"
        echo -e "\t${ANSI_BOLD}${list[@]}${ANSI_DEFAULT}"
        exit 1        
fi
