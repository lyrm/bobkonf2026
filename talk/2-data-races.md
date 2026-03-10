## Data races in OCaml 5's memory model

{pause unreveal=data-race}

<style>
.box-columns {
  display: flex;
  gap: 1.5em;
}
.box-columns > :first-child {
  flex: 1.3;
}
.box-columns > :last-child {
  flex: 1;
  padding-left: 1em;
  align-self: center;
}
.inner-box {
  background: rgba(255, 255, 255, 0.5);
  border: 1px dashed #c8a050;
  border-radius: 8px;
  padding: 0.6em 1em;
  font-size: 0.9em;
}
.example-columns {
  display: flex;
  gap: 1.5em;
  align-items: center;
  margin-top: 0;
}
.example-columns h4 {
  margin-bottom: 0;
}
.example-columns > :first-child {
  flex: 1;
}
.example-columns > :last-child {
  flex: 1;
}
</style>

{.block .box}
> {.box-columns}
> > > A **data race** occurs when:
> > >
> > > 1. Two or more domains run in parallel,
> > > 2. at least two access the same mutable value,
> > > 3. and at least one of them writes to it
> > > 4. without a synchronization mechanism (like locks or atomic operations).
> > >
> > > {#data-race} 
> > > > [**An unpredictable bug**, caused by compiler and architecture optimization!]{style="color: crimson"}
> > > > 
> > > > But, in OCaml, a data race can't cause a crash. 
> > 
> > > 
> > > {.block .inner-box pause}
> > > > **Non-atomic mutable values in OCaml:**
> > > > - reference cells (`ref`)
> > > > - mutable record fields (`{mutable field : ...}`)
> > > > - arrays (`Array`)
{reveal=data-race}

{pause down}
{.example-columns}
---
> #### Example
> ```ocaml
> let a = ref 0 and b = ref 0
> 
> let d1 () =    let d2 () =
>   a := 1;        b := 1;
>   !b             !a
>
> let main () =
>   let h1 = Domain.spawn d1 in
>   let h2 = Domain.spawn d2 () in
>   Domain.join h1, Domain.join h2
>```

> {pause}
> Sequentially consistent results:
> - `r1 = 0, r2 = 1` (d2 runs first)
> - `r1 = 1, r2 = 0` (d1 runs first)
> - `r1 = 1, r2 = 1` (any other interleaving)
>
> {pause}
> [With a data race: `r1 = 0, r2 = 0` is possible!]{style="color: crimson; font-weight: bold;"}
---

