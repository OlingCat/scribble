#reader(lib "docreader.ss" "scribble")
@require[(lib "manual.ss" "scribble")]
@require["utils.ss"]
@require-for-syntax[mzscheme]

@title[#:tag "manual"]{PLT Manual Forms}

The @file{manual.ss} module provides all of @file{basic.ss}, and
more...

@; ------------------------------------------------------------------------
@section{Typesetting Code}

@defform[(schemeblock datum ...)]{

Typesets the @scheme[datum] sequence as a table of Scheme code inset
by two spaces. The source locations of the @scheme[datum]s determine
the generated layout. For example,

@schemeblock[
(schemeblock
 (define (loop x)
   (loop (not x))))
]

produces the output

@schemeblock[
(define (loop x)
  (loop (not x)))
]

with the @scheme[(loop (not x))] indented under @scheme[define],
because that's the way it is idented the use of @scheme[schemeblock].

Furthermore, @scheme[define] is typeset as a keyword (bold and black)
and as a hyperlink to @scheme[define]'s definition in the reference
manual, because this document was built using information about the
reference manual, and because the lexical binding of @scheme[define]
(in the source) matches the lexical binding of the definition in the
reference manual. Similarly, @scheme[not] is a hyperlink to the its
definition in the reference manual.

Use @scheme[unsyntax] to escape back to an expression that produces an
@scheme[element]. For example,

@let[([unsyntax #f])
(schemeblock
 (schemeblock
   (+ 1 (unsyntax (elem (scheme x) (subscript "2"))))))
]

produces

@schemeblock[
(+ 1 (unsyntax (elem (scheme x) (subscript "2"))))
]

The @scheme[unsyntax] form is regonized via
@scheme[module-identifier=?], so if you want to typeset code that
includes @scheme[unsyntax], you can simply hide the usual binding:

@SCHEMEBLOCK[
(schemeblock
  (let ([(UNSYNTAX (scheme unsyntax)) #f])
    (schemeblock
      (syntax (+ 1 (unsyntax x))))))
]

Or use @scheme[SCHEMEBLOCK], whose escape form is @scheme[UNSYNTAX]
instead of @scheme[unsyntax]. See also @scheme[define-code] from
@file{scheme.ss}.

A few other escapes are recognized symbolically:

@itemize{

 @item{@scheme[(#,(scheme code:line) datum ...)] typesets as the
       sequence of @scheme[datum]s (i.e., without the
       @scheme[code:line] wrapper.}

 @item{@scheme[(#,(scheme code:comment) content-expr)] typesets as a
       comment whose content (i.e., sequence of elements) is produced
       by @scheme[content-expr].}

 @item{@schemeidfont{code:blank} typesets as a blank line.}

}

}

@defform[(SCHEMEBLOCK datum ...)]{Like @scheme[schemeblock], but with
the expression escape @scheme[UNSYNTAX] instead of @scheme[unsyntax].}

@defform[(schemeblock0 datum ...)]{Like @scheme[schemeblock], but
without insetting the code.}

@defform[(SCHEMEBLOCK0 datum ...)]{Like @scheme[SCHEMEBLOCK], but
without insetting the code.}

@defform[(schemeinput datum ...)]{Like @scheme[schemeblock], but the
@scheme[datum] are typeset after a prompt representing a REPL.}

@defform[(schememod lang datum ...)]{Like @scheme[schemeblock], but
the @scheme[datum] are typeset inside a @schemefont{#module}-form
module whose language is @scheme[lang].}

@defform[(scheme datum ...)]{Like @scheme[schemeblock], but typeset on
a single line and wrapped with its enclosing paragraph, independent of
the formatting of @scheme[datum].}

@defform[(schemeresult datum ...)]{Like @scheme[scheme], but typeset
as a REPL value (i.e., a single color with no hyperlinks).}

@defform[(schemeid datum ...)]{Like @scheme[scheme], but typeset
as an unbound identifier (i.e., no coloring or hyperlinks).}

@defform[(schememodname datum ...)]{Like @scheme[scheme], but typeset
as a @schemefont{#module} language name.}

@defproc[(litchar [str string?]) element?]{Typesets @scheme[str] as a
representation of literal text. Use this when you have to talk about
the individual characters in a stream of text, as as when documenting
a reader extension.}

@defproc[(verbatim [str string?]) flow-element?]{Typesets @scheme[str]
as a table/paragraph in typewriter font with the linebreaks specified
by newline characters in @scheme[str]. ``Here strings'' are often
useful with @scheme[verbatim].}

@defproc[(schemefont [pre-content any/c] ...) element?]{Typesets the given
content as uncolored, unhyperlinked Scheme. This procedure is useful
for typesetting things like @scheme{#module}, which are not
@scheme[read]able by themselves.}

@defproc[(schemevalfont [pre-content any/c] ...) element?]{Like
@scheme[schemefont], but colored as a value.}

@defproc[(schemeresultfont [pre-content any/c] ...) element?]{Like
@scheme[schemefont], but colored as a REPL result.}

@defproc[(schemeidfont [pre-content any/c] ...) element?]{Like
@scheme[schemefont], but colored as an identifier.}

@defproc[(schemekeywordfont [pre-content any/c] ...) element?]{Like
@scheme[schemefont], but colored as a syntactic form name.}

@defproc[(procedure [pre-content any/c] ...) element?]{Typesets the given
content as a procedure name in a REPL result (e.g., in typewriter font
with a @schemefont{#<procedure:} prefix and @schemefont{>} suffix.).}

@defform[(var datum)]{Typesets @scheme[var] as an identifier that is
an argument or sub-form in a procedure being
documented. Normally, the @scheme[defproc] and @scheme[defform]
arrange for @scheme[scheme] to format such identifiers automatically
in the description of the procedure, but use @scheme[var] if that
cannot work for some reason.}

@defform[(svar datum)]{Like @scheme[var], but for subform non-terminals
in a form definition.}

@; ------------------------------------------------------------------------
@section{Definition Reference}

@defform[(defproc (id arg-spec ...)
                  result-contract-expr-datum
                  pre-flow ...)]{

Produces a sequence of flow elements (encaptured in a @scheme[splice])
to document a procedure named @scheme[id]. The @scheme[id] is
registered so that @scheme[scheme]-typeset uses of the identifier
(with the same lexical binding) are hyperlinked to this documentation.

Each @scheme[arg-spec] must have one of the following forms:

@specsubform[(arg-id contract-expr-datum)]{
       An argument whose contract is specified by
       @scheme[contract-expr-datum] which is typeset via
       @scheme[schemeblock0].}

@specsubform[(arg-id contract-expr-datum default-expr)]{
       Like the previous case, but with a default value. All arguments
       with a default value must be grouped together, but they can be
       in the middle of required arguments.}

@specsubform[(keyword arg-id contract-expr-datum)]{
       Like the first case, but for a keyword-based argument.}

@specsubform[(keyword arg-id contract-expr-datum default-expr)]{
       Like the previous case, but with a default
       value.}

@specsubform[#, @schemeidfont{...}]{ Any number of the preceding argument
      (normally at the end).}

@specsubform[#, @schemeidfont{...+}]{One or more of the preceding argument
       (normally at the end).}

The @scheme[result-contract-expr-datum] is typeset via
@scheme[schemeblock0], and it represents a contract on the procedure's
result.

The @scheme[pre-flow]s list is parsed as a flow that documents the
procedure. In this description, references to @svar[arg-id]s
are typeset as procedure arguments.

The typesetting of all data before the @scheme[pre-flow]s ignores the
source layout.}


@defform[(defproc* ([(id arg-spec ...)
                     result-contract-expr-datum] ...)
                   pre-flow ...)]{

Like @scheme[defproc], but for multiple cases with the same
@scheme[id].  }


@defform/subs[(defform maybe-literals (id . datum) pre-flow ...)
              ([maybe-literals code:blank
                               (code:line #:literals (literal-id ...))])]{

Produces a a sequence of flow elements (encaptured in a
@scheme[splice]) to document a syntatic form named by @scheme[id]. The
@scheme[id] is registered so that @scheme[scheme]-typeset uses of the
identifier (with the same lexical binding) are hyperlinked to this
documentation.

The @scheme[pre-flow]s list is parsed as a flow that documents the
procedure. In this description, a reference to any identifier in
@scheme[datum] is typeset as a sub-form non-terminal. If
@scheme[#:literals] clause is provided, however, instances of the
@scheme[literal-id]s are typeset normally.

The typesetting of @scheme[(id . datum)] preserves the source
layout, like @scheme[schemeblock], and unlike @scheme[defproc].}

@defform[(defform* maybe-literals [(id . datum) ..+] pre-flow ...)]{

Like @scheme[defform], but for multiple forms using the same
@scheme[id].}

@defform/subs[(defform/subs maybe-literals (id . datum)
                ([nonterm-id clause-datum ...+] ...)
                pre-flow ...)
              ([maybe-literals code:blank
                               (code:line #:literals (literal-id ...))])]{
Like @scheme[defform], but including an auxiliary grammar of
non-terminals shown with the @scheme[id] form. Each
@scheme[nonterm-id] is specified as being any of the corresponding
@scheme[clause-datum]s, where the formatting of each
@scheme[clause-datum] is preserved.}

@defform/subs[(specform maybe-literals (id . datum) pre-flow ...)
              ([maybe-literals code:blank
                               (code:line #:literals (literal-id ...))])]{

Like @scheme[defform], with without registering a definition, and with
indenting on the left for both the specification and the
@scheme[pre-flow]s.}

@defform[(specsubform maybe-literals datum pre-flow ...)]{

Similar to @scheme[defform], but without any specific identifier being
defined, and the table and flow are typeset indented. This form is
intended for use when refining the syntax of a non-terminal used in a
@scheme[defform] or other @scheme[specsubform]. For example, it is
used in the documentation for @scheme[defproc] in the itemization of
possible shapes for @svar[arg-spec].

The @scheme[pre-flow]s list is parsed as a flow that documents the
procedure. In this description, a reference to any identifier in
@scheme[datum] is typeset as a sub-form non-terminal.}

@defform[(defthing id contract-expr-datum pre-flow ...)]{

Like @scheme[defproc], but for a non-procedure binding.}

@defform/subs[(defstruct struct-name ([field-name contract-expr-datum] ...)
                pre-flow ...)
              ([struct-name id
                            (id super-id)])]{

Similar to @scheme[defform] or @scheme[defproc], but for a structure
definition.}

@defform/subs[(schemegrammar maybe-literals id clause-datum ...+)
              ([maybe-literals code:blank
                               (code:line #:literals (literal-id ...))])]{

Creates a table to define the grammar of @scheme[id]. Each identifier
mentioned in a @scheme[clause-datum] is typeset as a non-terminal,
except for the identifiers listed as @scheme[literal-id]s, which are
typeset as with @scheme[scheme].}

@defform[(schemegrammar* maybe-literals [id clause-datum ...+] ...)]{

Like @scheme[schemegrammar], but for typesetting multiple productions
at once, aligned around the @litchar{=} and @litchar{|}.}

@; ------------------------------------------------------------------------
@section{Various String Forms}

@defproc[(defterm [pre-content any/c] ...) element?]{Typesets the given
content as a defined term (e.g., in italic).}

@defproc[(onscreen [pre-content any/c] ...) element?]{ Typesets the given
content as a string that appears in a GUI, such as the name of a
button.}

@defproc[(menuitem [menu-name string?] [item-name string?]) element?]{
Typesets the given combination of a GUI's menu and item name.}

@defproc[(file [pre-content any/c] ...) element?]{Typesets the given content
as a file name (e.g., in typewriter font and in in quotes).}

@defproc[(exec [pre-content any/c] ...) element?]{Typesets the given content
as a command line (e.g., in typewriter font).}

@; ------------------------------------------------------------------------
@section[#:tag "scribble:manual:section-links"]{Section Links}

@defproc[(secref [tag string?]) element?]{Inserts the hyperlinked
title of the section tagged @scheme[tag], but @scheme{aux-element}
items in the title content are omitted in the hyperlink label.}

@defproc[(seclink [tag string?] [pre-content any/c] ...) element?]{The content from
@scheme[pre-content] is hyperlinked to the section tagged @scheme[tag].}

@defproc[(schemelink [id symbol?] [pre-content any/c] ...) element?]{The content from
@scheme[pre-content] is hyperlinked to the definition of @scheme[id].}


@; ------------------------------------------------------------------------
@section{Indexing}

@defproc[(idefterm [pre-content any/c] ...) element?]{Combines
@scheme[as-index] and @scheme[defterm]. The content normally should be
plurarl, rather than singular.}

@defproc[(pidefterm [pre-content any/c] ...) element?]{Like
@scheme[idefterm], but plural: adds an ``s'' on the end of the content
for the index entry.}

@; ------------------------------------------------------------------------
@section{Miscellaneous}

@defthing[PLaneT string?]{@scheme["PLaneT"] (to help make sure you get
the letters in the right case).}

@defthing[void-const element?]{Returns an element for @|void-const|.}

@defthing[undefined-const element?]{Returns an element for @|undefined-const|.}

@defproc[(centerline [pre-flow any/c] ...) table?]{Produces a
centered table with the @scheme[pre-flow] parsed by
@scheme[decode-flow].}

@defproc[(commandline [pre-content any/c] ...) paragraph?]{Produces
an inset command-line example (e.g., in typewriter font).}