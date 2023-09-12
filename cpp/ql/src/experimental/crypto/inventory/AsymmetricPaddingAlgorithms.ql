/**
 * @name Asymmetric Padding Schemes
 * @description Finds all potential usage of padding schemes used with asymmeric algorithms.
 * @kind problem
 * @id cpp/quantum-readiness/cbom/asymmetric-padding-schemes
 * @problem.severity error
 * @tags security
 *       cbom
 *       cryptography
 */

import cpp
import experimental.crypto.Concepts

// TODO: currently not modeled for any API
from AsymmetricPadding alg
select alg, "Use of algorithm " + alg.getPaddingName()
