#!/bin/bash

content=""

for post in "${posts[@]}"
do
  post_title=${titles[$post]}
  excerpt=${excerpts[$post]}
  date=${dates[$post]}
  url=$(fileNameToUrl $post)
  content+="<li>$date - <a href=\"$base_url/$url\">$post_title</a> &#126; <em>$excerpt</em></li>"
done

subtitle=""

if [ -n "$tag_name" ]; then
  subtitle="Browsing posts by tag: <span class=\"tag\">$tag_name</span>"
fi

if [ -n "$category_name" ]; then
  subtitle="Browsing posts by category: <span class=\"category\">$category_name</span>"
fi

if [ -n "$date_span" ]; then
  date_span=$(sed 's/\//-/g' <<< "$date_span")
  subtitle="Browsing posts by date: <span class=\"date\">$date_span</span>"
fi

source="<!DOCTYPE html>
<html lang=\"en\">
<head>
  <meta charset=\"UTF-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
  <meta http-equiv=\"X-UA-Compatible\" content=\"ie=edge\">
  <title>$title</title>
</head>
<body>
  <header class=\"half\">
    <h1>$title</h1>
    $subtitle
  </header>

  <main>
    <article>
      <ul>$content</ul>
    </article>
  </main>

  <footer>
    <p>Copyright &copy; $current_year $default_author</p>
  </footer>
</body>
</html>"