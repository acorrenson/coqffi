# `coqffi`

[![Travis][travis-shield]][travis-link]
[![Contributing][contributing-shield]][contributing-link]
[![Code of Conduct][conduct-shield]][conduct-link]
[![Zulip][zulip-shield]][zulip-link]

[travis-shield]: https://travis-ci.com/coq-community/coqffi.svg?branch=main
[travis-link]: https://travis-ci.com/coq-community/coqffi/builds

[contributing-shield]: https://img.shields.io/badge/contributions-welcome-%23f7931e.svg
[contributing-link]: https://github.com/coq-community/manifesto/blob/master/CONTRIBUTING.md

[conduct-shield]: https://img.shields.io/badge/%E2%9D%A4-code%20of%20conduct-%23f15a24.svg
[conduct-link]: https://github.com/coq-community/manifesto/blob/master/CODE_OF_CONDUCT.md

[zulip-shield]: https://img.shields.io/badge/chat-on%20zulip-%23c1272d.svg
[zulip-link]: https://coq.zulipchat.com/#narrow/stream/237663-coq-community-devs.20.26.20users



`coqffi` generates the necessary Coq boilerplate to use OCaml functions in a
Coq development, and configures the Coq extraction mechanism accordingly.

## Meta

- Author(s):
  - Thomas Letan
  - Li-yao Xia
  - Yann Régis-Gianas
  - Yannick Zakowski
- Coq-community maintainer(s):
  - Thomas Letan ([**@lthms**](https://github.com/lthms))
- License: [MIT License](LICENSE)
- Compatible Coq versions: 8.12 or later
- Compatible OCaml versions: 4.08 or later
- Additional dependencies:
  - [Cmdliner](http://erratique.ch/software/cmdliner) 1.0.4 or later
  - [Dune](https://dune.build) 2.5 or later
- Coq namespace: `CoqFFI`
- Related publication(s): none

## Building and installation instructions

Make sure your OPAM installation points to the official Coq repository
as documented [here](https://github.com/coq/opam-coq-archive), and
then, the following should work:

``` shell
git clone https://github.com/coq-community/coqffi.git
cd coqffi
opam install .
```

Alternatively, you can install `coqffi`’s dependencies (as listed in
the **Meta** section of the README), then build it.

```shell
git clone https://github.com/coq-community/coqffi.git
cd coqffi
./src-prepare.sh
dune build -p coq-coqffi
```

## Example

Suppose the following OCaml header file (`file.mli`) is given:

```ocaml
type fd

val std_out : fd
val fd_equal : fd -> fd -> bool

val openfile : string -> fd [@@impure]
val closefile : fd -> unit [@@impure]
val read_all : fd -> string [@@impure]
val write : fd -> string -> unit [@@impure]
```

`coqffi` then generates the necessary Coq boilerplate to use these
functions in a Coq development:

```coq
(* This file has been generated by coqffi. *)

Set Implicit Arguments.
Unset Strict Implicit.
Set Contextual Implicit.
Generalizable All Variables.

From CoqFFI Require Export Extraction.
From SimpleIO Require Import IO_Monad.
From CoqFFI Require Import Interface.

(** * Types *)

Axiom fd : Type.

Extract Constant fd => "Examples.File.fd".

(** * Pure functions *)

Axiom std_out : fd.
Axiom fd_equal : fd -> fd -> bool.

Extract Constant std_out => "Examples.File.std_out".
Extract Constant fd_equal => "Examples.File.fd_equal".

(** * Impure Primitives *)

(** ** Monad Definition *)

Class MonadFile (m : Type -> Type) : Type :=
  { openfile : string -> m fd
  ; closefile : fd -> m unit
  ; read_all : fd -> m string
  ; write : fd -> string -> m unit
  }.

(** ** [IO] Instance *)

Axiom io_openfile : string -> IO fd.
Axiom io_closefile : fd -> IO unit.
Axiom io_read_all : fd -> IO string.
Axiom io_write : fd -> string -> IO unit.

Extract Constant io_openfile
  => "(fun x0 k__ -> k__ (Examples.File.openfile x0))".
Extract Constant io_closefile
  => "(fun x0 k__ -> k__ (Examples.File.closefile x0))".
Extract Constant io_read_all
  => "(fun x0 k__ -> k__ (Examples.File.read_all x0))".
Extract Constant io_write
  => "(fun x0 x1 k__ -> k__ (Examples.File.write x0 x1))".

Instance IO_MonadFile : MonadFile IO :=
  { openfile := io_openfile
  ; closefile := io_closefile
  ; read_all := io_read_all
  ; write := io_write
  }.

(* The generated file ends here. *)
```

The generated module may introduce additional dependency to your
project. For instance, the `simple-io` feature (enabled by default)
generates the necessary boilerplate to use the impure primitives of
the input module within the `IO` monad introduced by the
`coq-simple-io` package.

See the `coqffi` man pages for more information on how to use it.
