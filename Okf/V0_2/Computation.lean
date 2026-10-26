import Okf.V0_2.Provenance
import Okf.V0_2.Log
import Okf.V0_2.Policy

/-!
# §10 Attested computations — one clause, two gaps, and the example again

§10 is the longest section and the one with the most consumer-side and runtime
text. For the bundle it states one REQUIRED, leaves two contract fields
unmarked, and describes the inline computation in a way its own example does
not follow. The §5.1 footnote join, which §10.2's example demonstrates, is in
`Okf.V0_2.Footnotes`.

## The clause: `runtime` is REQUIRED for the type

§10.2: `runtime` is "REQUIRED for this type". The type is the scalar
`Attested Computation`, matched exactly, a commitment like `Index.md` in
`Okf.V0_2.Structure`. §4.1 said type values are not registered; this one the
spec fixes by name. Under §11 the REQUIRED is guidance, so the clause is gated
by `Policy.familyClauses` with §5's two.

## The gap: `executor` and `attester` are unmarked

§10.2 marks `runtime` REQUIRED and `computation` Optional, and marks
`parameters`, `executor` and `attester` neither way. §10.5 cannot run or attest
without the last two. `Policy.contractFields` holds the choice; the strict
reading is that an Attested Computation carries `executor` and `attester`.
`parameters` is left out of it: an empty list and an absent key cannot be told
apart in intent, and §10.5 works with no parameters declared. That exclusion is
a pick, recorded. `docs/findings.md`, 2026-10-26, "§10.2 marks `executor` and
`attester` neither required nor optional".

## The gap: fenced, and the example is indented

§10.3: "a single fenced code block in the body under `# Computation`", or a
`computation` path with the body fence omitted, "in one of two ways". §10.2's
own example indents its SQL four spaces, has no fence, and has no `computation`
key. `Policy.inlineComp` holds the choice: the text's fence only, fence or
indented block, or the sentence as description. The strict readings require
exactly one of the key and a body block, since "one of two ways" and "omit the
body fence" read as exclusive. "Single" is not counted.

The body is read as §9 reads it, by lines. The `# Computation` section is the
lines after a line that is exactly `# Computation`, up to the next line
opening `# `. A fence is a line opening with three backticks or three tildes;
an indented block is a line opening with four spaces or a tab and carrying
more than that. The same approximation of markdown as `Okf.V0_2.Log` records.
`docs/findings.md`, 2026-10-26, "§10.3 says fenced, and §10.2's example is
indented".

## Shapes stated without force, under `fieldTypes`

`runtime` a scalar; `parameters` a list of mappings, each with `name`, `type`
and `required`; `computation` a scalar; `executor` a mapping with a scalar
`resource` and a `receipt` list of scalars; `attester` a mapping with a scalar
`resource`. Reading "each entry: `{ name, type, required }`" as all three
present is a pick inside the strict reading, recorded. Same field as §4.1 and
§5, same habit.

## Not modelled

The agent MAY supply only parameter values and MUST NOT author or edit the
computation: obligations on the agent at run time, not on the bundle. §10.5 and
§10.6 are informative by their own words. "A directory choice, not a
frontmatter one" and "OKF fixes the interface, not the packaging" are
informative. §10.4's `Metric` example is a positive witness in
`Okf.V0_2.Conformance`.
-/

namespace Okf.V0_2

/-- §10.1: a concept of `type: Attested Computation`, matched exactly. -/
def Document.isAttestedComputation (d : Document) : Bool :=
  match d.frontmatter.get? "type" with
  | some (.scalar s) => s == "Attested Computation"
  | _ => false

/-- Whether the frontmatter carries `key`. -/
def Frontmatter.hasKey (f : Frontmatter) (key : String) : Bool :=
  (f.get? key).isSome

/-- §10.2: `runtime` is "REQUIRED for this type". A concept of another type
passes. -/
def Document.runtimeIfAttested (d : Document) : Bool :=
  !d.isAttestedComputation || d.frontmatter.hasKey "runtime"

/-- §10.2's clause: every Attested Computation carries `runtime`. Gated by
`Policy.familyClauses`: §11 lists it among neither of its conditions and makes
§10 a SHOULD. -/
def Bundle.attestedHaveRuntime (b : Bundle) : Bool :=
  b.concepts.all fun e => e.2.runtimeIfAttested

/-- The `Prop` reading of `Bundle.attestedHaveRuntime`. -/
def Bundle.AttestedHaveRuntime (b : Bundle) : Prop :=
  ∀ e ∈ b.concepts, e.2.runtimeIfAttested = true

theorem Bundle.attestedHaveRuntime_iff (b : Bundle) :
    b.attestedHaveRuntime = true ↔ b.AttestedHaveRuntime := by
  simp [Bundle.attestedHaveRuntime, Bundle.AttestedHaveRuntime]

/-- The strict reading of `Policy.contractFields`: an Attested Computation
carries `executor` and `attester`. -/
def Document.contractComplete (d : Document) : Bool :=
  !d.isAttestedComputation
    || (d.frontmatter.hasKey "executor" && d.frontmatter.hasKey "attester")

/-- The strict reading over the bundle's concepts. -/
def Bundle.contractsComplete (b : Bundle) : Bool :=
  b.concepts.all fun e => e.2.contractComplete

/-- The `Prop` reading of `Bundle.contractsComplete`. -/
def Bundle.ContractsComplete (b : Bundle) : Prop :=
  ∀ e ∈ b.concepts, e.2.contractComplete = true

theorem Bundle.contractsComplete_iff (b : Bundle) :
    b.contractsComplete = true ↔ b.ContractsComplete := by
  simp [Bundle.contractsComplete, Bundle.ContractsComplete]

/-- The lines up to the next level-one heading. -/
def untilNextH1 : List (List Char) → List (List Char)
  | [] => []
  | line :: rest =>
    if "# ".toList.isPrefixOf line then [] else line :: untilNextH1 rest

/-- The lines of the `# Computation` section, by the line-based reading the
module docstring describes. Empty when there is no such heading. -/
def computationSection : List (List Char) → List (List Char)
  | [] => []
  | line :: rest =>
    if line == "# Computation".toList then untilNextH1 rest else computationSection rest

/-- A fence opens with three backticks or three tildes. -/
def isFenceLine (line : List Char) : Bool :=
  "```".toList.isPrefixOf line || "~~~".toList.isPrefixOf line

/-- An indented code line opens with four spaces or a tab and carries more. -/
def isIndentedCodeLine (line : List Char) : Bool :=
  ("    ".toList.isPrefixOf line && line.length > 4)
    || ("\t".toList.isPrefixOf line && line.length > 1)

/-- §10.3's inline form: a fence under `# Computation`. -/
def Body.hasComputationFence (b : Body) : Bool :=
  (computationSection (splitLines b.toList)).any isFenceLine

/-- §10.2's example's form: an indented block under `# Computation`. -/
def Body.hasIndentedComputation (b : Body) : Bool :=
  (computationSection (splitLines b.toList)).any isIndentedCodeLine

/-- Which bodies a reading counts as carrying an inline computation. -/
def InlineCompForm.bodyHas : InlineCompForm → Body → Bool
  | .fencedOnly, b => b.hasComputationFence
  | .fencedOrIndented, b => b.hasComputationFence || b.hasIndentedComputation
  | .unconstrained, _ => true

/-- §10.3 under reading `form`: an Attested Computation provides its
computation in exactly one of the two ways. Under `unconstrained` nothing is
checked. A concept of another type passes. -/
def Document.computationProvided (form : InlineCompForm) (d : Document) : Bool :=
  !d.isAttestedComputation
    || match form with
      | .unconstrained => true
      | f =>
        let viaKey := d.frontmatter.hasKey "computation"
        let viaBody := f.bodyHas d.body
        (viaKey && !viaBody) || (!viaKey && viaBody)

/-- §10.3 over the bundle's concepts, under reading `form`. -/
def Bundle.computationsProvided (b : Bundle) (form : InlineCompForm) : Bool :=
  b.concepts.all fun e => e.2.computationProvided form

/-- The `Prop` reading of `Bundle.computationsProvided`. -/
def Bundle.ComputationsProvided (b : Bundle) (form : InlineCompForm) : Prop :=
  ∀ e ∈ b.concepts, e.2.computationProvided form = true

theorem Bundle.computationsProvided_iff (b : Bundle) (form : InlineCompForm) :
    b.computationsProvided form = true ↔ b.ComputationsProvided form := by
  simp [Bundle.computationsProvided, Bundle.ComputationsProvided]

/-- A `parameters` entry as §10.2 describes it: `{ name, type, required }`,
all three present, all scalars. -/
def Value.isParameter (v : Value) : Bool :=
  v.isMap
    && v.hasKey "name" && v.keyHolds "name" Value.isScalar
    && v.hasKey "type" && v.keyHolds "type" Value.isScalar
    && v.hasKey "required" && v.keyHolds "required" Value.isScalar

/-- §10.2's `executor`: a mapping with a scalar `resource` and a `receipt` list
of scalars. -/
def Value.isExecutor (v : Value) : Bool :=
  v.isMap && v.keyHolds "resource" Value.isScalar && v.keyHolds "receipt" Value.isSeqOfScalars

/-- §10.2's `attester`: a mapping with a scalar `resource`. -/
def Value.isAttester (v : Value) : Bool :=
  v.isMap && v.keyHolds "resource" Value.isScalar

/-- The strict reading of §10's shape descriptions. Whether it binds is
`Policy.fieldTypes`, shared with §4.1 and §5. -/
def Frontmatter.computationTypesHold (f : Frontmatter) : Bool :=
  f.keyHolds "runtime" Value.isScalar
    && f.keyHolds "parameters" (fun v => match v with
      | .seq items => items.all Value.isParameter
      | _ => false)
    && f.keyHolds "computation" Value.isScalar
    && f.keyHolds "executor" Value.isExecutor
    && f.keyHolds "attester" Value.isAttester

/-- The strict reading over the bundle's concepts. -/
def Bundle.computationTypesHold (b : Bundle) : Bool :=
  b.concepts.all fun e => e.2.frontmatter.computationTypesHold

/-- The `Prop` reading of `Bundle.computationTypesHold`. -/
def Bundle.ComputationTypesHold (b : Bundle) : Prop :=
  ∀ e ∈ b.concepts, e.2.frontmatter.computationTypesHold = true

theorem Bundle.computationTypesHold_iff (b : Bundle) :
    b.computationTypesHold = true ↔ b.ComputationTypesHold := by
  simp [Bundle.computationTypesHold, Bundle.ComputationTypesHold]

end Okf.V0_2
