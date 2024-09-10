// generated by codegen
/**
 * This module provides the generated definition of `InlineAsmExpr`.
 * INTERNAL: Do not import directly.
 */

private import codeql.rust.generated.Synth
private import codeql.rust.generated.Raw
import codeql.rust.elements.Expr

/**
 * INTERNAL: This module contains the fully generated definition of `InlineAsmExpr` and should not
 * be referenced directly.
 */
module Generated {
  /**
   * An inline assembly expression. For example:
   * ```
   * unsafe {
   *     builtin # asm(_);
   * }
   * ```
   * INTERNAL: Do not reference the `Generated::InlineAsmExpr` class directly.
   * Use the subclass `InlineAsmExpr`, where the following predicates are available.
   */
  class InlineAsmExpr extends Synth::TInlineAsmExpr, Expr {
    override string getAPrimaryQlClass() { result = "InlineAsmExpr" }

    /**
     * Gets the expression of this inline asm expression.
     */
    Expr getExpr() {
      result =
        Synth::convertExprFromRaw(Synth::convertInlineAsmExprToRaw(this)
              .(Raw::InlineAsmExpr)
              .getExpr())
    }
  }
}
