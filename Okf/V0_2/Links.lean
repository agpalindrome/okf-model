import Okf.V0_2.Basic

/-!
# §6 Cross-linking and paths — nothing to model, and why

This module declares nothing. It exists because §6 carries RFC 2119 keywords
and the model declines every one of them, and the reasons are not recoverable
from code that is not there.

## Links cannot make a bundle non-conformant

§6.1 says concepts MAY link, names two supported forms, and calls the absolute
form "recommended" in lowercase, which is not RFC 2119 RECOMMENDED. Its one
MUST binds consumers, to tolerate broken links, and it says in so many words
that a link whose target is not in the bundle "is not malformed". So there is
no clause about links, and no clause reads a `Body`.

That closes two things left open earlier. `Okf.V0_2.Basic` expected §6 to force
a structured `Body`; it does not, and `Body` stays `String` until a section
states a rule over body content. §2 deferred `Link` to here; §6.1 gives its two
forms, but no clause reads one, so a `Link` type would be a stub with the shape
we guessed, and there is none. If the fixture bridge in
`docs/scope-and-stance.md` is ever built and needs the bundle graph, it will
also need a resolution function for "a standard markdown relative path", and
the spec does not define one: markdown has no path semantics of its own.

## §6.2 states three accepted forms with no complement

Path-valued fields "accept" an absolute URL, a bundle-relative path beginning
with `/`, or "a relative path". No keyword attaches, and relative path is not
defined, so every string that is not one of the first two is the third. For
`sources[].resource` the text adds that a scope descriptor, free prose, is
accepted too. A constraint with no complement checks nothing, so it gets no
predicate and no `Policy` field. It is not logged in `docs/findings.md`: the
question for upstream would be what is not a relative path, and the owner
judged that too thin (2026-10-26).

## §6.3 says of itself

The `references/` subdirectory is "a naming convention, not a requirement".

## The footnote join went on to §10

§5.1's footnote label as a `sources[].id` join key waited here for a `Body`
with structure, and §6 was not the section that gave one. §9 then read a body
by lines, and `Okf.V0_2.Footnotes` models the join that way.
-/
