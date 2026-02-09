## Race conditions

{pause unreveal=race-cond}

{.block .box}
> A **race condition** occurs when the behavior of a program depends on the relative timing of events, such as the interleaving of operations from different threads.
> 
> [Is not necessarily a bug!]{#race-cond}

{pause reveal=race-cond}

{pause}

#### Example

```ocaml
let () =
  let d1 = Domain.spawn (fun () -> print_endline "Hello from domain 1") in
  let d2 = Domain.spawn (fun () -> print_endline "Hello from domain 2") in
  Domain.join d1;
  Domain.join d2
```

{pause}

<style>
.results {
  display: flex;
  justify-content: flex-start;
  align-items: center;
  gap: 1.5em;
}
.results > * {
  flex: 0 0 auto;
}
.results .label {
  font-style: italic;
  color: #888;
}
</style>

<div class="results">

<span class="label">Could result in:</span>

```
Hello from domain 1
Hello from domain 2
```

<span class="label">or</span>

```
Hello from domain 2
Hello from domain 1
```

</div>