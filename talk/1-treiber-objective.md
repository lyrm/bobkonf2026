
{pause}

Obviously, we could just do:
```ocaml
let size t =
    List.length (Atomic.get t.stack)
```
{pause}
**But:** [O(n) in the size of the stack!]{style="color: crimson"}


{unreveal #obj}
---

<!-- {carousel #carousel-ex}
---- -->
> {.block .box}
> > Let's start our adventure, with our first pitfall. 


<!-- > #### First try:
> 
---- -->

---