/**
 * @name Artifact poisoning
 * @description An attacker may be able to poison the workflow's artifacts and influence on consequent steps.
 * @kind path-problem
 * @problem.severity warning
 * @precision high
 * @security-severity 5.0
 * @id actions/artifact-poisoning
 * @tags actions
 *       security
 *       external/cwe/cwe-829
 */

import actions
import codeql.actions.security.ArtifactPoisoningQuery
import ArtifactPoisoningFlow::PathGraph

from ArtifactPoisoningFlow::PathNode source, ArtifactPoisoningFlow::PathNode sink
where
  ArtifactPoisoningFlow::flowPath(source, sink) and
  (
    exists(source.getNode().asExpr().getEnclosingCompositeAction())
    or
    exists(Workflow w |
      w = source.getNode().asExpr().getEnclosingWorkflow() and
      not w.isPrivileged()
    )
  )
select sink.getNode(), source, sink,
  "Potential artifact poisoning in $@, which may be controlled by an external user.", sink,
  sink.getNode().toString()
