#!/bin/bash

year=${date:0:4}
date_string=$(date -d "$date" "+%B %d, %Y")

taglist=""
for tag in "${tags[@]}"
do
  tag=$(htmlEscape "$tag")
  taglist+="<li><a class=\"tag\" href=\"$base_url/posts/tags/$tag.html\">$tag</a></li>"
done

source="<!DOCTYPE html>
<html lang=\"en\">
<head>
  <meta charset=\"UTF-8\">
  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
  <meta http-equiv=\"X-UA-Compatible\" content=\"ie=edge\">
  <title>$title</title>
</head>
<body>
  <header>
    <h1>$title</h1>
    <h2>$excerpt</h2>
    <h3>By $author</h3>
    <ul class=\"tags\">$taglist</ul>
  </header>

  <main>
    <article>
    <time datetime=\"$date\">$date_string</time>
$content
    </article>
  </main>

  <footer>
    <p>Copyright &copy; $year $author</p>
  </footer>
</body>
</html>"