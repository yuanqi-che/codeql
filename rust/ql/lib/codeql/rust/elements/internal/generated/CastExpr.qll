// generated by codegen, do not edit
/**
 * This module provides the generated definition of `CastExpr`.
 * INTERNAL: Do not import directly.
 */

private import codeql.rust.elements.internal.generated.Synth
private import codeql.rust.elements.internal.generated.Raw
import codeql.rust.elements.Attr
import codeql.rust.elements.Expr
import codeql.rust.elements.internal.ExprImpl::Impl as ExprImpl
import codeql.rust.elements.TypeRepr

/**
 * INTERNAL: This module contains the fully generated definition of `CastExpr` and should not
 * be referenced directly.
 */
module Generated {
  /**
   * A type cast expression. For example:
   * ```rust
   * value as u64;
   * ```
   * INTERNAL: Do not reference the `Generated::CastExpr` class directly.
   * Use the subclass `CastExpr`, where the following predicates are available.
   */
  class CastExpr extends Synth::TCastExpr, ExprImpl::Expr {
    override string getAPrimaryQlClass() { result = "CastExpr" }

    /**
     * Gets the `index`th attr of this cast expression (0-based).
     */
    Attr getAttr(int index) {
      result =
        Synth::convertAttrFromRaw(Synth::convertCastExprToRaw(this).(Raw::CastExpr).getAttr(index))
    }

    /**
     * Gets any of the attrs of this cast expression.
     */
    final Attr getAnAttr() { result = this.getAttr(_) }

    /**
     * Gets the number of attrs of this cast expression.
     */
    final int getNumberOfAttrs() { result = count(int i | exists(this.getAttr(i))) }

    /**
     * Gets the expression of this cast expression, if it exists.
     */
    Expr getExpr() {
      result =
        Synth::convertExprFromRaw(Synth::convertCastExprToRaw(this).(Raw::CastExpr).getExpr())
    }

    /**
     * Holds if `getExpr()` exists.
     */
    final predicate hasExpr() { exists(this.getExpr()) }

    /**
     * Gets the type representation of this cast expression, if it exists.
     */
    TypeRepr getTypeRepr() {
      result =
        Synth::convertTypeReprFromRaw(Synth::convertCastExprToRaw(this)
              .(Raw::CastExpr)
              .getTypeRepr())
    }

    /**
     * Holds if `getTypeRepr()` exists.
     */
    final predicate hasTypeRepr() { exists(this.getTypeRepr()) }
  }
}
