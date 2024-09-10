// generated by codegen
/**
 * This module provides the generated definition of `PathExpr`.
 * INTERNAL: Do not import directly.
 */

private import codeql.rust.generated.Synth
private import codeql.rust.generated.Raw
import codeql.rust.elements.Expr
import codeql.rust.elements.Unimplemented

/**
 * INTERNAL: This module contains the fully generated definition of `PathExpr` and should not
 * be referenced directly.
 */
module Generated {
  /**
   * A path expression. For example:
   * ```
   * let x = variable;
   * let x = foo::bar;
   * let y = <T>::foo;
   * let z = <Type as Trait>::foo;
   * ```
   * INTERNAL: Do not reference the `Generated::PathExpr` class directly.
   * Use the subclass `PathExpr`, where the following predicates are available.
   */
  class PathExpr extends Synth::TPathExpr, Expr {
    override string getAPrimaryQlClass() { result = "PathExpr" }

    /**
     * Gets the path of this path expression.
     */
    Unimplemented getPath() {
      result =
        Synth::convertUnimplementedFromRaw(Synth::convertPathExprToRaw(this)
              .(Raw::PathExpr)
              .getPath())
    }
  }
}
