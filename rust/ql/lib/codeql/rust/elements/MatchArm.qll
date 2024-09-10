// generated by codegen, remove this comment if you wish to edit this file
/**
 * This module provides a hand-modifiable wrapper around the generated class `MatchArm`.
 */

private import codeql.rust.generated.MatchArm

/**
 * A match arm. For example:
 * ```
 * match x {
 *     Some(y) => y,
 *     None => 0,
 * }
 * ```
 * ```
 * match x {
 *     Some(y) if y != 0 => 1 / y,
 *     _ => 0,
 * }
 * ```
 */
class MatchArm extends Generated::MatchArm { }
