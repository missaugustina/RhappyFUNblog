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

# TODO creation time isn't preserved by git apparently
# render_site(here::here("site", "blog.Rmd"))
blog_html <- read_lines(here::here("site", "www", "blog.html"))

# add new post to index
blog_li <- which(str_detect(blog_html, "</a></li>"))
# check if it's already been added
if (str_detect(blog_html[max(blog_li)], slug)) {
  print(paste("Already appended", slug, "skipping"))
} else {
  slug_li <- paste("<li><a href=\"blog/", slug, "/index.html\">", Sys.Date(), ": ", slug, "</a></li>", sep="")
  blog_html_new <- c(blog_html[1:max(blog_li)], slug_li, blog_html[(max(blog_li)+1):length(blog_html)])
  write_lines(blog_html_new, here::here("site", "www", "blog.html"))
  print(paste("Appended new blog entry to index:", slug_li))
}


# add nav html to blog post
blog_slug_html <- read_lines(here::here("site", "blog", slug, "index.html"))

# extract nav
blog_html_nav <- 
  str_extract(paste(blog_html, collapse=""), "<div class=\"navbar navbar-default  navbar-fixed-top\" role=\"navigation\">.*</div><!--/.navbar -->")

blog_html_nav <- str_replace_all(blog_html_nav, "href=\"", "href=\"../../")

# add navigation to blog entries
blog_slug_nav <- str_replace(blog_slug_html, "<div class=\"container-fluid main-container\">",
                             paste0("<div class=\"container-fluid main-container\">", 
                                    blog_html_nav, 
                                    "<div class=\"fluid-row\"><br /><br /><br /></div>"))

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
# update rendered blog entry html with nav html pulled from main pages
write_lines(blog_slug_nav, here::here("site", "blog", slug,"index.html"))

# Something is breaking the navigation layout when running render_site and passing in all files
# render_site(here::here("site"))
site_files <- list.files(path=here::here("site"), pattern="*.Rmd", full.names = FALSE)
# TODO have to fix stuff, in the meantime, these have to be updated manually
# site_files %>% map(~ render_site(here::here("site", .x)))

