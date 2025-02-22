// generated by codegen/codegen.py, do not edit
/**
 * This module provides the generated definition of `ThrowStmt`.
 * INTERNAL: Do not import directly.
 */

private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.expr.Expr
import codeql.swift.elements.stmt.internal.StmtImpl::Impl as StmtImpl

/**
 * INTERNAL: This module contains the fully generated definition of `ThrowStmt` and should not
 * be referenced directly.
 */
module Generated {
  /**
   * INTERNAL: Do not reference the `Generated::ThrowStmt` class directly.
   * Use the subclass `ThrowStmt`, where the following predicates are available.
   */
  class ThrowStmt extends Synth::TThrowStmt, StmtImpl::Stmt {
    override string getAPrimaryQlClass() { result = "ThrowStmt" }

    /**
     * Gets the sub expression of this throw statement.
     *
     * This includes nodes from the "hidden" AST. It can be overridden in subclasses to change the
     * behavior of both the `Immediate` and non-`Immediate` versions.
     */
    Expr getImmediateSubExpr() {
      result =
        Synth::convertExprFromRaw(Synth::convertThrowStmtToRaw(this).(Raw::ThrowStmt).getSubExpr())
    }

    /**
     * Gets the sub expression of this throw statement.
     */
    final Expr getSubExpr() {
      exists(Expr immediate |
        immediate = this.getImmediateSubExpr() and
        result = immediate.resolve()
      )
    }
  }
}
