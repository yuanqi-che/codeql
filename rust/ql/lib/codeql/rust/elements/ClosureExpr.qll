// generated by codegen, do not edit
/**
 * This module provides the public class `ClosureExpr`.
 */

private import internal.ClosureExprImpl
import codeql.rust.elements.Callable
import codeql.rust.elements.ClosureBinder
import codeql.rust.elements.Expr
import codeql.rust.elements.RetTypeRef

/**
 * A closure expression. For example:
 * ```rust
 * |x| x + 1;
 * move |x: i32| -> i32 { x + 1 };
 * async |x: i32, y| x + y;
 *  #[coroutine]
 * |x| yield x;
 *  #[coroutine]
 *  static |x| yield x;
 * ```
 */
final class ClosureExpr = Impl::ClosureExpr;
