#!/usr/bin/env Rscript

library(here)
library(readr)
library(rmarkdown)
library(stringr)

slug <- commandArgs()

# render blog post
render(paste0(slug, ".Rmd"),
  output_file=here("site", "blog", slug, "index.html"),
  output_options = c(self_contained=FALSE))

render_site(here("site/blog.Rmd"))

# add nav html to blog post
blog_slug_html <- read_lines(here("site", "blog", slug, "index.html"))

# extract nav
blog_html <- read_lines(here("site", "site", "blog.html"))
blog_html_nav <- 
  str_extract(paste(blog_html, collapse=""), "<div class=\"navbar navbar-default  navbar-fixed-top\" role=\"navigation\">.*</div><!--/.navbar -->")

blog_slug_nav <- str_replace(blog_slug_html, "<div class=\"container-fluid main-container\">",
                             paste0("<div class=\"container-fluid main-container\">", 
                                    blog_html_nav, 
                                    "<div class=\"fluid-row\"><br /><br /></div>"))

# run the full site rendering
write_lines(blog_slug_nav, "index.html")

render_site(input=here("site"))
