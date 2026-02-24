# Abstract
OCaml has a reputation for keeping its promises: strong types, solid abstractions, and very few runtime surprises. Multicore parallelism changes the rules a bit: suddenly, we can encounter race conditions, the kind of bugs that only show up at 3 AM, disappear when you add a print statement, and return months later just to spite you. If we want to stay in OCaml’s comfort zone, we need good tools.

<!-- This talk takes a user’s tour through the current toolbox for multicore safety in OCaml. After a brief introduction to OCaml’s memory model, we explore the practical helpers available today, including a race detector (ThreadSanitizer), a model checker, and a property-based concurrency tester. These tools are similar, albeit less mature, to those found in other languages. However, we show that when combined, they already provide a surprisingly robust workflow for debugging multicore code without compromising your sanity. -->

In this tutorial, participants start from a buggy lock-free queue and work their way toward a correct implementation using the tools available today for multicore safety in OCaml: a race detector (ThreadSanitizer), property-based concurrency testing (QCheck-Lin), and a model checker (dscheck). Step by step, they will discover why standard testing falls short for concurrent code, learn to apply each tool to find specific classes of bugs, and fix them until the queue is fully correct. These tools are similar, albeit less mature, to those found in other languages, but when combined they already provide a surprisingly robust workflow for writing reliable multicore code.

At the end of the tutorial, we will also have a look at a more radical option: OxCaml, a promising but experimental mode-system extension inspired by Rust’s ownership model. The idea is simple: if you really dislike runtime bugs, or if you’re writing critical software, you shouldn’t just detect data races, you should make them statically impossible to write.

In brief, OCaml already provides the tools you need for everyday multicore safety, and OxCaml points toward an even more reassuring future for those who require the strongest guarantees.

# TODO 
- comparison with other languages/tools
- dscheck interface documentation 
- qcheck-stm gen interface 

Setup pour le 27 fevrier:
- dev-container
- add instructions if ocaml already set up
  - switch 5.4.0 
  - switch tsan 
  - install dscheck and qcheck-stm
  - clone the repo

## TODO Step 0
**WARNING** Keep the directive line of the abstract. 

- Write the general deroulé of the tutorial -> complete the todo list
  
- Start with a short introduction: 
  - SLIDE - How to set up the environment  
  - SLIDE - OCaml 5.0 -> Multicore (and effects) -> new type of bugs not caught by the type system!
  - CODE - Show the data structure 
      -> it's buggy but don't look this way, even an expert need to look carefully to find the bugs
    - CODE : some basic test: it works fine most of the time
      - but if we run it for a while, we can see some weird behaviors
      - other way to improve the likelihood of seeing the bugs: a synchronization mechanism, 
    - But we could still miss some! 
  - SLIDE So how to we ensure multicore safety in OCaml: same as for the other languages, we need tools! 
    - SLIDE Current state of the art in OCaml and 
    - CODE try it (+short comparison to what can be found in other languages)
      - CODE tsan to capture data races -> need a lot of tests -> qcheck-stm (or qcheck-lin)
      - CODE model checking (dscheck) for race conditions on atomic operation -> unitary testing -> can be help with qcheck-stm to define which tests to write in dscheck
    - SLIDE Finally, a more radical option: make data races statically impossible to write with OxCaml
      - QUIZ
   
  **Note**: the tutorial is not about OxCaml, but about the current state of the art in OCaml and how OxCaml can be a promising future direction. So we will spend more time on the first part, and only briefly introduce OxCaml at the end.
 

## Question 
- Niveau des étudiants 
- Pour le 27: instruction de set up ?

## General TODO 

**Part 1**  
- TODO general intro
- TODO introduction -> how to set up 
  - DONE docker containter -> codespaces, vscode, other editors
  - TODO standart installation  (pointers to the right documentation)
- DONE Plan of the tutorial
- TODO Some explanation about the data structure
  - clone the repo 
  - one slide explaning how its works
  - show the code

*First part of coding*
- TODO write the instructions 
- DONE spsc queue implementation
  - DONE define bugs to add (both data races and race conditions)
- WIP Some unit tests that can catch the bugs but not all the time
- TODO add more tests 
- TODO add comments to the code to explain the tests 
  
**Part 2**
- TODO some explanations about the bugs 
- TODO what kind of tools do we need ?
- TODO some explanation about Tsan + qcheck-stm

*Second part of coding*
- TODO write the instructions 
- WIP write qcheck-stm tests to capture the bugs
- TODO comment the code
- TODO try TSAN to see if the data races are caught
- TODO define which part of the test the user should write in qcheck-stm

**Part 3**
- TODO some explanations about dscheck
- TODO how to use it with qcheck-stm

*Third part of coding*
- TODO write the instructions 
- WIP write dscheck tests to capture the bugs
- TODO comment the code
- TODO have a flow of execution that works -> use qcheck-stm to define a missing test in dscheck 

**Part 4**
- TODO some explanations about OxCaml 
  - portable and contended
  - prevent sharing of mutable state without a specific API

*Fourth interactive part*
- TODO quiz

**Bonus**
- Do everything for a second  data structure with less tests written for the advanced audiance. 
- in a branch call advanced with the solution of the first part so `dune runtest` works without the user having to write the tests for the first part (and the advanced tests are not an issue for the first part)

# Tutorial Plan
1. Introduction to OCaml’s memory model
   - Race conditions and data races
   - What makes multicore safety hard 
     - No static guarantees,
     - Even full-coverage testing can miss bugs 
2. Existing tools (with comparison to other languages)
   - ThreadSanitizer
   - Model checking (dscheck)
   - Property-based concurrency testing (QCheck)
   - Model-based testing (QCheck-STM)
   - Limitations and caveats
3. Demonstration of a typical debugging workflow
4. Introduction to OxCaml and its ownership model
   - How OxCaml guarantees data race freedom
     - Portable and contended 
     - No sharing of mutable state (without a specific API)
     - **Exercises**: QCM with discussion 
5. Q&A and discussion on future directions

# Objectives: less talk more exercises 

- one single lock-fre data structure (MS queue with optimization) with several bugs
  - race conditions
  - data races  


# Discussion points
- 