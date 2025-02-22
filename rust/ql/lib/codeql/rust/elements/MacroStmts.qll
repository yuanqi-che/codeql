// generated by codegen, do not edit
/**
 * This module provides the public class `MacroStmts`.
 */

private import internal.MacroStmtsImpl
import codeql.rust.elements.AstNode
import codeql.rust.elements.Expr
import codeql.rust.elements.Stmt

/**
 * A sequence of statements generated by a `MacroCall`. For example:
 * ```rust
 * fn main() {
 *     println!("Hello, world!"); // This macro expands into a list of statements
 * }
 * ```
 */
final class MacroStmts = Impl::MacroStmts;
