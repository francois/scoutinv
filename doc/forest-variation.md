# Forest / Cedar

A restrained, practical variation of Forest. PT Sans replaces editorial headings
with compact humanist typography; PT Mono gives dates and quantities a field-log
character. Warm cream paper, rust actions, olive greens, tighter spacing and
fine full panel borders keep the existing layouts intact. Cards rest flat.

## Typography

- Interface and headings: **PT Sans**, then Liberation Sans and bundled DM Sans.
- Labels and data: **PT Mono**, then Liberation Mono and bundled DM Mono.
- All explicitly selected families are open source.
- PT Sans: https://github.com/google/fonts/tree/main/ofl/ptsans
- PT Mono: https://github.com/google/fonts/tree/main/ofl/ptmono
- Liberation: https://github.com/liberationfonts/liberation-fonts
- Existing bundled fallback licenses live in `app/assets/fonts/OFL-*.txt`.

Installed fonts are preferred; there are no new font files, remote font services,
imports or preloads. Devices without the preferred families use the existing
self-hosted fallback, which may download on a cold cache. The fallback faces also
try `local()` before their asset URLs. Generic CSS fallbacks are a last resort for
missing glyphs or unavailable assets, not a promise about the OS font's license.

Compare the dashboard, inventory, an event's reservation cards and the logged-out
home page after changing the theme.

The variation also corrects the existing home-page locale filenames and an extra
closing tag in the registration form so both translated home pages render and
the desktop login panel stays inside its grid.
