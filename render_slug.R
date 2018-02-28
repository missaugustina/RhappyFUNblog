#!/usr/bin/env Rscript

render_slug <- function(slug) {
  rmarkdown::render("site/blog/countering-bean-counting-commits/countering-bean-counting-commits.Rmd",
                    output_file="index.html",
                    output_options = c(self_contained=FALSE))
}