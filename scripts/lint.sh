#!/usr/bin/env sh
# usage: ./scripts/lint.sh src/p0001_two_sum.rs
# clippy pedantic + rustfmt --check; produces no binary.
set -eu
src=$1
out="${HOME}/.cache/leercode/lint"
mkdir -p "$out"
clippy-driver --edition 2024 --test -W clippy::pedantic --emit=metadata --out-dir "$out" "$src"
rustfmt --edition 2024 --check "$src"
