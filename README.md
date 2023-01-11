# Xranklin build action

```yml
name: Deploy

on:
  push:
    branches:
      - main

jobs:
  docs:
    runs-on: ubuntu-latest
    permissions: write-all
    steps:
      - uses: actions/checkout@v3
      - uses: tlienart/xranklin-build-action@main
        with:
          SITE_FOLDER: "docs/"
          BASE_URL_PREFIX: "Xranklin.jl"
          PYTHON_LIBS: "matplotlib pandas ansi2html"
          LUNR: true
```

## Action Options

None of the options are required, check the default values.

### Deployment Options

The overall picture is that you have a repo on GitHub e.g. `theRepo` which,
in it, has a folder which contains your files from which Franklin can generate
the website.
This can be the repo itself, or a folder in the repo (e.g. `docs/`).

For instance, for `Xranklin.jl` the repo has a folder `docs/` that has a
structure that should be familiar:

```
docs/
├── _assets
├── _css
├── _layout
├── ...
├── index.md
└── config.md
```

often, the repo itself is the folder (i.e. `./` instead of `docs/` in the
example above).

The Franklin process generates HTML files with the assumption that the landing
page will be at

```
[1]/[base_url_prefix]/[preview]/
```

where `[1]` can be

* `username.github.io`, in general,
* `some_other_place.ext`, if you use a custom URL (e.g. `julialang.org`)

and `[base_url_prefix]` and `[preview]` can both be empty or set specifically
(see table below).

<br>

| **Key** |  **Default** | **Purpose** | **Examples** |
| ------- | ------------ | ----------- | ----------- |
| `SITE_FOLDER` | `""`   | If given and not empty, a folder path **with** a trailing backslash. This is the location of the source folder in the repository (where the `config.md` and `utils.jl` files are expected to be found). If the repo itself is the source folder, leave empty. | `"docs/"`, ... |
| `BASE_URL_PREFIX` | `""` | If given and not empty, the base URL prefix for a project website **without** backslash. It indicates where the base path is, `/` by default and `/foo/` if set to `foo`. If deploying with GitHub, a user website (`username.github.io`) should leave it empty, a project website (`username.github.io/theRepo/`) should specify `"theRepo"`. | `"theRepo"`, ... |
| `PREVIEW` | `""` | Extension appended to `BASE_URL_PREFIX`, **without** backslash. This allows to have preview deployments with a separate path for testing. | `"preview"` (see also [this action](https://github.com/tlienart/Xranklin.jl/blob/main/.github/workflows/deploy.yml)), ... |
| `DEPLOY` | `true` | If set to false, the script will only attempt to build the website but not try to deploy it (i.e. won't try to copy the generated content of `__site`). This can be used for testing on a branch or fork when you don't have write-access to the repo's `gh-pages` branch. | {`false`,`true`} |
| `DEPLOY_BRANCH` | `"gh-pages"` | The branch on which to place generated content for deployment. This **must** match the branch selected for deployment in the repo pages settings (in general this should be left as is). | `"website"`, `"docs"`, ... | 
| `UPLOAD_ARTIFACTS` | `false` | If set to `true`, will upload the generated `__site` folder to github artifacts so it can be used in a separate job. This can be useful if you set `DEPLOY` to `false` and want to do the deployment manually in a separate job.<sup><a href="fn1">1</a></sup> | {`false`, `true`} |
| `LUNR` | `false` | If set to `true`, will install the [lunr.js](https://lunrjs.com/) dependencies and attempt to build the lunr index (lunr is a tool that can add a search to your website). | {`false`, `true`} |
| `LUNR_BUILDER` | `"_libs/lunr/build_index.js"` | If specified, the location _inside_ the `SITE_FOLDER` where the index builder script is (in general this should be left as is). | `"another/valid/path.js"`, ... |

<sup><a id="fn1">1</a></sup>This can be useful if you want to inspect the generated site or do the deployment yourself (e.g. place things on S3) (in which case you'd have a separate job that uses [download artifacts](https://github.com/actions/download-artifact), the artifact name is `website` and corresponds to the full content of `__site`.)


### Franklin options

For now these options should be left untouched.

| **Key** |  **Default** | **Purpose** |
| ------- | ------------ | ----------- |
| `JULIA_VERSION` | `'1'` | Julia version to use (see [julia setup docs](https://github.com/julia-actions/setup-julia)) |
| `FRANKLIN_REPO` | `"https://github.com/tlienart/Xranklin.jl"` | Where the Franklin code is (this will be removed when there's only one code base of course) |
| `FRANKLIN_VERSION` | `""` | The version to use if not the latest. |
| `FRANKLIN_BRANCH` | `""` | The branch to use if not `"main"`. This takes precedence over `FRANKLIN_VERSION` and will use the latest commit of the branch. |


### Build options

These are options for dependencies that need to be installed for your website to work properly (e.g. to install Gnuplot if your website makes use of that).
It also allows you to specify Julia code to run before and after the build process.

| **Key** |  **Default** | **Purpose** | **Examples** |
| ------- | ------------ | ----------- | ----------- |
| `JULIA_PRE` | `""` | If given and not empty, some Julia code to run prior to building the website. For instance, this can be used to install specific packages or download some data. Be mindful of `'` and `"` usage and add a trailing `;` to **every** line. Do not add comments. | `'using Pkg; Pkg.add(...)'`, `'include("pre_script.jl")'`, ... |
| `JULIA_POST` | `""` | Same as `JULIA_PRE` but run after building the website. The build state can be used here for instance by calling `cur_gc()`. | `'include("post_script.jl")'`, ... |
| `PYTHON_LIBS` | `""` | If given and not empty, the Python 3 libraries to pip-install | `"matplotlib pandas"`, ... |
| `DISPLAY_SERVER` | `""` | If you make use of Plots.jl on your website set this to `"xvfb-run"` | `"xvfb-run"`, ... |
| `LATEX` | `false` | Set this to `true` if you make use of packages that require LaTeX (e.g. PGFPlots.jl etc.) | {`false`, `true`} |
| `GNUPLOT` | `false` | Set this to `true` if you make use of GnuPlot (e.g. via Gaston.jl, Gnuplot.jl) | {`false`, `true`} |
