# Sync Upstream Repo Fork

This is a Github Action used to merge changes from remote.  

This is forked from [mheene](https://github.com/mheene/sync-upstream-repo), with me adding authentication using [GitHub Token](https://docs.github.com/en/actions/reference/authentication-in-a-workflow) and downstream branch options due to the [default branch naming changes](https://github.com/github/renaming).

## Use case

- Perserve a repo while keeping up-to-date (rather than to clone it).
- Have a branch in sync with upstream, and pull changes into dev branch.

## Usage

Example github action:

```YAML
name: Sync Upstream

env:
  # Required, URL to upstream (fork base)
  UPSTREAM_URL: "https://gitlab.com/qemu-project/qemu.git"
  # Required, token to authenticate bot, could use ${{ secrets.GITHUB_TOKEN }} 
  # Over here, we use a PAT instead to authenticate workflow file changes.
  WORKFLOW_TOKEN: ${{ secrets.WORKFLOW_TOKEN }}
  # Optional, defaults to main
  UPSTREAM_BRANCH: "main"
  # Optional, defaults to UPSTREAM_BRANCH
  DOWNSTREAM_BRANCH: ""
  # Optional fetch arguments
  FETCH_ARGS: ""
  # Optional merge arguments
  MERGE_ARGS: ""
  # Optional push arguments
  PUSH_ARGS: ""

# This runs every day on 1801 UTC
on:
  schedule:
    - cron: '1 18 * * *'
  # Allows manual workflow run (must in default branch to work)
  workflow_dispatch:

jobs:
  build:
    steps:
      - name: GitHub Sync to Upstream Repository
        uses: kheubaum/sync-upstream-repo
        with: 
          upstream_repo: ${{ env.UPSTREAM_URL }}
          upstream_branch: ${{ env.UPSTREAM_BRANCH }}
          downstream_branch: ${{ env.DOWNSTREAM_BRANCH }}
          token: ${{ env.WORKFLOW_TOKEN }}
          fetch_args: ${{ env.FETCH_ARGS }}
          merge_args: ${{ env.MERGE_ARGS }}
          push_args: ${{ env.PUSH_ARGS }}
```

This action syncs your repo (merge changes from `remote`) at branch `main` with the upstream repo ``` https://github.com/dabreadman/go-web-proxy.git ``` every day on 1801 UTC.  
Do note GitHub Action scheduled workflow usually face delay as it is pushed onto a queue, the delay is usually within 1 hour long.

## Development

In [`action.yml`](https://github.com/kheubaum/sync-upstream-repo/blob/master/action.yml), we define `inputs`.  
We then pass these arguments into [`Dockerfile`](https://github.com/kheubaum/sync-upstream-repo/blob/master/Dockerfile), which then passed onto [`entrypoint.sh`](https://github.com/kheubaum/sync-upstream-repo/blob/master/entrypoint.sh).

`entrypoint.sh` does the heavy-lifting,

- Set up variables.
- Set up git config.
- Clone downstream repository.
- Fetch upstream repository.
- Attempt merge if behind, and push to downstream.
