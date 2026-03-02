# Parallelism without panic: a user’s guide to multicore safety in OCaml
**Bobkonf**, March 13th 2026

## Setup

There are several options to set up your environment to run the exercises in this repository, depending on your preferences and existing setup. All options will provide an environment with OCaml 5.4.0 and the necessary dependencies to run the exercises, including the TSan-enabled OCaml compiler for the relevant exercises. 


--- 

### (Fastest option) Codespaces setup 
You can run the exercises in your browser, using the provided [devcontainer](https://containers.dev/) setup, in GitHub [Codespaces](https://github.com/features/codespaces). Just select “Create codespace on main” from the “Codespaces” tab in the “Code” menu. You'll get started in a few minutes. 

--- 
### (20-30 minutes) Local setup

If you already have your own OCaml environment installed, clone this repository and see [SETUP](SETUP.md) for details

---

### (A few minutes) Local devcontainer setup
You need to clone this repository first. 

#### VS Code

Launch the devcontainer in [VS Code](https://code.visualstudio.com/docs/devcontainers/containers) : 
- `CTRL+SHIFT+P` 
- select “Dev Containers: Reopen in Container” 
- choose the first container (not the oxcaml one). 

To close the container, select “Dev Containers: Reopen Folder Locally” from the same menu. 

#### Other editors
Launch the [`devcontainer`](https://github.com/nodejs/devcontainer) tool on the command line (requires `npm`), inside the clone:
  * `npm install -g @devcontainers/cli`
  * `devcontainer up`
  * `devcontainer exec opam switch`


--- 

### Remote Codespace (CLI)
You can also use the [`gh`](https://cli.github.com/manual/gh_codespace) tool: `gh codespace ssh` (if you haven't created a codespace in your browser, you can do it using `gh codespace create lyrm/bobkonf2026`)
