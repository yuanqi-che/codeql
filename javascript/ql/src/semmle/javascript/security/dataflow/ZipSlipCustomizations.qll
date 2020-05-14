/**
 * Provides default sources, sinks and sanitizers for reasoning about
 * unsafe zip and tar archive extraction, as well as extension points
 * for adding your own.
 */

import javascript

module ZipSlip {
  /**
   * A data flow source for unsafe archive extraction.
   */
  abstract class Source extends DataFlow::Node { }

  /**
   * A data flow sink for unsafe archive extraction.
   */
  abstract class Sink extends DataFlow::Node { }

  /**
   * A sanitizer for unsafe archive extraction.
   */
  abstract class Sanitizer extends DataFlow::Node { }

  /**
   * A sanitizer guard for unsafe archive extraction.
   */
  abstract class SanitizerGuard extends TaintTracking::SanitizerGuardNode, DataFlow::ValueNode { }

  /**
   * Gets a node that can be a parsed archive.
   */
  private DataFlow::SourceNode parsedArchive() {
    result = DataFlow::moduleImport("unzipper").getAMemberCall("Parse")
    or
    result = DataFlow::moduleImport("unzip").getAMemberCall("Parse")
    or
    result = DataFlow::moduleImport("tar-stream").getAMemberCall("extract")
    or
    // `streamProducer.pipe(unzip.Parse())` is a typical (but not
    // universal) pattern when using nodejs streams, whose return
    // value is the parsed stream.
    exists(DataFlow::MethodCallNode pipe |
      pipe = result and
      pipe.getMethodName() = "pipe" and
      parsedArchive().flowsTo(pipe.getArgument(0))
    )
  }

  /** Gets a property that is used to get a filename part of an archive entry. */
  private string getAFilenameProperty() {
    result = "path" // Used by library 'unzip'.
    or
    result = "name" // Used by library 'tar-stream'.
    or
    result = "linkname" // linked file name, used by 'tar-stream'.
  }

  /** An archive entry path access, as a source for unsafe archive extraction. */
  class UnzipEntrySource extends Source {
    // For example, in
    // ```javascript
    // const unzip = require('unzip');
    //
    // fs.createReadStream('archive.zip')
    //   .pipe(unzip.Parse())
    //   .on('entry', entry => {
    //      const path = entry.path;
    //   });
    // ```
    // there is an `UnzipEntrySource` node corresponding to
    // the expression `entry.path`.
    UnzipEntrySource() {
      exists(DataFlow::CallNode cn |
        cn = parsedArchive().getAMemberCall(EventEmitter::on()) and
        cn.getArgument(0).mayHaveStringValue("entry") and
        this = cn.getCallback(1).getParameter(0).getAPropertyRead(getAFilenameProperty())
      )
    }
  }

  /** An archive entry path access using the `adm-zip` package. */
  class AdmZipEntrySource extends Source {
    AdmZipEntrySource() {
      exists(DataFlow::SourceNode admZip, DataFlow::SourceNode entry |
        admZip = DataFlow::moduleImport("adm-zip").getAnInstantiation() and
        this = entry.getAPropertyRead("entryName")
      |
        entry = admZip.getAMethodCall("getEntry")
        or
        exists(DataFlow::SourceNode entries | entries = admZip.getAMethodCall("getEntries") |
          entry = entries.getAPropertyRead()
          or
          exists(string map | map = "map" or map = "forEach" |
            entry = entries.getAMethodCall(map).getCallback(0).getParameter(0)
          )
        )
      )
    }
  }

  /** A call to `fs.createWriteStream`, as a sink for unsafe archive extraction. */
  class CreateWriteStreamSink extends Sink {
    CreateWriteStreamSink() {
      // This is not covered by `FileSystemWriteSink`, because it is
      // required that a write actually takes place to the stream.
      // However, we want to consider even the bare `createWriteStream`
      // to be a zipslip vulnerability since it may truncate an
      // existing file.
      this = NodeJSLib::Fs::moduleMember("createWriteStream").getACall().getArgument(0)
    }
  }

  /** A file path of a file write, as a sink for unsafe archive extraction. */
  class FileSystemWriteSink extends Sink {
    FileSystemWriteSink() { exists(FileSystemWriteAccess fsw | fsw.getAPathArgument() = this) }
  }

  /** An expression that sanitizes by calling path.basename */
  class BasenameSanitizer extends Sanitizer {
    BasenameSanitizer() { this = DataFlow::moduleImport("path").getAMemberCall("basename") }
  }

  /**
   * An expression that forces the output path to be in the current working folder.
   * Recognizes the pattern: `path.join(cwd, path.join('/', orgPath))`.
   */
  class PathSanitizer extends Sanitizer, DataFlow::CallNode {
    PathSanitizer() {
      this = NodeJSLib::Path::moduleMember("join").getACall() and
      exists(DataFlow::CallNode inner | inner = getArgument(1) |
        inner = NodeJSLib::Path::moduleMember("join").getACall() and
        inner.getArgument(0).mayHaveStringValue("/")
      )
    }
  }

  /**
   * Gets a string which is sufficient to exclude to make
   * a filepath definitely not refer to parent directories.
   */
  private string getAParentDirName() { result = ".." or result = "../" }

  /** A check that a path string does not include '..' */
  class NoParentDirSanitizerGuard extends SanitizerGuard {
    StringOps::Includes incl;

    NoParentDirSanitizerGuard() { this = incl }

    override predicate sanitizes(boolean outcome, Expr e) {
      incl.getPolarity().booleanNot() = outcome and
      incl.getBaseString().asExpr() = e and
      incl.getSubstring().mayHaveStringValue(getAParentDirName())
    }
  }
}
