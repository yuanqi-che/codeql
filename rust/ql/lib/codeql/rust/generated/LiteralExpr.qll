// generated by codegen, do not edit
/**
 * This module provides the generated definition of `LiteralExpr`.
 * INTERNAL: Do not import directly.
 */

private import codeql.rust.generated.Synth
private import codeql.rust.generated.Raw
import codeql.rust.elements.ExprImpl::Impl as ExprImpl

/**
 * INTERNAL: This module contains the fully generated definition of `LiteralExpr` and should not
 * be referenced directly.
 */
module Generated {
  /**
   * A literal expression. For example:
   * ```
   * 42;
   * 42.0;
   * "Hello, world!";
   * b"Hello, world!";
   * 'x';
   * b'x';
   * r"Hello, world!";
   * true;
   * INTERNAL: Do not reference the `Generated::LiteralExpr` class directly.
   * Use the subclass `LiteralExpr`, where the following predicates are available.
   */
  class LiteralExpr extends Synth::TLiteralExpr, ExprImpl::Expr {
    override string getAPrimaryQlClass() { result = "LiteralExpr" }
  }
}
