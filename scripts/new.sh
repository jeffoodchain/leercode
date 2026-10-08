#!/usr/bin/env sh
# Create a new problem from a number, slug, or problem URL. Fetches title, difficulty,
# tags, the Rust signature, and the examples from LeetCode.
#   ./scripts/new.sh 206
#   ./scripts/new.sh reverse-linked-list
#   ./scripts/new.sh https://leetcode.com/problems/reverse-linked-list/description/
# Offline fallback (no fetch): ./scripts/new.sh 206 reverse-linked-list
set -eu
[ $# -ge 1 ] || { echo "usage: $0 <number|slug|url> [slug]" >&2; exit 2; }
root=$(cd "$(dirname "$0")/.." && pwd)
exec python3 -I - "$root" "$@" <<'PY'
import json, re, sys, urllib.request, datetime, pathlib

root = pathlib.Path(sys.argv[1]); args = sys.argv[2:]
GQL = "https://leetcode.com/graphql"

def gql(query, variables, referer):
    req = urllib.request.Request(
        GQL, data=json.dumps({"query": query, "variables": variables}).encode(),
        headers={"Content-Type": "application/json", "User-Agent": "Mozilla/5.0", "Referer": referer})
    with urllib.request.urlopen(req, timeout=20) as r:
        body = json.load(r)
    if "errors" in body:
        sys.exit("leetcode graphql error: " + json.dumps(body["errors"])[:300])
    return body["data"]

def slug_from_number(n):
    data = gql("""query q($f: QuestionListFilterInput) {
        questionList(categorySlug: "", limit: 10, skip: 0, filters: $f) {
            data { questionFrontendId titleSlug } } }""",
        {"f": {"searchKeywords": str(n)}}, "https://leetcode.com/problemset/")
    for q in data["questionList"]["data"]:
        if q["questionFrontendId"] == str(n):
            return q["titleSlug"]
    sys.exit(f"no problem with number {n}")

def fetch(slug):
    data = gql("""query q($slug: String!) { question(titleSlug: $slug) {
        questionFrontendId title titleSlug difficulty content metaData exampleTestcaseList
        topicTags { slug } codeSnippets { langSlug code } } }""",
        {"slug": slug}, f"https://leetcode.com/problems/{slug}/")
    q = data["question"]
    if q is None:
        sys.exit(f"no problem with slug {slug}")
    return q

def rust_snippet(q):
    for s in q["codeSnippets"]:
        if s["langSlug"] == "rust":
            code = s["code"]
            # Drop the commented-out ListNode/TreeNode definitions; we use common/ instead.
            code = "\n".join(l for l in code.splitlines() if not l.startswith("//"))
            # Fill empty function bodies with todo!()
            code = re.sub(r"\{\n[ \t]*\n([ \t]*)\}", r"{\n\1    todo!()\n\1}", code)
            return code.strip()
    sys.exit("this problem has no Rust snippet")

def examples(q):
    params = [p["name"] for p in json.loads(q["metaData"]).get("params", [])]
    outputs = re.findall(r"<strong>Output:</strong>\s*(.*?)\s*\n", q["content"] or "")
    lines = []
    for i, case in enumerate(q["exampleTestcaseList"], 1):
        vals = case.split("\n")
        inp = ", ".join(f"{n} = {v}" for n, v in zip(params, vals)) if len(params) == len(vals) else case.replace("\n", " ; ")
        out = outputs[i - 1] if i - 1 < len(outputs) else "?"
        lines += ["", "    #[test]", f"    fn example_{i}() {{",
                  f"        // input: {inp}", f"        // output: {out}",
                  '        todo!("write the assert_eq!")', "    }"]
    if not lines:
        lines = ["", "    #[test]", "    fn example_1() {", '        todo!("write the assert_eq!")', "    }"]
    return "\n".join(lines)

# ---- parse arguments ----
if len(args) == 2:                       # offline mode: <number> <slug>
    n = args[0].lstrip("0") or "0"
    if not n.isdigit(): sys.exit(f"number must be digits: {args[0]}")
    slug = args[1]
    v = dict(num=n, title=" ".join(w.capitalize() for w in slug.split("-")), slug=slug,
             url=f"https://leetcode.com/problems/{slug}/", difficulty="", tags="", uses="",
             snippet="impl Solution {\n    pub fn solve() {\n        todo!()\n    }\n}",
             tests='\n    #[test]\n    fn example_1() {\n        todo!("write the assert_eq!")\n    }')
else:
    a = args[0]
    m = re.search(r"/problems/([^/?#]+)", a)
    if m:            slug = m.group(1)
    elif a.isdigit(): slug = slug_from_number(a.lstrip("0") or "0")
    else:             slug = a
    q = fetch(slug)
    snippet = rust_snippet(q)
    # Tree problems ship `use std::rc::Rc;` etc. in the snippet; hoist them to the file header.
    uses = [l for l in snippet.splitlines() if l.startswith("use ")]
    snippet = "\n".join(l for l in snippet.splitlines() if not l.startswith("use ")).strip()
    if "ListNode" in snippet:
        uses.append("#[allow(unused_imports)]\nuse common::list_node::{ListNode, from_vec, to_vec};")
    if "TreeNode" in snippet:
        uses.append("#[allow(unused_imports)]\nuse common::tree_node::{TreeNode, Tree, from_level_order, to_level_order};")
    v = dict(num=q["questionFrontendId"], title=q["title"], slug=q["titleSlug"],
             url=f"https://leetcode.com/problems/{q['titleSlug']}/", difficulty=q["difficulty"],
             tags=", ".join(t["slug"] for t in q["topicTags"]),
             uses="".join(u + "\n" for u in uses), snippet=snippet, tests=examples(q))

# ---- write the file ----
name = f"p{int(v['num']):04d}_{v['slug'].replace('-', '_')}.rs"
path = root / "src" / name
if path.exists():
    sys.exit(f"already exists: {path}")
tpl = (root / "templates" / "problem.rs").read_text()
for k, val in v.items():
    tpl = tpl.replace("{{" + k.upper() + "}}", val)
path.write_text(tpl)
with (root / "README.md").open("a") as f:
    f.write(f"| {int(v['num']):04d} | [{v['title']}](src/{name}) | {v['difficulty']} | {v['tags']} | {datetime.date.today()} |  |\n")
print(path)
PY
