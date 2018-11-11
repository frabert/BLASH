#!/bin/bash

#------------------------------------------------------------------------------#
#                     BLASH - Bash static blog generator                       #
#                                                                              #
#                Released under the ISC license - see LICENSE                  #
#------------------------------------------------------------------------------#

htmlEscape () {
  sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g' <<< "$1"
}

fileNameToUrl() {
  # File format: YYYY-mm-dd-foo-bar-baz
  local year=${1:0:4}
  local month=${1:5:2}
  local day=${1:8:2}
  local slug=${1:11}

  echo "posts/$year/$month/$day/$slug.html"
}

mkdir -p publish/posts
mkdir -p publish/posts/tags
mkdir -p publish/posts/categories
mkdir -p publish/assets/js
mkdir -p publish/assets/css
mkdir -p publish/assets/images

source "config.sh"

configureAssets

declare -a posts
posts=()

declare -A titles dates excerpts all_categories all_tags posts_by_year posts_by_month posts_by_day
titles=()
dates=()
excerpts=()
all_categories=()
all_tags=()
posts_by_year=()
posts_by_month=()
posts_by_day=()

current_year=$(date +%Y)

post_list=(contents/posts/*.sh)
post_list_rev=()

# Reverse post list to get chronological order
for (( i=${#post_list[@]}-1,j=0 ;i>=0;i--,j++ ))
do
  post_list_rev[j]=${post_list[i]}
done

################################################################################
# Generate post pages                                                          #
################################################################################
for post in "${post_list_rev[@]}"
do
  filename=$(basename -- "$post")
  filename="${filename%.*}"

  title=""
  author=$default_author
  categories=("misc")
  tags=()
  draft=false
  excerpt=""
  source "$post"
  title=$(htmlEscape "$title")
  author=$(htmlEscape "$author")
  excerpt=$(htmlEscape "$excerpt")

  date=${filename:0:10}
  content=$(pandoc "contents/posts/$filename.md")
  source "templates/post.sh"

  path=$(fileNameToUrl "$filename")
  mkdir -p "publish/${path%/*}"
  echo "$source" > "publish/$path"

  # If a post is a draft, it will get built, but not indexed
  if [ "$draft" = false ] ; then
    posts+=("$filename")
    titles["$filename"]=$title
    excerpts["$filename"]=$excerpt
    dates["$filename"]=$date
    
    year=${filename:0:4}
    month=${filename:5:2}
    day=${filename:8:2}

    # The dates are stored in a YYYY/mm/dd format
    # to make it easy to generate the indices
    posts_by_year["$year"]+=" $filename"
    posts_by_month["$year/$month"]+=" $filename"
    posts_by_day["$year/$month/$day"]+=" $filename"

    for cat in "${categories[@]}"
    do
      all_categories["$cat"]+=" $filename"
    done
    
    for tag in "${tags[@]}"
    do
      all_tags["$tag"]+=" $filename"
    done
  fi
done

unset tag_name
unset category_name
title="$blog_title"
source "templates/index.sh"

echo "$source" > "publish/index.html"

for tag_name in "${!all_tags[@]}"
do
  tag_posts="${all_tags[$tag_name]}"
  read -r -a posts <<< "$tag_posts"

  source "templates/index.sh"
  echo "$source" > "publish/posts/tags/$tag_name.html"
done

for category_name in "${!all_categories[@]}"
do
  category_posts="${all_categories[$category_name]}"
  read -r -a posts <<< "$category_posts"

  source "templates/index.sh"
  echo "$source" > "publish/posts/categories/$category_name.html"
done

################################################################################
# Generate indices based on date                                               #
################################################################################

# Posts by year
for date_span in "${!posts_by_year[@]}"
do
  date_posts="${posts_by_year[$date_span]}"
  target="publish/posts/$date_span/index.html"
  read -r -a posts <<< "$date_posts"

  source "templates/index.sh"
  echo "$source" > "$target"
done

# Posts by month
for date_span in "${!posts_by_month[@]}"
do
  date_posts="${posts_by_month[$date_span]}"
  target="publish/posts/$date_span/index.html"
  read -r -a posts <<< "$date_posts"

  source "templates/index.sh"
  echo "$source" > "$target"
done

# Posts by day
for date_span in "${!posts_by_day[@]}"
do
  date_posts="${posts_by_day[$date_span]}"
  target="publish/posts/$date_span/index.html"
  read -r -a posts <<< "$date_posts"

  source "templates/index.sh"
  echo "$source" > "$target"
done