salt-vim — community continuation
================================

Portable Salt state editing for Vim and Neovim: YAML with embedded Jinja,
Salt renderer extensions, requisites, and conservative buffer-local defaults.

This is a community continuation of `SaltStack's original salt-vim
<https://github.com/vmware-archive/salt-vim>`_, not an official ownership
transfer or a VMware/Broadcom/Salt Project endorsement. Original history and
Apache-2.0 notices are preserved. See ``NOTICE`` for reviewed donor attribution.

Status: 0.2.0, adding snippets and a large-file sync opt-out. This plugin does not render
templates, execute Salt, install tools, format files, start language servers,
or discover project commands.

Unreleased: independent opt-in conservative indentation and mixed YAML/Jinja
folds, with regression fixtures for all three syntax providers.

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

Optional indentation and folds
==============================

Both features are off by default. Set either option before opening a buffer::

    let g:salt_indent = 1
    let g:salt_folds = 1

Indentation installs an autoloaded ``indentexpr`` for standalone Jinja blocks,
including nested controls, ``else``/``elif``, trimmed tags and Salt's
``load_yaml``/``load_json``/``load_text`` blocks. It aligns standalone template
controls with their nesting and matches closing tags to openers. It retains
existing YAML indentation exactly: adding YAML indentation for a Jinja loop
would change the rendered mapping hierarchy. It does not reconstruct YAML from
flattened or incorrectly indented input: sibling boundaries are ambiguous.
Block scalar content, raw/``load_text`` bodies and Jinja comments are left
alone. Trailing-only whitespace-control tags and raw/text closing prefixes
retain their indentation because those spaces can become rendered data.
Inline and multiline template statements are not reflowed. Review
reindentation changes as with any indentation tool; this is not a YAML/Jinja
parser or a formatter. New blank lines inherit the preceding YAML indentation,
increasing it after mapping headers, without adding template depth to YAML.

Folding installs ``foldmethod=expr`` and an autoloaded ``foldexpr``. It combines
YAML indentation depth with standalone Jinja blocks, including top-level
template blocks missed by plain indentation folds. Raw bodies and block scalars
do not introduce template folds. It leaves ``foldlevel``, ``foldenable`` and
other opening preferences alone. Both features support ``salt`` and ``sls``;
all installed options and cached state are cleaned up on filetype changes.
Neither feature loads a provider's indentation code or any donor fold code.

The indentation expression scans a structural snapshot; folding caches its
scan until the buffer or indentation width changes. These features are opt-in
and are not intended as a large-file performance optimization.

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
See ``snippets/README.md`` for origins and current Salt reference checks.

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
Jinja. No rendered-source mapping or general-purpose YAML repair is promised.
Optional indentation/folds are covered by reindentation, idempotence, fold
level, default-off, independent opt-in and filetype-undo regression tests.
Syntax synchronizes from the start of the buffer for multiline
correctness. On a synthetic 45,000-line state this took about 4.8 s for the
first jump to the end of the buffer, against about 0.1 s with a bounded sync.
Large-file users can trade some multiline accuracy for speed::

    let g:salt_syntax_sync_fromstart = 0

This switches to ``syntax sync minlines=200``.
