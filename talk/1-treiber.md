
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
> > ### Lockfree stack interface  
> > {include src=1-treiber-interface.md}
>
> > ### Objective: Add a `size` function
> > {include src=1-treiber-objective.md}

> ### Lockfree stack implementation
> {include src=1-treiber-implem.md}

---

{change-page=carousel-treiber}

{reveal="compl"}

{reveal="obj"} 

{pause up}
<div style="background: #e8f4fd; border: 1px solid #4a90d9; border-radius: 5px; padding: 0.4em 1em; font-size: 1em; text-align: center; margin-top: 1em;">
📋 <strong>Setup</strong>: <code>git clone git@github.com:lyrm/bobkonf2026.git</code>. Full setup instructions in the README. </a>
</div>

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
<!-- > {.block .box reveal #ex2}
> > 📝 Exercise 2: race conditions on atomic operations
> > - A new implementation with an atomic size field
> > - Find a test that fails with `qcheck-lin`
> > - Find a trace of the bug with a model checker (`dscheck`)  -->


---



