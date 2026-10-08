# leercode

LeetCode 練習，Rust 單檔 + rustc，不用 Cargo。

## 日常流程

```sh
./scripts/new.sh 206                   # 題號、slug 或題目 URL 都可以。從 LeetCode 抓題名、難度、tags、
                                       # Rust 簽名、範例，產生 src/p0206_reverse_linked_list.rs 並在下方表格加一列
./scripts/new.sh 206 reverse-linked-list   # 離線備用，不抓資料，只套模板
./run.sh src/p0001_two_sum.rs          # 編譯並跑該題全部測試
./run.sh src/p0001_two_sum.rs example  # 只跑名稱含 example 的測試
for f in src/p*.rs; do ./run.sh "$f"; done   # 跑全部，只重編有改動的題
./scripts/lint.sh src/p0001_two_sum.rs    # clippy pedantic + rustfmt --check
rustfmt src/p0001_two_sum.rs                 # 直接排版
```

- 編譯產物在 `~/.cache/leercode/`，repo 裡不會有 target。
- 解完把 `impl Solution` 整段貼回 LeetCode。
- `src/common/` 是 LeetCode 附帶的 `ListNode`、`TreeNode` 和測試用 helper，每題用 `mod common;` 引入。
- nvim 在 `nix develop` 內開，工具由 flake.nix 提供。

## 題目

| 編號 | 題目 | 難度 | Tags | 日期 | 做法 |
| --- | --- | --- | --- | --- | --- |
