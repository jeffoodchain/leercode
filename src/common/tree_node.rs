// Same definition LeetCode provides with the problem. Do not paste this file back to the site.
use std::cell::RefCell;
use std::collections::VecDeque;
use std::rc::Rc;

#[derive(Debug, PartialEq, Eq)]
pub struct TreeNode {
    pub val: i32,
    pub left: Option<Rc<RefCell<TreeNode>>>,
    pub right: Option<Rc<RefCell<TreeNode>>>,
}

impl TreeNode {
    #[inline]
    pub fn new(val: i32) -> Self {
        TreeNode {
            val,
            left: None,
            right: None,
        }
    }
}

pub type Tree = Option<Rc<RefCell<TreeNode>>>;

/// Build a tree from LeetCode's level-order notation; `None` is the problem's `null`.
/// `from_level_order(&[Some(1), None, Some(2), Some(3)])` is the problem's `[1,null,2,3]`.
pub fn from_level_order(vals: &[Option<i32>]) -> Tree {
    let mut iter = vals.iter().copied();
    let root = Rc::new(RefCell::new(TreeNode::new(iter.next()??)));
    let mut queue = VecDeque::from([Rc::clone(&root)]);
    while let Some(node) = queue.pop_front() {
        if let Some(Some(v)) = iter.next() {
            let child = Rc::new(RefCell::new(TreeNode::new(v)));
            node.borrow_mut().left = Some(Rc::clone(&child));
            queue.push_back(child);
        }
        if let Some(Some(v)) = iter.next() {
            let child = Rc::new(RefCell::new(TreeNode::new(v)));
            node.borrow_mut().right = Some(Rc::clone(&child));
            queue.push_back(child);
        }
    }
    Some(root)
}

/// Convert a tree back to level-order; trailing `None`s are dropped to match the problem's notation.
pub fn to_level_order(root: Tree) -> Vec<Option<i32>> {
    let mut out = Vec::new();
    let mut queue = VecDeque::from([root]);
    while let Some(node) = queue.pop_front() {
        match node {
            Some(n) => {
                let n = n.borrow();
                out.push(Some(n.val));
                queue.push_back(n.left.clone());
                queue.push_back(n.right.clone());
            }
            None => out.push(None),
        }
    }
    while out.last() == Some(&None) {
        out.pop();
    }
    out
}
