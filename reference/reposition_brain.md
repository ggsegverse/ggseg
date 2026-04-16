# Reposition brain slices

Function for repositioning pre-joined atlas data (i.e. data and atlas
already joined to a single data frame). This makes it possible for users
to reposition the geometry data for the atlas for control over final
plot layout. For even more detailed control over the positioning, the
"hemi" and "view" columns should be converted into factors and ordered
by wanted order of appearance.

## Usage

``` r
reposition_brain(
  data,
  position = "horizontal",
  nrow = NULL,
  ncol = NULL,
  views = NULL
)
```

## Arguments

- data:

  sf-data.frame of joined brain atlas and data

- position:

  Position formula for slices. For cortical atlases, use formulas like
  \`hemi ~ view\`. For subcortical/tract atlases, use "horizontal",
  "vertical", or \`type ~ .\` for type-based layout.

- nrow:

  Number of rows for grid layout (subcortical/tract only)

- ncol:

  Number of columns for grid layout (subcortical/tract only)

- views:

  Character vector specifying view order (subcortical/tract only)

## Value

sf-data.frame with re-positioned slices

## Examples

``` r
reposition_brain(dk(), hemi ~ view)
reposition_brain(dk(), view ~ hemi)
reposition_brain(dk(), hemi + view ~ .)
reposition_brain(dk(), . ~ hemi + view)

# \donttest{
reposition_brain(aseg(), nrow = 2)
reposition_brain(aseg(), views = c("sagittal", "axial_3"))
# }
```
