---
layout: page
title: Alcatraz | Blog
---

## Much blog

{% for post in site.posts %}
  <span>{{ post.date | date_to_string }} - </span>
  <a href="{{ post.url }}">{{ post.title }}</a>
  <br>
{% endfor %}

