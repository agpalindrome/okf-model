import Okf.V0_2.Basic

/-!
# §13 Changes from v0.1 — nothing to model, and one thing to record

§13 is the document's account of its own history. It binds no bundle, so this
module declares nothing; `Okf.V0_2.AppendixA` carries the worked example that
follows §13 in the text.

## §13 applies §12's scheme and breaks it

§12: a minor bump "introduces backward-compatible additions"; a major bump "may
make breaking changes (renaming required fields, changing reserved
filenames)". §13: v0.2 "is a minor version bump under §12, except for two
deliberate breaking changes", one of which renames `timestamp` to
`generated.at`. The sentence applies the scheme and excepts itself from it.
That is not a gap in what a bundle must be, so it gets no `Policy` field; it is
a document-level finding beside the first entry in `docs/findings.md`, which
found the same scheme silent on the timestamp type change.

## Legacy fields

§13.1 lets consumers fall back to a legacy `timestamp` and parse a legacy
`# Citations` list. Consumer rules. A v0.2 bundle that still carries them
violates nothing: `timestamp` is an extension key under §4.1 and no clause
reads a `# Citations` heading. `Okf.V0_2.AppendixA` proves the appendix's own
v0.1 document conformant under every policy, which is stronger than §13's
"consumable" and is stated nowhere in the text.

## Inter-revision theorems stay open

`docs/scope-and-stance.md` left open whether theorems about §13's "changes
from" are worth stating. There is no v0.1 pin and no `Okf.V0_1`, so from this
text alone a "changes from" theorem has no second side. §13.2's list of what is
additive, and "everything else is carried forward unchanged", are claims about
v0.1 the model cannot check. Whether to ever model v0.1 stays where the stance
document left it, with the owner.

## Carried forward "permissive conformance"

§13 lists "permissive conformance" among what v0.1 carried forward unchanged.
That is §11 described as permissive by the text itself, which leans toward §11
as the definition of conformance and the §5 and §10 REQUIREDs as guidance; it
does not state it. The §11 finding in `docs/findings.md` records the lean.
-/
