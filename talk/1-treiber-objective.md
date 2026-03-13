
Obviously, we could just do:
```ocaml
let size t =
    List.length (Atomic.get t.stack)
```

{#compl}
**But:** [O(n) in the size of the stack!]{style="color: crimson"}


> {.block .box #obj}
> > Let's start our adventure, with our first pitfall. 
