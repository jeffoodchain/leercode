// Same definition LeetCode provides with the problem. Do not paste this file back to the site.
#[derive(PartialEq, Eq, Clone, Debug)]
pub struct ListNode {
    pub val: i32,
    pub next: Option<Box<ListNode>>,
}

impl ListNode {
    #[inline]
    pub fn new(val: i32) -> Self {
        ListNode { next: None, val }
    }
}

/// `from_vec(&[1, 2, 3])` -> 1 -> 2 -> 3
pub fn from_vec(vals: &[i32]) -> Option<Box<ListNode>> {
    let mut head = None;
    for &val in vals.iter().rev() {
        head = Some(Box::new(ListNode { val, next: head }));
    }
    head
}

/// 1 -> 2 -> 3 -> `vec![1, 2, 3]`
pub fn to_vec(mut node: Option<Box<ListNode>>) -> Vec<i32> {
    let mut out = Vec::new();
    while let Some(n) = node {
        out.push(n.val);
        node = n.next;
    }
    out
}
