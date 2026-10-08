# leercode

LeetCode practice in Rust. One file per problem, compiled with plain `rustc`. No Cargo.

## Daily workflow

```sh
./scripts/new.sh 206                   # Number, slug, or problem URL. Fetches title, difficulty, tags,
                                       # Rust signature, and examples from LeetCode; writes
                                       # src/p0206_reverse_linked_list.rs and adds a row to the table below.
./scripts/new.sh 206 reverse-linked-list   # Offline fallback: template only, no fetch.
./run.sh src/p0001_two_sum.rs          # Compile and run all tests for that problem.
./run.sh src/p0001_two_sum.rs example  # Run only tests whose name contains "example".
for f in src/p*.rs; do ./run.sh "$f"; done   # Run everything; only changed files are recompiled.
./scripts/lint.sh src/p0001_two_sum.rs    # clippy pedantic + rustfmt --check
rustfmt src/p0001_two_sum.rs                 # Format in place.
```

- Build output goes to `~/.cache/leercode/`, so the repo never contains a target directory.
- When a problem passes, paste the `impl Solution` block back into LeetCode.
- `src/common/` holds the `ListNode` and `TreeNode` types LeetCode provides, plus test helpers. Each problem pulls them in with `mod common;`.
- Open nvim inside `nix develop`; flake.nix provides the toolchain.

## Problems

| # | Problem | Difficulty | Tags | Date | Approach |
| --- | --- | --- | --- | --- | --- |
