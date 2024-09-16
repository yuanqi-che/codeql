// generated by codegen, do not edit
/**
 * This module provides the generated definition of `TypeRef`.
 * INTERNAL: Do not import directly.
 */

private import codeql.rust.generated.Synth
private import codeql.rust.generated.Raw
import codeql.rust.elements.AstNodeImpl::Impl as AstNodeImpl
import codeql.rust.elements.UnimplementedImpl::Impl as UnimplementedImpl

/**
 * INTERNAL: This module contains the fully generated definition of `TypeRef` and should not
 * be referenced directly.
 */
module Generated {
  /**
   * The base class for type references.
   * ```
   * let x: i32;
   * let y: Vec<i32>;
   * let z: Option<i32>;
   * ```
   * INTERNAL: Do not reference the `Generated::TypeRef` class directly.
   * Use the subclass `TypeRef`, where the following predicates are available.
   */
  class TypeRef extends Synth::TTypeRef, AstNodeImpl::AstNode, UnimplementedImpl::Unimplemented {
    override string getAPrimaryQlClass() { result = "TypeRef" }
  }
}
