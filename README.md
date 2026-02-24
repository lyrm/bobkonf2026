# Parallelism without panic: a user’s guide to multicore safety in OCaml
**Bobkonf**, March 13th 2026

## Setup

You can run the exercices in your browser, using the provided [devcontainer](https://containers.dev/) setup, in GitHub [Codespaces](https://github.com/features/codespaces). Just select “Create codespace on main” from the “Codespaces” tab in the “Code” menu. You'll get started in a few minutes. Alternative options that requires cloning this repo, include the following ones:

* Use your own OCaml environment, if you already have one installed, see [CONFIG](CONFIG.md) for details
* Launch the devcontainer in [VS Code](https://code.visualstudio.com/docs/devcontainers/containers) using “Dev Containers: Reopen in Container”
* Launch the [`devcontainer`](https://github.com/nodejs/devcontainer) tool on the command line (requires `npm`), inside the clone:
  * `npm install -g @devcontainers/cli`
  * `devcontainer up`
  * `devcontainer exec opam switch`

You can also use the [`gh`](https://cli.github.com/manual/gh_codespace) tool: `gh codespace ssh` (if you haven't created a codespace in your browser, you can do it using `gh codespace create lyrm/bobkonf2026`)
