// generated by codegen, remove this comment if you wish to edit this file
/**
 * This module provides a hand-modifiable wrapper around the generated class `MatchExpr`.
 *
 * INTERNAL: Do not use.
 */

private import codeql.rust.generated.MatchExpr

/**
 * INTERNAL: This module contains the customizable definition of `MatchExpr` and should not
 * be referenced directly.
 */
module Impl {
  /**
   * A match expression. For example:
   * ```
   * match x {
   *     Option::Some(y) => y,
   *     Option::None => 0,
   * }
   * ```
   * ```
   * match x {
   *     Some(y) if y != 0 => 1 / y,
   *     _ => 0,
   * }
   * ```
   */
  class MatchExpr extends Generated::MatchExpr { }
}
