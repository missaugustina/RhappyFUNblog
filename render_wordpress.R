#!/usr/bin/env Rscript

library(here)
library(readr)
library(rmarkdown)
library(stringr)

# commandArgs <- function(...) c(params$slug,"http://developer.ibm.com/code/wp-content/uploads/sites/118/2018/05/")
# you have to get the wp url after uploading images to the developerworks site

slug <- commandArgs()[1]
wp_url <- commandArgs()[2]

# render blog post
render(here::here("site", "blog", slug, paste0(slug, ".Rmd")),
       output_file=here::here("site", "blog", slug, paste0(slug, "_wordpress.html")),
       output_options = c(self_contained=FALSE))
system(paste0("rm -r ", here::here("site", "blog", slug), "/", slug, "_wordpress_files"))

# read in blog html so we can strip out the main HTML we want
blog_slug_html <- read_lines(here::here("site", "blog", slug, "index.html"))
blog_slug_body_start <- which(str_detect(blog_slug_html, "<div id=\"content\">"))
blog_slug_body_end <- tail(which(str_detect(blog_slug_html, "^</div>")))
blog_slug_body_end <- blog_slug_body_end[length(blog_slug_body_end)-1] # 2nd to last div
blog_slug_body <- blog_slug_html[blog_slug_body_start:blog_slug_body_end]

# replace image urls with the wordpress one
blog_slug_body <- str_replace_all(blog_slug_body, "<img src=\"img/", paste0("<img src=\"", wp_url))

# fix local links
blog_slug_body <- str_replace_all(blog_slug_body, "a href=\"(?!http)", paste0("a href=\"http://rhappy.fun/blog/", slug, "/"))

# add github link
blog_slug_body <- append(blog_slug_body,
                         paste0("<p align=\"center\">",
                                "<a href=\"", "https://github.com/missaugustina/RhappyFUNblog/blob/master/", 
                                "site/blog/", slug, "/", slug, ".Rmd\">",
                                "This post is available as Rmarkdown on Github",
                                "</a></p>"))

# add cross-posted link
blog_slug_body <- append(blog_slug_body,
                         paste0("<p align=\"center\">Cross-posted from Augustina's ", 
                                "<a href=\"", "http://rhappy.fun/blog/", slug, "/", slug,"\">", 
                                "R Happy FUN! Blog",
                                "</a></p>"))


write_lines(blog_slug_body, here::here("site", "blog", slug, paste0(slug, "_wordpress.html")))
