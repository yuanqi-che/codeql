// generated by codegen, remove this comment if you wish to edit this file
/**
 * This module provides a hand-modifiable wrapper around the generated class `UnsafeBlockExpr`.
 *
 * INTERNAL: Do not use.
 */

private import codeql.rust.generated.UnsafeBlockExpr

/**
 * INTERNAL: This module contains the customizable definition of `UnsafeBlockExpr` and should not
 * be referenced directly.
 */
module Impl {
  /**
   * An unsafe block expression. For example:
   * ```
   * let layout = unsafe {
   *     let x = 42;
   *     Layout::from_size_align_unchecked(size, align)
   * };
   * ```
   */
  class UnsafeBlockExpr extends Generated::UnsafeBlockExpr { }
}
