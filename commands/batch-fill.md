---
description: Fill a form once per row of a CSV with Emboss
argument-hint: <form id> [csv path or URL]
---

Fill the form $ARGUMENTS once per row of a CSV with Emboss. Ask for the CSV
(a path or https URL) if not given. Call `suggest_mapping`, show the
proposed mapping and unmapped columns, and confirm with the user before
calling `fill_batch` (`suggest_mapping` is billed as one context fill; each
row is one fill). Poll `get_batch` about every 20 seconds; reply with the
zip link (batch rows come 100 at a time: pass `next_cursor` as `cursor` for the next 100) and any failed rows. On an account with no payment method, a batch with more rows than the free fills left is refused; relay its message and billing link.
