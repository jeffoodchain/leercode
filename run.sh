#!/usr/bin/env sh
# usage: ./run.sh src/p0001_two_sum.rs [test_name_filter]
set -eu
src=$1; shift
out="${HOME}/.cache/leercode"
mkdir -p "$out"
bin="$out/$(basename "$src" .rs)"

if [ ! -x "$bin" ] || [ "$src" -nt "$bin" ]; then
  rustc --edition 2024 --test -g "$src" -o "$bin"
fi
exec "$bin" "$@"
