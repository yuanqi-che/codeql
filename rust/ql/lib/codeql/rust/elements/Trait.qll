// generated by codegen, do not edit
/**
 * This module provides the public class `Trait`.
 */

private import internal.TraitImpl
import codeql.rust.elements.AssocItemList
import codeql.rust.elements.Attr
import codeql.rust.elements.GenericParamList
import codeql.rust.elements.Item
import codeql.rust.elements.Name
import codeql.rust.elements.TypeBoundList
import codeql.rust.elements.Visibility
import codeql.rust.elements.WhereClause

/**
 * A Trait. For example:
 * ```
 * trait Frobinizable {
 *   type Frobinator;
 *   type Result: Copy;
 *   fn frobinize_with(&mut self, frobinator: &Self::Frobinator) -> Result;
 * }
 *
 * pub trait Foo<T: Frobinizable> where T::Frobinator: Eq {}
 * ```
 */
final class Trait = Impl::Trait;
