
> > ## Multicore programming in OCaml
> >
> > {pause}
> > 
> >
> > {include src="ocaml-multicore-can.md"}
> >
> > {.block title="Domains"}
> > ---
> >
> > A domain in OCaml is a **parallel execution unit** that has its own minor heap, and execution stack.
> > Domains allow OCaml programs to run **code in parallel on multiple CPU cores** without a global runtime lock.
> >
> > {pause}
> >
> > **Rule of thumb:** Spawn the domains at the start of the world and keep them waiting until they are needed.