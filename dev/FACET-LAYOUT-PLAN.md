# Laying brain views out with facets -- considered and rejected

Drafted 2026-11-23, from the question of how to place region labels outside a
view with a leader line into it.
Every claim below was measured, and the measurement is given.

## Verdict: rejected, and why it will stay rejected

**Views must not be panels, because the user's grouping variable needs them.**

A brain figure's panels belong to whatever the researcher is comparing --
patients against controls, timepoints, models. `position_brain()` composes
every hemisphere and view into *one* panel precisely so that
`facet_grid(group ~ .)` gives one whole brain per group, which is the layout
people actually publish. Measured: that builds today, and renders two rows of
eight brains, one row per group.

Make views into panels and that is gone: `group x hemi x view` is sixteen
panels for two groups, and the brain stops reading as a brain.

This was decided once before and the reason was not written down, so it was
rediscovered from first principles. It is written down now.

Everything below is kept because the measurements are worth having -- several
are useful whatever the layout -- but the conclusion is: **the layout stays
as it is, and labelling is solved inside the label layer.**

### What this means for labels

The callout layer gets a whole panel of data, several views in it, and must
work out per-view bounds itself. That is tractable: split the flattened
geometry by `hemi` and `view`, take each one's bounding box, and place labels
against that box rather than against the figure. My first attempt used
figure-wide bounds and produced 89 labels in two columns with leader lines
crossing three brains, which is what the rest of this document was a reaction
to.

Open questions for that work, in order of how much they matter:

1. Where does "outside" go when views sit side by side? Outside a middle view
   is on top of its neighbour. Candidates: above and below each view rather
   than left and right; outside the whole composition with leader lines routed
   per view; or a gap between views that appears only when callouts are used.
2. Is labelling every region ever worth supporting? Eight regions across eight
   brains is already dense. The realistic use is a handful of named regions,
   and optimising for that may make question 1 moot.
3. Does a callout layer need to refuse multi-view plots rather than silently
   produce the mess? Refusing is honest; so is laying out per view and letting
   the user judge.

## Why this came up

Labelling made the current layout's cost visible.
`position_brain()` lays views out by **rewriting coordinates** into one shared
panel, so a layer that needs to know where a view begins and ends has to
rediscover that from the data.
A callout layer did, got it wrong, and produced 89 labels stacked in two
columns at the figure's edges with leader lines crossing three brains.

Under facets the question does not arise: each view is a panel, ggplot2 hands
a layer its panel's data, and "outside this view" is simply "outside this
panel".

The gains are wider than labelling:

- strip labels do what `annotate_brain()` was written for
- `facet_grid(group ~ view)` is the layout people keep asking for
- zoom, limits and scales become per-panel concepts ggplot2 already owns
- users get a vocabulary they already know

## What is true today, measured

**Faceting already works.** `facet_wrap(~ view)` with `position = "identity"`
builds. Nothing needs to be added for the simple case.

**Free scales are forbidden.** `facet_wrap(~ view, scales = "free")` errors:

    `facet_wrap()` can't use free scales with `coord_cartesian()` with a fixed
    `ratio` argument.

`geom_brain()` supplies `coord_brain()`, which fixes the ratio so a brain is
not drawn distorted. That is not negotiable, so **free scales are not
available**.

**With fixed scales, the panels are mostly empty.** The atlas's views carry
absolute offsets -- for `dk`'s left hemisphere, `inferior` sits at x 50-200,
`lateral` at 250-450, `medial` at 500-750, `superior` at 750-950 -- so every
panel spans the full 0-1000 range and each brain occupies a quarter of it.

**Re-centring fixes that.** Centring each view on its own origin gives four
views spanning 213, 215, 215 and 214 units: near-identical ranges, so fixed
scales fit every panel. This is the key enabling change, and it is a change to
what `position = "identity"` means.

**`facet_grid(group ~ view)` fails today.**

    At least one layer must contain all faceting variables: `view`

ggplot2 resolves facet variables against layer data before the stat runs, and
a user's data frame has `region` and `group`, not `view`.
`facet_grid(group ~ .)` builds, because `group` is in their data.
This is the single biggest blocker, and the one the maintainer explicitly
wants solved.

**Zoom is already compatible, and this is the pleasant surprise.**
`zoom` crops each view "to a common window centred on its focus regions" --
equal-sized windows, which is exactly what fixed scales need.
Zoom can stay a data transform and keep working, provided re-centring happens
after it.

## The shape of the answer: no facet of our own

The `group ~ view` failure looked like it demanded a `facet_brain()`. It does
not. Measured: the same plot, with the same user data, **builds** as soon as
the data carries a `view` column --

    rows without view: 12 | with view: 22
    facet_grid(group ~ view) with view in data: BUILDS

ggplot2's facets were never the obstacle. Ours is: `LayerBrain$setup_layer()`
emits one row per *region* when the user supplies data, because joining the
views in would multiply the rows, and facet variables are resolved against
that data before the stat runs. The post-stat data does carry `view` and
`hemi` -- too late for the facet.

**It is `hemi` as well as `view`.** A cortical atlas is positioned by both --
left and right, lateral and medial -- so the default layout is
`hemi ~ view`, and both variables have to arrive. Measured, with the same
user data carrying both:

    facet_grid(hemi ~ view), plain      ERROR: at least one layer must contain...
    facet_grid(hemi ~ view), w/ cols    BUILDS
    facet_grid(group ~ hemi + view)     BUILDS
    facet_wrap(~ hemi + view)           BUILDS

So the user's grouping variable, the hemispheres and the views compose in
stock `facet_grid()` with nothing added.

So the work is **in the layer, not in a facet**: make the brain's own
variables reach the facet resolver. Then `facet_wrap()`, `facet_grid()`,
`facet_null()`, and third-party facets like `ggh4x`'s all work, with none of
their strip, spacing or scale behaviour reimplemented. That is the difference
between a feature and a maintenance burden: a hand-rolled facet would owe
users every variant ggplot2 ships, forever.

Two ways to get `hemi` and `view` there, to be decided by trying them:

1. emit per-hemi-per-view rows from `setup_layer()` -- correct, but this is
   exactly the row multiplication the current code avoids: six regions over
   two groups go from 12 rows to 42 for `dk`, and a region appears in every
   hemi x view it is drawn in
2. attach the two columns without multiplying rows, so the facet can resolve
   them while the stat still expands per view

Route 1's cost is the thing to measure at `schaefer-1000`, not at `dk`.

Re-centring remains ours regardless, since it is about the atlas's
coordinates, not about facets.

## What this costs users, which is the part to get right

**Every existing figure changes.** Not subtly: panel strips appear, spacing
changes, the single-panel composition becomes a grid.
Every vdiffr snapshot in the suite will change, and so will every figure in
every vignette, the README, and the pkgdown site.

So:

- `position_brain()` keeps working for a full release, deprecated but intact,
  so a user pins their old figures by doing nothing
- the new layout is opt-in first -- the user writes `facet_wrap(~ view)`
  themselves -- and only becomes the default once the examples all render
- the NEWS entry leads with the visual change, not the mechanism
- a vignette section shows the before and after side by side, and says plainly
  which argument restores the old look
- the snapshot churn lands in one commit, reviewed as "these all changed
  because the layout changed", never mixed with behavioural work

## Examples that must exist before it ships

The maintainer named these as the point of the exercise, so they are
acceptance criteria rather than documentation chores:

1. `facet_wrap(~ view)` alone -- the four-view layout, filling its panels
2. with a user's grouping variable in rows: patients over controls, views
   across -- the case that errors today
3. with the user's variable in columns and views in rows
4. zoomed onto a handful of regions, with and without a grouping variable
5. with region labels, both on the regions and outside the panel with leader
   lines -- the thing that started this
6. a faceted plot that keeps the old single-panel look, for a reader who wants
   their figure back

## Stages

Each stage is finished when its examples render correctly and the suite is
green, not when the code exists.

**1. Per-view re-centring.** Behind an argument, default off. Prove that
`facet_wrap(~ view)` then fills its panels (the 213-215 measurement above is
the target).

**2. `hemi` and `view` reach the facet resolver.** The layer's pre-stat data
carries both, so stock `facet_grid(hemi ~ view)` works with user data.
Examples 1 and 5.

**3. Grouping variables.** No new API: `facet_grid(group ~ hemi + view)` is
the answer, and it already builds when the data carries both. Examples 2 and 3
-- this is the acceptance test for the whole exercise.

**4. Zoom.** Confirm the common-window crop survives, per panel, with and
without grouping. Example 4.

**5. Default switch.** `geom_brain()` facets by view when the plot has no
facet of its own, `position_brain()` deprecated with a pointer. Example 6,
the snapshot churn commit, and the vignette rewrite.

## Open questions

- Which of the two routes gets `hemi` and `view` to the facet resolver
  without the row multiplication the current code avoids, and what does each
  cost at schaefer-1000 scale? (`dk` goes 12 rows to 42 on a six-region
  example; the question is what 1000 regions do.)
- A subcortical or tract atlas has views but one hemisphere, or none. Does the
  default layout become `hemi ~ view` only where `hemi` varies, and what does
  a one-row grid look like?
- How does a plot know to facet by default without taking the decision away
  from a user who wants `facet_null()`? `geom_brain()` already returns a list
  of layers plus a coord, so adding a facet to that list is possible -- but a
  facet the user cannot override would be worse than the current layout.
- What happens to `position_brain()`'s formula layouts (`~ hemi + view`)?
  `facet_grid()` expresses most of them; the ones it cannot express are worth
  listing before deprecating anything.
- Does `annotate_brain()` retire into strip labels, or keep working for people
  who want labels inside the panel?
- `coord_brain()`'s fixed ratio is what forbids free scales. Is a per-panel
  ratio possible inside a custom facet, and would that remove the need for
  re-centring altogether?
