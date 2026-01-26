#!/bin/bash
# Script to unzst a spotify .zst file
# Usage: ./spotify-unzst-file.sh <input_file.zst> <output_file>
# Example: ./spotify-unzst-file.sh spotify_shows.jsonl.zst spotify_shows.jsonl
input_file=$1
output_file=${2:-${input_file%.zst}}
zstd -d "$input_file" -o "${output_file}"
echo "Decompressed $input_file to $output_file"
