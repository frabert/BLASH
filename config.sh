#!/bin/bash

: ${blog_title:="BLASH blog"}
: ${default_author:="John Doe"}
: ${base_url:=""}

configureAssets () {
  for css in assets/css/*.css
  do
    filename=$(basename -- "$css")
    cp "$css" "publish/assets/css/$filename"
  done
}