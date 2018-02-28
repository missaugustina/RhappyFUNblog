#!/usr/bin/env Rscript

slug <- commandArgs()
path <- paste0("site/blog/", slug, "/")

# render blog post
rmarkdown::render(paste0(path, slug, ".Rmd"),
  output_file="index.html",
  output_options = c(self_contained=FALSE))

# add nav html to blog post

blog_html <- readr::read_lines(paste0(path, "index.html"))
blog_nav_html <- readr::read_lines("blog_nav.html")

blog_html_nav <- stringr::str_replace(blog_html, "<div class=\"container-fluid main-container\">", 
                                      paste(blog_nav_html, collapse=""))
# run the full site rendering
readr::write_lines(blog_html_nav, paste0(path, "index.html"))

setwd("site")
rmarkdown::render_site()
