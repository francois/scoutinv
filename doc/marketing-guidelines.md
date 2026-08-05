# Scoutinv Landing Page Specification

## Goal

This page serves people who are not signed in. Its goal is to explain Scoutinv, build trust in its approach, and lead visitors to register or sign in.

The page is not a product screenshot. It is a Gazette: an editorial page that tells the story of equipment and demonstrates product benefits through concrete situations.

## Rails implementation constraints

- Create a separate marketing layout for the anonymous home page. The current layout includes a Foundation top bar, generic H1, and footer that conflict with this composition.
- Keep the application layout for signed-in users until the design system migration is complete.
- Convert static CTAs into real actions: registration must lead to the registration form; sign-in must lead to the email-link form already used by the app.
- Put every visible string in `fr.yml` and `en.yml`.
- Host the three font families in the asset pipeline and load them with `@font-face`.
- Do not use a Google Fonts `@import` in production.

## Container and responsive behaviour

| Element | Reference value |
| --- | --- |
| Content width | `min(1160px, calc(100% - 48px))` |
| Page background | `--paper` (`#f5eee2`) |
| Rules | 1 px `--ink`; 3 px double rule for header/footer |
| Desktop columns | CSS Grid with no gap; borders separate columns |
| Breakpoint | 720 px reference; 768 px is acceptable if used consistently in the app |
| Mobile | Every grid becomes one column, with a top border between articles |
| Mobile margins | 24 px minimum |

Do not use the Foundation Grid for the Gazette. Use scoped CSS Grid for marketing; Foundation may remain loaded during migration.

## Required content order

1. Brand header
2. “Les nouvelles du local” masthead
3. Three-article row
4. Sarah → Martin handover feature in three columns
5. MJ9 equipment sheet: illustration across two columns, details in one column
6. Three closing articles
7. Three-column pricing article
8. Gazette footer
9. Email sign-in popup, rendered above the page when activated

## Header

Left: Scoutinv wordmark.

Right:

- “Connexion” link opening the popup;
- primary “Inscrire mon groupe” CTA.

The header has a double rule beneath it. There are no secondary marketing links: the page is an editorial document, not a conventional site navigation bar.

## Masthead

Reference content:

```text
LA GAZETTE DU MATÉRIEL · ÉDITION DES RESPONSABLES
Les nouvelles du local
Un journal pour ce qui part à l’aventure et revient raconter son histoire.
```

The eyebrow uses small, tracked DM Mono. The title is centred, very large, and set in Newsreader. A rule closes the masthead.

## First row: three articles

Build a `0.8fr 1.4fr 0.8fr` grid.

### Left column — Maintenance

```text
ENTRETIEN
Le poêle D81 part en réparation.
Une fuite a été signalée au retour. Son numéro de série permet de le mettre de côté sans confondre les autres poêles du groupe.
```

### Centre column — Lead story

```text
À LA UNE
Votre matériel part à l’aventure. Gardez une trace de son retour.
Scoutinv réunit les sorties, les retours, les observations et les réparations. L’information reste avec le groupe, et avec chaque exemplaire de matériel.
```

This column contains the “Inscrire mon groupe” and “Connexion” CTAs.

### Right column — Next outing

```text
PROCHAINE SORTIE
Le poste prépare son week-end.
Trois tentes et le matériel cuisine sont confirmés. La hache N8C reste à localiser avant le départ.
```

## Handover feature

Title: “Sarah passe le matériel à Martin.”

Keep three value columns:

| Eyebrow | Heading | Point made |
| --- | --- | --- |
| AVANT | Sarah n’a pas à tout raconter de mémoire. | Locations, states, and recent outings are already recorded. |
| PENDANT | Martin apprend avec de vrais repères. | MJ9, N8C, and D81 are serial numbers for specific items. |
| APRÈS | La prochaine relève aura elle aussi un point de départ. | Outings and repairs enrich the group’s memory. |

This feature must demonstrate volunteer continuity; do not rewrite it as a productivity promise.

## MJ9 equipment sheet

Build a `2fr 1fr` grid: an editorial illustration of the tent on the left and a dark sheet on the right.

The sheet contains:

```text
FICHE MATÉRIEL
Tente prospecteur MJ9

DERNIÈRE SORTIE
Camp de printemps · unité des Éclaireurs

SIGNALÉ PAR L’UNITÉ
Problème avec la porte de la tente

PROCHAINE ÉTAPE
Vérifier si une réparation est nécessaire
```

The illustration may be CSS, an original photo, or generated artwork, but it must centre the object and its serial number. Do not use a generic camping stock photo.

## Closing articles

Use a three-column grid, with a distinct background for each article: light surface, sage, then ink.

| Eyebrow | Message |
| --- | --- |
| NOTE DE LA RÉDACTION | What Scoutinv retains for the group: useful small facts, without adding a new chore. |
| LE SAVIEZ-VOUS ? | A serial number tells one item’s story and prevents identical objects from being confused. |
| POUR VOTRE GROUPE | Create the journal of your equipment, with an “Inscrire mon groupe” CTA. |

## Pricing article

Add one final article with a shared heading, followed by a three-column grid. Reference content:

| Column | Content |
| --- | --- |
| Hosted version | `20 USD / 20 CAD / 20 EUR` **per year**. Scoutinv is hosted and maintained for the group. |
| Self-hosted | No licence fee; the group manages its own hosting and environment. |
| Open source | Scoutinv is GPLv2 software. The code can be studied, changed, and shared under that licence. Link: `https://github.com/francois/scoutinv`. |

The GitHub link must include the GitHub logo, an explicit “View the source code on GitHub” label, and accessible text or name. The logo must not be the only link affordance.

Do not build a complex pricing page or invent plan tiers. The yearly price communicates simplicity and affordability for volunteer groups.

## Email-link sign-in

### Demonstration state

The intended demonstration state displays:

```text
CONNEXION
Un lien, et c’est parti.
francois@teksol.info
Envoyer
LIEN ENVOYÉ
Un courriel de connexion vient d’être envoyé à francois@teksol.info.
```

This documents the intended success state. In production, the popup must be closed initially and show confirmation only after a successful server response.

### Production behaviour

- The “Connexion” button opens a modal dialog.
- The form sends the address to the real existing session endpoint; do not simulate sending in JavaScript.
- After success, show confirmation in an `aria-live="polite"` region.
- On error, retain the entered address, show the error next to the field, and keep the dialog open.
- Trap focus in the dialog; close with Escape and the close button; restore focus to the trigger.
- The dimmed backdrop is visual only; it must not leave the underlying page keyboard-accessible.

## Registration

The “Inscrire mon groupe” CTA must lead to the real registration form, ideally in a final section or dedicated flow. Reuse the logic from `_registration_form.html.erb`; do not create a second implementation of the same fields or submit data to `#`.

## Accessibility and quality

- One `<h1>` only: “Les nouvelles du local”.
- Preserve a meaningful heading hierarchy within articles.
- Serial numbers must never be communicated by colour or typography alone.
- Every button and link has an explicit accessible name.
- Images have useful `alt` text; decorative illustrations are marked decorative.
- Test contrast, visible focus, and rendering without web fonts.
- Do not display the demonstration popup by default in production.

## Acceptance checklist

- Desktop: first row, handover, closing, and pricing all render in three columns; the MJ9 sheet renders 2/1.
- Mobile: every column becomes vertical with no overlap or truncated text.
- “Inscrire mon groupe” leads to the real registration flow.
- “Connexion” opens the form, accepts an email address, and confirms the real send.
- The price is yearly, never monthly.
- The GPLv2 link leads to the GitHub repository with both a GitHub logo and label.
- French and English content are localized; no marketing strings are hard-coded.
