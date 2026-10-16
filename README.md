# Kiddo Colors – Remote Content

Public content feed for the Kiddo Colors app. The app fetches `manifest.json`
from this repo's raw GitHub URL at launch and adds any new templates listed
here to the picker, without needing an app update.

## Adding a new template

1. Draw a line-art image: 800x800px, dark outline (#2b2340), transparent or
   white background, same style as the app's built-in templates.
2. Drop it in `images/`.
3. Add an entry to `manifest.json`:
   ```json
   {
     "id": "unique_id",
     "cat": "free",
     "names": "Turkish|English|German|Spanish|French|Portuguese|Russian",
     "premium": false,
     "image": "images/your_file.png"
   }
   ```
4. Commit and push. The app picks it up automatically (checks once per day).
