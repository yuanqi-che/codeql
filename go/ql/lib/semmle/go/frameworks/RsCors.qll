/**
 * Provides classes for modeling the `github.com/rs/cors` package.
 */

 import go

 /**
  * Provides classes for modeling the `github.com/rs/cors` package.
  */
 module RsCors {
   /** Gets the package name `github.com/gin-gonic/gin`. */
   string packagePath() { result = package("github.com/rs/cors", "") }
 
   /**
    * A new function create a new gin Handler that passed to gin as middleware
    */
   class New extends Function {
     New() { exists(Function f | f.hasQualifiedName(packagePath(), "New") | this = f) }
   }
 
   /**
    * A write to the value of Access-Control-Allow-Credentials header
    */
   class AllowCredentialsWrite extends DataFlow::ExprNode {
     DataFlow::Node base;
 
     AllowCredentialsWrite() {
       exists(Field f, Write w |
         f.hasQualifiedName(packagePath(), "Options", "AllowCredentials") and
         w.writesField(base, f, this) and
         this.getType() instanceof BoolType
       )
     }
 
     /**
      * Get config struct holding header values
      */
     DataFlow::Node getBase() { result = base }
 
     /**
      * Get config variable holding header values
      */
     RsOptions getConfig() {
       exists(RsOptions gc |
         (
           gc.getV().getBaseVariable().getDefinition().(SsaExplicitDefinition).getRhs() =
             base.asInstruction() or
           gc.getV().getAUse() = base
         ) and
         result = gc
       )
     }
   }
 
   /**
    * A write to the value of Access-Control-Allow-Origins header
    */
   class AllowOriginsWrite extends DataFlow::ExprNode {
     DataFlow::Node base;
 
     AllowOriginsWrite() {
       exists(Field f, Write w |
         f.hasQualifiedName(packagePath(), "Options", "AllowedOrigins") and
         w.writesField(base, f, this) and
         this.asExpr() instanceof SliceLit
       )
     }
 
     /**
      * Get config struct holding header values
      */
     DataFlow::Node getBase() { result = base }
 
     /**
      * Get config variable holding header values
      */
     RsOptions getConfig() {
       exists(RsOptions gc |
         (
           gc.getV().getBaseVariable().getDefinition().(SsaExplicitDefinition).getRhs() =
             base.asInstruction() or
           gc.getV().getAUse() = base
         ) and
         result = gc
       )
     }
   }
 
   /**
    * A write to the value of Access-Control-Allow-Origins of value "*", overriding AllowOrigins
    */
   class AllowAllOriginsWrite extends DataFlow::ExprNode {
     DataFlow::Node base;
 
     AllowAllOriginsWrite() {
       exists(Field f, Write w |
         f.hasQualifiedName(packagePath(), "Options", "AllowAllOrigins") and
         w.writesField(base, f, this) and
         this.getType() instanceof BoolType
       )
     }
 
     /**
      * Get config struct holding header values
      */
     DataFlow::Node getBase() { result = base }
 
     /**
      * Get config variable holding header values
      */
     RsOptions getConfig() {
       exists(RsOptions gc |
         (
           gc.getV().getBaseVariable().getDefinition().(SsaExplicitDefinition).getRhs() =
             base.asInstruction() or
           gc.getV().getAUse() = base
         ) and
         result = gc
       )
     }
   }
 
   /**
    * A variable of type Config that holds the headers to be set.
    */
   class RsOptions extends Variable {
     SsaWithFields v;
 
     RsOptions() {
       this = v.getBaseVariable().getSourceVariable() and
       exists(Type t | t.hasQualifiedName(packagePath(), "Options") | v.getType() = t)
     }
 
     /**
      * Get variable declaration of GinConfig
      */
     SsaWithFields getV() { result = v }
   }
 }