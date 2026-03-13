{pause up}
### The tools exist

<style>
.tool-columns {
  display: flex;
  gap: 2em;
}
.tool-columns > :first-child {
  flex: 1;
  text-align: right;
}
.tool-columns > :last-child {
  flex: 2;
}
</style>

{.tool-columns}
---

> **TSan**
>
> **qcheck-lin** / **qcheck-stm**
>
> **dscheck**

> Detects data races at runtime
>
> Generates concurrent tests automatically and checks for linearizability
>
> Model-checks all interleavings of atomic operations

---
 

{pause}

### But some are still maturing

Especially **dscheck** :
- limited documentation, 
- does not work on projects with other synchronization mechanism like mutexes, condition variables, etc.

{pause}

### A good process

1. **Generate tests** with qcheck-lin (or qcheck-stm for richer specifications)
2. **Run them with TSan** to catch data races
3. **Feed failing scenarios to dscheck** to get a full trace of the bug

