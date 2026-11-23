# Placing region labels: what the prior art says

Drafted 2026-11-23 after reading the sources of ggrepel 0.9.8, ggpp 0.6.1,
ggforce (main), directlabels (master), ggfittext 0.10.4, shadowtext 0.1.6 and
ggtext 0.2.0 / gridtext 0.1.6.

The goal: name a few chosen regions well, let someone name all of them if they
insist, be honest when that is illegible, and give control over placement
without inventing a dozen arguments.

## A correction first

I claimed text has no width in data units, and built around that. **It is
false.** Inside `makeContent()`, with the panel viewport pushed:

    convertWidth(grobWidth(textGrob(label)), "native", valueOnly = TRUE)

With `xscale = c(0, 215)` (a `dk` view) at 8pt:

| label                                | native width | as % of view |
| ------------------------------------ | ------------ | ------------ |
| `banks of superior temporal sulcus`  | 51.04        | 24%          |
| `rostral\nmiddle\nfrontal` (wrapped) | 10.05        | 5%           |

So "does this name fit in this region" is answerable, not a matter of taste.

**The trap:** with no device open the same call returns a plausible wrong
number (119.64) rather than erroring. This logic may live only in
`makeContent()`, never in `setup_data()` or a stat.

## We already compute the fit and throw it away

`widest_run_at()` in `R/geom-brain-text.R` returns `width` -- the widest
interior horizontal run of the polygon, in data units -- and
`scanline_anchor()` uses it to pick the best scanline and then discards it.
That number is exactly the box width a fit test needs.

Extending it to an **inscribed rectangle** is ~20 lines on code whose
correctness is already reasoned about: group consecutive scanlines whose runs
overlap in x, intersect their x-intervals, take the y-extent, maximise the
resulting fitted font size. No dependency, and it avoids the thing that makes
bounding boxes wrong here -- a crescent region's bbox covers its neighbours.

## Three ideas worth taking, from three packages

**1. ggpp's column contract (adopt).** Three orthogonal knobs over one
convention:

- a position writes `x_orig`/`y_orig` alongside the moved `x`/`y`
- the geom draws the connector from `(x, y)` to `(x_orig, y_orig)`, and
  disables itself silently when those columns are absent:
  `add.segments <- add.segments && any(c("x_orig","y_orig") %in% names(data))`
- `hjust = "position"` derives justification from `sign(x_orig - x)`, so text
  faces away from its anchor without being told

ggrepel writes the same two columns, so the convention interoperates with
both. Also worth copying verbatim: `shrink_segments()` (~25 lines) which pulls
the connector in from the text box by `box.padding` and off the anchor by
`point.padding`, flagging segments shorter than `min.segment.length` as
`nullGrob()`.

**2. ggfittext's two-stage fit (adopt the logic, not the package).** Reflow
_then_ shrink, in that order:

- enumerate candidate wraps at every whitespace position, measure each
- if any fits, take the **widest** that does (fewest lines)
- if none fits, take the wrap whose **aspect ratio best matches the box**,
  then one-shot linear rescale: `target <- box_dim * fontsize / text_dim`,
  min of the two axes

The aspect-ratio match is the cleverest part: for a near-square region,
"rostral middle frontal" on three lines matches the box far better than on
one, so the shrink afterwards costs much less size.

**3. directlabels' `method =` interface (adopt the interface, not the
implementation).** One argument with a short, speakable vocabulary beats a
dozen `label.*` arguments. For brain regions the vocabulary is anatomical
rather than invented:

| method      | meaning                                           |
| ----------- | ------------------------------------------------- |
| `"inside"`  | the current anchor, fitted to the region          |
| `"outside"` | callout: text outside the outline, leader line in |
| `"gutter"`  | stacked in a fixed column beside the view         |
| manual      | per-region override, à la `dl.move()`             |

What not to copy from it: methods resolved by bare `get()`, positioning
functions that draw as a side effect, and an informal data.frame column
contract every step must honour by convention.

## Legibility over an unknown fill

The fill belongs to a _different layer_, possibly under the user's own
continuous scale. So contrast-based text colour (ggfittext's `contrast`, which
inverts when CIE L\* < 50) would require re-deriving the rendered fill per
region by replaying the scale -- fragile, and broken by `scale_*_manual`,
alpha, or any later scale change.

Prefer the fill-independent options, in order:

1. **Halo**, inlined: 16 offsets at `unit(cos(theta) * r, "strheight", data = "X")`
   with the label on top -- ~15 lines of grid, radius relative to cap height
   so it scales with font size. Expose `bg.colour`/`bg.r` as aesthetics with
   `bg.colour = NULL` as the opt-out, as shadowtext does.
2. **Translucent plate** drawn from the dimensions we already measured, if
   halos read as too cartoonish for publication.
3. Contrast inversion only as an extra, only for greyscale text.

## Dependencies: take none of them

| package           | cost                                                                           |
| ----------------- | ------------------------------------------------------------------------------ |
| ggpp              | 16 Imports incl. `xts`, `zoo`, `polynom`, `dplyr`, `gridExtra`                 |
| shadowtext        | pulls `ggiraph`                                                                |
| ggtext / gridtext | `Rcpp`, `markdown`, `png`, `jpeg`, `curl`; a markdown parse per label per draw |
| ggforce           | `polyclip`, and its search is the wrong shape for our data                     |
| ggrepel           | light, but see below                                                           |

The three mechanisms actually wanted -- native-unit measurement,
aspect-matched reflow, the 16-offset halo -- are about 60 lines against
`grid`, which is already an Import.

## Why repulsion is not the default

ggrepel repels against **its own layer's rows only**. It cannot see the
polygons, the outlines, or the gutters between composed views, so on a
coordinate-shifted panel of 70-140 anchors it parks labels in the corpus
callosum and between views. It is RNG-dependent without `seed`, computed at
draw time in device space (so its result cannot be tested or reported), and
its own docs say `hjust`/`vjust` are not preserved under repulsion. It also
drops labels silently once `max.overlaps` is exceeded -- and since 0.9.8 the
notice is behind `verbose`.

It stays a thing a user can compose themselves. It is not what we build on.

## Room: what a layer can and cannot do

ggforce's `geom_mark_*()` does find room at draw time, and the architecture is
available to any layer: `draw_panel` returns `gTree(cl = ...)`,
`makeContent()` converts to millimetres with `convertX/convertY`, reads the
panel with `unit(1, "npc")`, and searches the free space.

But it **cannot create space**. Panel size and scale limits are settled long
before `makeContent()` runs. ggforce's answer when nothing fits is
`nullGrob()` -- silently nothing. directlabels' is to push the label off-panel
to be clipped. Neither is acceptable for an anatomy figure.

So: expanding limits stays the only way to manufacture room, and stays an
explicit opt-in. Draw-time search decides _where_, never _whether there is_.

Two cautions if we borrow the search:

- Do not run exact Minkowski/polyclip over 35-100 concave atlas polygons on
  every draw. directlabels' discrete occupancy grid (`empty.grid`) is the
  cheaper primitive, and `sf` -- already in the tree -- can do the buffering
  without adding `polyclip`. **Measure first**: the objection is from the
  algorithm's shape, not a timing.
- Draw-time placement makes vdiffr snapshots high-churn and uninformative.
  Test the placement function directly -- given these obstacles and this label
  size, is the chosen point non-overlapping and nearest the anchor -- not only
  through images.

## The decision both packages dodge

Neither says what to do when a label does not fit: ggforce drops it silently,
ggfittext drops it below `min.size` silently, directlabels pushes it off the
panel, ggrepel drops it and mentions it only under `verbose`.

For an anatomy figure a silently missing region name reads as a data error.
Ours should **say so**: a message naming how many labels were dropped and
which regions, gated like ggrepel's `verbose` but on by default, because the
alternative is a figure that lies quietly.

## What this makes the implementation

1. inscribed rectangle from the existing scanlines (~20 lines)
2. measure in `makeContent()`, reflow by aspect match, then shrink (~40 lines)
3. `method = c("inside", "outside", "gutter")`, one argument
4. the `x_orig`/`y_orig` contract plus `shrink_segments()` for connectors
5. halo inlined, `bg.colour`/`bg.r` as aesthetics
6. an honest message when labels are dropped
7. `display` stays the text, since a curated short name beats any algorithmic
   abbreviation of "banks of superior temporal sulcus"
