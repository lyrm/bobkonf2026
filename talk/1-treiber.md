
<style>
.columns-2 {
  display: flex;
  font-size: 0.85em;
  gap: 1.5em;
}
.columns-2 > :first-child {
  width: 45%;
}
.columns-2 > :last-child {
  width: 55%;
}
.columns-2 h3 {
  margin-bottom: 0;
}
.columns-2 + .columns-2 {
  margin-top: 0;
}
</style>

{.columns-2 #phases}
---

{carousel #carousel-treiber }
> > ### Interface
> > {include src=1-treiber-interface.md}
>
> > ### Objective: Add a `size` function
> > {include src=1-treiber-objective.md}


{include src=1-treiber-implem.md}

---

{change-page=carousel-treiber}

{reveal="obj" unreveal="ex1 ex2"}

{pause up}
### First pitfall: mutable size field
<style>
.columns-2b {
  display: flex;
  font-size: 0.85em;
}
.columns-2b > :first-child {
  width: 60%;
}
.columns-2b > :last-child {
  width: 40%;
  align-self: center;
}
.columns-2b h3 {
  margin-bottom: 0;
}
.columns-2b + .columns-2b {
  margin-top: 0;
}
.box {
  background: #f1e7ba;
  border-left: 6px solid #ef9c3e;
  padding: 0.5em 1em;
  border-radius: 10px;
  margin-top: 0.5em;
}
</style>

{.columns-2b #phases}
---

{include src=1-treiber-ref-size.md}

> 
> > 
> {.block .box reveal #ex1}
> > 📝 Exercise 1: data races
> > - Build a test that consistently fails 
> > - Find a trace to the bug with ThreadSanitizer
> 
> {.block .box reveal #ex2}
> > 📝 Exercise 2: race conditions on atomic operations
> > - A new implementation with an atomic size field
> > - Find a test that fails with a test generator
> > - Find a trace of the bug with a model checker

---



