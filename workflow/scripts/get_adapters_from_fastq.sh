#!/usr/bin/bash

# Report adapters in PE fastq
# Usage: get_adapters_from_fastq [-h] R1.fastg.gz R1.fastg.gz
# Last modified: 2026-04-17 11:08:16
# Sign: JN

if [ $# -gt 2 ] || [ ! "$1" ] || [ "$1" == '-h' ]; then
  echo "Usage: $(basename "$0") R1.fastg.gz R1.fastg.gz"
  exit 1
fi

command -v fastp > /dev/null 2>&1 || { echo >&2 "Error: fastp not found."; exit 1; }

if [[ -n "$1" && -n "$2" ]] ; then
  in1=$1
  in2=$2
  for f in "$in1" "$in2" ; do
    if [ ! -e "${f}" ]; then
      echo "Error: can not find ${f}"
      exit 1
    fi
  done
else
  echo "Usage: $0 R1.fastg.gz R1.fastg.gz"
  exit 1
fi

tmp_files=()
tmp_out1='__tmp_REMOVE_ME_IF_YOU_SEE_ME.out1.fg' && tmp_files+=("$tmp_out1")
tmp_out2='__tmp_REMOVE_ME_IF_YOU_SEE_ME.out2.fq' && tmp_files+=("$tmp_out2")
tmp_html='__tmp_REMOVE_ME_IF_YOU_SEE_ME.report.html' && tmp_files+=("$tmp_html")
tmp_json='__tmp_REMOVE_ME_IF_YOU_SEE_ME.report.json' && tmp_files+=("$tmp_json")

>&2 echo "Searching for adapters using fastp"

fastp -i "$in1" -I "$in2" \
  -o "$tmp_out1" -O "$tmp_out2" \
  --detect_adapter_for_pe \
  -h "$tmp_html" -j "$tmp_json" \
  2>&1 | \
  grep -A 3 'Detecting adapter sequence' | \
  grep -v 'Detecting adapter sequence'

rm "${tmp_files[@]}"
