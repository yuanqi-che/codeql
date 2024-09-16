// generated by codegen/codegen.py, do not edit
/**
 * This module provides the generated definition of `Location`.
 * INTERNAL: Do not import directly.
 */

private import codeql.swift.generated.Synth
private import codeql.swift.generated.Raw
import codeql.swift.elements.ElementImpl::Impl as ElementImpl
import codeql.swift.elements.File

/**
 * INTERNAL: This module contains the fully generated definition of `Location` and should not
 * be referenced directly.
 */
module Generated {
  /**
   * INTERNAL: Do not reference the `Generated::Location` class directly.
   * Use the subclass `Location`, where the following predicates are available.
   */
  class Location extends Synth::TLocation, ElementImpl::Element {
    /**
     * Gets the file of this location.
     */
    File getFile() {
      result =
        Synth::convertFileFromRaw(Synth::convertLocationToRaw(this).(Raw::Location).getFile())
    }

    /**
     * Gets the start line of this location.
     */
    int getStartLine() { result = Synth::convertLocationToRaw(this).(Raw::Location).getStartLine() }

    /**
     * Gets the start column of this location.
     */
    int getStartColumn() {
      result = Synth::convertLocationToRaw(this).(Raw::Location).getStartColumn()
    }

    /**
     * Gets the end line of this location.
     */
    int getEndLine() { result = Synth::convertLocationToRaw(this).(Raw::Location).getEndLine() }

    /**
     * Gets the end column of this location.
     */
    int getEndColumn() { result = Synth::convertLocationToRaw(this).(Raw::Location).getEndColumn() }
  }
}
