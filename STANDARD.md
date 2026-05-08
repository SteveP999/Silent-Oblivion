# HTR Artist Site Standard — Frozen Contract

This repo is a full replacement package. It must be deploy-ready by itself.

## Required files
- index.html
- songs.json
- latest.json
- radio.json
- manifest.json
- CNAME, if the repo uses a custom domain
- update.bat
- STANDARD.md

## Required folders
- images/artist
- images/covers
- images/logos
- audio/ optional, but folder remains for future local audio

## Song schema
Every song object must include `videos`, even if empty.

```json
"videos": []
```

If videos exist, render Watch Video. If empty, render Video Coming Soon.

Do not remove operational files when creating a replacement ZIP.
