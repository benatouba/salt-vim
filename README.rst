salt-vim — community continuation
================================

Portable Salt state editing for Vim and Neovim: YAML with embedded Jinja,
Salt renderer extensions, requisites, and conservative buffer-local defaults.

This is a community continuation of `SaltStack's original salt-vim
<https://github.com/vmware-archive/salt-vim>`_, not an official ownership
transfer or a VMware/Broadcom/Salt Project endorsement. Original history and
Apache-2.0 notices are preserved. See ``NOTICE`` for reviewed donor attribution.

Status: 0.1.0, the first community release. This plugin does not render
templates, execute Salt, install tools, format files, start language servers,
or discover project commands.

Requirements and installation
=============================

Use Vim with ``syntax/jinja.vim`` available (bundled by Vim 9.1.0735 and newer),
or Neovim 0.11+. The default provider is your editor's bundled Jinja syntax.
If your Vim runtime lacks it, install one generic Jinja provider such as
`HiPhish/jinja.vim <https://gitlab.com/HiPhish/jinja.vim>`_. Django syntax is
no longer a substitute for Jinja. Put salt-vim before the editor runtime on
``runtimepath``, as normal plugin managers do.

With Vim's native packages::

    git clone https://github.com/benatouba/salt-vim.git \
      ~/.vim/pack/community/start/salt-vim

Enable filetype plugins and highlighting in your vimrc::

    filetype plugin indent on
    syntax enable

For Neovim with lazy.nvim::

    { "benatouba/salt-vim", ft = { "salt", "sls" } }

Current Neovim already detects ``*.sls`` as ``salt``. Lazy managers that need
plugin detection for old runtimes, ``Saltfile`` or ``#!py`` must load this
plugin at startup instead (``lazy = false`` with lazy.nvim): a filetype trigger
cannot retroactively run a missed ``BufRead`` event.

Filetypes and syntax ownership
=============================

* ``salt`` is canonical; ``:setfiletype sls`` remains supported for existing
  configurations. Update lint, snippet and formatter filetype mappings when
  moving from the old ``sls`` default to ``salt``.
* Detects ``*.sls`` and ``Saltfile`` if no unrelated filetype is already set.
  Python-rendered SLS beginning with ``#!py`` (including a renderer pipeline)
  uses ``python`` instead. This is textual detection, never rendering.
* Ordinary ``*.yaml``, HTML and Jinja templates are not claimed by salt-vim.
* Loads YAML, then the **first** ``syntax/jinja.vim`` on ``runtimepath``.
  Runtime Jinja, pinned HiPhish and Glench syntax are covered by regression
  tests. No generic Jinja implementation is vendored. Additional generic
  providers can change behavior; do not stack competing Jinja plugins.
* With older Glench providers, HTML host loading is temporarily disabled while
  sourcing syntax and its previous setting restored, preventing Salt recursion.
  Only syntax is composed; salt-vim never loads Jinja's HTML-oriented indent
  or ftplugin. A separately installed provider may have its own global behavior.
* Requisite/typo groups are key-highlighting hints, not semantic validation.
  Salt Jinja extensions and injected globals have separate syntax groups.

Buffer settings
===============

Sets ``comments=:#``, ``commentstring=# %s`` and ``autoindent``. Recommended
style adds ``expandtab``, ``shiftwidth=2`` and ``softtabstop=2``. Disable just
the style defaults before opening a Salt buffer::

    let g:salt_recommended_style = 0

The standard ``g:filetype_recommended_style`` is the fallback. All changed
options have ``b:undo_ftplugin`` cleanup. No mappings, forced folding,
``formatoptions`` changes, regexp-engine changes, UTF-8 error matches, global
indent functions, or destructive ``clearmatches()`` calls are installed.
There is deliberately no mixed YAML/Jinja ``indentexpr`` yet.

Snippets
========

``package.json`` and ``snippets/salt.json`` provide a small set of original
VS Code-style snippets (``spkg``, ``sfile``, ``ssvc``, ``sinc``, ``sreq``,
``swatch``, ``sonch``, ``smap``, ``spillar``, ``sgrain``) for both ``salt`` and
``sls``. salt-vim does not load them itself; they are inert data for your
snippet engine. With LuaSnip::

    require("luasnip.loaders.from_vscode").lazy_load()

This discovers the manifest on ``runtimepath``. To opt out, use the loader's
``exclude`` option or simply do not call a loader; nothing else is affected.

Release policy
==============

Releases use annotated semantic-version tags. Before 1.0, a minor release may
change behavior; a patch release fixes defects without intentional behavior
changes. From 1.0, removing the ``sls`` filetype alias or raising the minimum
editor version is a breaking change. The supported baseline is Neovim 0.11 or
newer, or a Vim whose runtime provides ``syntax/jinja.vim`` (Vim 9.1.0735 or
newer). Install a tagged release when you want a stable snapshot instead of
tracking ``master``.

Migration from the archived plugin
=================================

Remove old manually copied runtime files before installing this continuation;
two Salt plugins on ``runtimepath`` can both install detection hooks. Existing
``sls`` configurations still work, but new automatic detection uses ``salt``.
The old ``g:sls_use_jinja_syntax`` Django/Jinja selector is retired. Existing
NERDCommenter delimiter dictionaries and user-defined highlights are preserved.
Unicode is valid YAML; the previous non-ASCII warning has been removed.

Diagnostics belong to an external integration: ALE commonly uses ``salt``;
nvim-lint/none-ls configurations may need an explicit ``salt``/``sls`` alias.
Use salt-lint for unrendered SLS, not plain yamllint. Choose one diagnostics
owner. Resolve tools and decide formatting policies in your editor/project;
salt-vim does not start any tool, including on save. Salt LSP is a separate
project and is outside this plugin's implementation scope.

Tests and current limits
========================

From the repository root::

    vim -Nu NONE -U NONE -i NONE -n -es -S tests/test.vim
    nvim -Nu NONE -U NONE -i NONE -n -es -S tests/test.vim

``vim`` must actually be Vim, not a Neovim alias. To exercise a different
Jinja syntax provider, set ``SALT_VIM_JINJA_PATH`` to its checkout. Tests load
only its syntax, not its detection, indentation or ftplugin. CI tests Neovim
nightly and stable with the runtime provider and with HiPhish and Glench at
pinned revisions, plus Neovim 0.11.5 and Vim 9.2 with the runtime provider.
Fixtures are synthetic and never rendered or executed. Tests cover quoted
and unquoted expressions, nested structures, templated keys, block scalars,
normal and whitespace-trimmed raw blocks, whitespace-control tags, Salt
extensions, detection, option undo, legacy filetypes, and all three regexp
engines.

The runtime, HiPhish and Glench raw regions do not accept whitespace control,
so ``syntax/salt.vim`` extends the provider's ``jinjaRaw`` group to recognize
``{%- raw -%}``. This covers editor runtimes that an upstream fix would not
reach, and remains harmless once a provider handles those delimiters itself.

Generic delimiter styling varies by provider, notably ``+`` on older runtime
Jinja. No automatic indentation or rendered-source mapping is promised. Snippets
and optional indentation/folds are later milestones, not bundled in this first
foundation. Syntax synchronizes from the start of the buffer for multiline
correctness; very large files may be slower.
