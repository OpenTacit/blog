---
title: "{{ replace .File.ContentBaseName "-" " " | title }}"
date: {{ dateFormat "2006-01-02" now }}
draft: true
description: "One sentence, shown under the title on the index and in search results."
---
