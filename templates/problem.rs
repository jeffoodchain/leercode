// {{NUM}}. {{TITLE}} — {{URL}}
// difficulty: {{DIFFICULTY}}   tags: {{TAGS}}   approach:
//
// Shared types live in src/common/: ListNode / from_vec / to_vec, TreeNode / from_level_order / to_level_order
mod common;
{{USES}}
pub struct Solution;

{{SNIPPET}}

#[cfg(test)]
mod tests {
    use super::*;
{{TESTS}}
}
