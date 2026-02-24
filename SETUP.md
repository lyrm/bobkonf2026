# Local Setup

If you already have `opam` installed and initialized, create these three switches instead of using a devcontainer.

## `ocaml` switch

Standard OCaml 5.4.0 with tutorial dependencies.

```bash
opam switch create ocaml ocaml-base-compiler.5.4.0 --yes
```

```bash
opam install -y dune ocaml-lsp-server merlin utop alcotest dscheck qcheck-stm qcheck-lin
```

## `ocaml+tsan` switch

OCaml 5.4.0 with ThreadSanitizer enabled.

On Linux, you need to reduce ASLR entropy to build the TSan-enabled OCaml compiler:

```bash
sudo sysctl -w vm.mmap_rnd_bits=28
```

Have `libunwind-dev` and `pkg-config` installed on your system, before creating the switch, if they aren't already, although `opam` may trigger their installation.

```bash
opam switch create ocaml+tsan ocaml-variants.5.4.0+options ocaml-option-tsan --yes
```

```bash
opam install -y dune ocaml-lsp-server merlin utop alcotest dscheck qcheck-stm qcheck-lin
```

## `oxcaml` switch

OxCaml 5.2.0+ox from the Jane Street `opam` repository. Note: `utop` did not compile with OxCaml at the time of writing this document. Check `autoconf` and `rsync` are installed on your system, before creating the switch.

```bash
opam switch create oxcaml \
  --repos "ox=git+https://github.com/oxcaml/opam-repository.git,default" \
  ocaml-variants.5.2.0+ox --yes
```

```bash
opam install -y dune ocaml-lsp-server merlin alcotest dscheck qcheck-stm qcheck-lin
```
