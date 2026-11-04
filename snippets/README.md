# Snippet provenance and reference checks

All ten snippets in `salt.json` are original to this community continuation,
licensed Apache-2.0. No donor snippets or generated Salt signatures are used.
They are inert VS Code-format data, registered for both `salt` and `sls`.

Checked against Salt's current `latest` documentation on 2026-11-04:

| Prefix | Checked behavior | Primary reference |
| --- | --- | --- |
| `spkg` | `pkg.installed`, `name` | [Package states](https://docs.saltproject.io/en/latest/ref/states/all/salt.states.pkg.html#salt.states.pkg.installed) |
| `sfile` | `file.managed`, `source`, `user`, `group`, quoted `mode`; `salt://` source | [Managed files](https://docs.saltproject.io/en/latest/ref/states/all/salt.states.file.html#salt.states.file.managed) |
| `ssvc` | `service.running`, `enable: True` | [Running services](https://docs.saltproject.io/en/latest/ref/states/all/salt.states.service.html#salt.states.service.running) |
| `sinc` | List of included SLS names | [Include declaration](https://docs.saltproject.io/en/latest/ref/states/include.html) |
| `sreq`, `swatch`, `sonch` | `require`, `watch`, `onchanges` lists of state-module/ID pairs | [Requisites](https://docs.saltproject.io/en/latest/ref/states/requisites.html) |
| `smap` | `from ... import ... with context` | [Salt Jinja](https://docs.saltproject.io/en/latest/topics/jinja/index.html) |
| `spillar` | `salt['pillar.get'](key, default)` | [Pillar lookup](https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.pillar.html#salt.modules.pillar.get) |
| `sgrain` | `salt['grains.get'](key, default)` | [Grains lookup](https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.grains.html#salt.modules.grains.get) |

Replace placeholders with project-specific values. Lookup defaults are Jinja
expressions: quote string defaults. Requisite snippets are fragments to insert
at the argument-list indentation, not standalone states. State IDs supply the
implicit `name` where omitted. Tests decode the manifest and snippet JSON,
check both filetypes, and require unique prefixes; they never render a snippet
or execute Salt. Reference checks do not imply version-aware validation.
