#!/usr/#!/usr/bin/env bash
# -*- coding: utf-8 -*-

toolbox="/mnt/c/Users/JeanM/AppData/Local/JetBrains/Toolbox/apps"
arrVar=()


for bin in $(find "$toolbox" -maxdepth 4 -type d -name bin); do
	pushd "$bin" &> /dev/null
	ls -1 | grep -E "64.exe$" | while read -r exe; do
		echo "$bin/$exe"
		arrVar+=("$bin/$exe")
	done
	popd &> /dev/null
done


for value in "${arrVar[@]}"; do
     echo "$value"
done
