#!/usr/bin/env Rscript

library(here)
library(purrr)
library(readr)
library(rmarkdown)
library(stringr)

slug <- commandArgs()

# render blog post
render(here::here("site", "blog", slug, paste0(slug, ".Rmd")),
  output_file=here::here("site", "blog", slug, "index.html"),
  output_options = c(self_contained=FALSE))

render_site(here::here("site", "blog.Rmd"))

# add nav html to blog post
blog_slug_html <- read_lines(here::here("site", "blog", slug, "index.html"))

# extract nav
blog_html <- read_lines(here::here("site", "www", "blog.html"))
blog_html_nav <- 
  str_extract(paste(blog_html, collapse=""), "<div class=\"navbar navbar-default  navbar-fixed-top\" role=\"navigation\">.*</div><!--/.navbar -->")

blog_html_nav <- str_replace_all(blog_html_nav, "href=\"", "href=\"../../")

# add navigation to blog entries
blog_slug_nav <- str_replace(blog_slug_html, "<div class=\"container-fluid main-container\">",
                             paste0("<div class=\"container-fluid main-container\">", 
                                    blog_html_nav, 
                                    "<div class=\"fluid-row\">test<br />test<br />test<br />test<br />test<br /></div>"))

# add github link to blog entries
blog_slug_nav <- str_replace(blog_slug_nav, "</body>",
                              paste0("<div class=\"fluid-row\"><p align=\"center\"><a href=\"",
                              "https://github.com/missaugustina/RhappyFUNblog/blob/master/", 
                              "site/blog/", slug, "/", slug, ".Rmd\">",
                              "This post is available as Rmarkdown on Github",
                              "</a></p></div></body>"))

# remove mathjax (assuming this isn't wanted - if it is in the future then this needs to be modified)
#  tried passing all kinds of donotwant for this but nothing seemed to work, so resorting to this
mathjax_line <- which(str_detect(blog_slug_nav, "<!-- dynamically load mathjax for compatibility with self-contained -->"))
print(paste("removing", blog_slug_nav[mathjax_line:(mathjax_line+8)]))
blog_slug_nav[mathjax_line:(mathjax_line+8)] = ""

# run the full site rendering
write_lines(blog_slug_nav, here::here("site", "blog", slug,"index.html"))

# Something is breaking the navigation layout when running render_site and passing in all files
# render_site(here::here("site"))
site_files <- list.files(path=here::here("site"), pattern="*.Rmd", full.names = FALSE)
site_files %>% map(~ render_site(here::here("site", .x)))

