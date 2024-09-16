// generated by codegen, do not edit
/**
 * This module provides the public class `UnsafeBlockExpr`.
 */

private import UnsafeBlockExprImpl
import codeql.rust.elements.BlockExprBase

/**
 * An unsafe block expression. For example:
 * ```
 * let layout = unsafe {
 *     let x = 42;
 *     Layout::from_size_align_unchecked(size, align)
 * };
 * ```
 */
final class UnsafeBlockExpr = Impl::UnsafeBlockExpr;
