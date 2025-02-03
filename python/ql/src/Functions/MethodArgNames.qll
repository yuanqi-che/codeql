/** Definitions for reasoning about the expected first argument names for methods. */

import python
import semmle.python.ApiGraphs
import DataFlow

/** Holds if `f` is a method of the class `c`. */
private predicate methodOfClass(Function f, Class c) { f.getScope() = c }

/** Holds if `c` is a metaclass. */
private predicate isMetaclass(Class c) {
  c = API::builtin("type").getASubclass*().asSource().asExpr().(ClassExpr).getInnerScope()
}

/** Holds if `f` is a class method. */
private predicate isClassMethod(Function f) {
  f.getADecorator() = API::builtin("classmethod").asSource().asExpr()
  or
  f.getName() in ["__new__", "__init_subclass__", "__metaclass__", "__class_getitem__"]
}

/** Holds if `f` is a static method. */
private predicate isStaticMethod(Function f) {
  f.getADecorator() = API::builtin("staticmethod").asSource().asExpr()
}

/** Holds if `c` is a Zope interface. */
private predicate isZopeInterface(Class c) {
  c =
    API::moduleImport("zope")
        .getMember("interface")
        .getMember("Interface")
        .getASubclass*()
        .asSource()
        .asExpr()
        .(ClassExpr)
        .getInnerScope()
}

/**
 * Holds if `f` is used in the initialisation of `c`.
 * This means `f` isn't being used as a normal method.
 * Ideally it should be a `@staticmethod`; however this wasn't possible prior to Python 3.10.
 * We exclude this case from the `not-named-self` query.
 * However there is potential for a new query that specifically covers and alerts for this case.
 */
private predicate usedInInit(Function f, Class c) {
  methodOfClass(f, c) and
  exists(Call call |
    call.getScope() = c and
    DataFlow::localFlow(DataFlow::exprNode(f.getDefinition()), DataFlow::exprNode(call.getFunc()))
  )
}

/** Holds if the first parameter of `f` should be named `self`. */
predicate shouldBeSelf(Function f, Class c) {
  methodOfClass(f, c) and
  not isStaticMethod(f) and
  not isClassMethod(f) and
  not isMetaclass(c) and
  not isZopeInterface(c) and
  not usedInInit(f, c)
}

/** Holds if the first parameter of `f` should be named `cls`. */
predicate shouldBeCls(Function f, Class c) {
  methodOfClass(f, c) and
  not isStaticMethod(f) and
  (
    isClassMethod(f) and not isMetaclass(c)
    or
    isMetaclass(c) and not isClassMethod(f)
  )
}

/** Holds if the first parameter of `f` is named `self`. */
predicate firstArgNamedSelf(Function f) { f.getArgName(0) = "self" }

/** Holds if the first parameter of `f` is named `cls`. */
predicate firstArgNamedCls(Function f) {
  exists(string argname | argname = f.getArgName(0) |
    argname = "cls"
    or
    /* Not PEP8, but relatively common */
    argname = "mcls"
  )
}

/** Holds if the first parameter of `f` should be named `self`, but isn't. */
predicate firstArgShouldBeNamedSelfAndIsnt(Function f) {
  shouldBeSelf(f, _) and
  not firstArgNamedSelf(f)
}

/** Holds if `f` is a regular method of a metaclass, and its first argument is named `self`. */
private predicate metaclassNamedSelf(Function f, Class c) {
  methodOfClass(f, c) and
  firstArgNamedSelf(f) and
  isMetaclass(c) and
  not isClassMethod(f)
}

/** Holds if the first parameter of `f` should be named `cls`, but isn't. */
predicate firstArgShouldBeNamedClsAndIsnt(Function f) {
  shouldBeCls(f, _) and
  not firstArgNamedCls(f) and
  not metaclassNamedSelf(f, _)
}
