
<!-- OxCaml provides:

*Safe control* over performance-critical aspects of program behavior, *in OCaml*. -->

{pause}

OxCaml is a superset of **OCaml** that adds modes, unboxed types, immutable arrays, labelled tuples, and more!

{Pause}
### Modes
Modes are deep properties of values tracked by the compiler:

- **Not types**: types describe what data is, modes describe how it is used
- **Inferred & checked**: like types, modes are inferred from definitions and checked for consistency by the type checker
- **Deep**: modes apply recursively to all components of structured data
- **Submoding**: values can freely move to more restrictive (greater) modes, but not to less restrictive ones
- **Backwards compatible**: each axis has a "legacy" default mode, so plain OCaml programs just work

{pause}
In particular, it provides:
- **Control:** over allocation and memory layout (locality axis)
- **Safe:** data-race freedom, memory safety (portability and contention axes)

{pause}
{.block .box style="text-align: center; font-size: 1.5em;"}
See [oxcaml.org](https://oxcaml.org)!

{pause}
![OxCaml](images/oxcaml-normal.svg){style="width: 20%; display:block; margin-left: auto; margin-top: -8em;"}



