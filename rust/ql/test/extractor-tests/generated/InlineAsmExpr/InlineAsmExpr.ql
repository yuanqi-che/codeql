// generated by codegen
import codeql.rust.elements
import TestUtils

from InlineAsmExpr x, Expr getExpr
where
  toBeTested(x) and
  not x.isUnknown() and
  getExpr = x.getExpr()
select x, "getExpr:", getExpr
