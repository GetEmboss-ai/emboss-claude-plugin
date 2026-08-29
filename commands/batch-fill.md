---
description: Fill a form once per row of a CSV with Emboss
---

Fill the form $ARGUMENTS once per row of a CSV with Emboss. Ask for the CSV
(a path or https URL) if not given. Call `suggest_mapping`, show the
proposed mapping and unmapped columns, and confirm with the user before
calling `fill_batch` (`suggest_mapping` is billed as one context fill; each
row is one fill). Poll `get_batch` about every 20 seconds; reply with the
zip link and any failed rows.
