# Emboss tool reference

Argument details for the 11 Emboss MCP tools. See SKILL.md for when to use
each one and how to talk about the results.

## list_forms

Forms already in the user's Emboss library.

- `state` (optional): `ready` (default), `processing`, `failed`, or `all`.
- `limit` (optional): up to 50.
- `cursor` (optional): from a previous call's `next_cursor`, for pagination.

Returns each form's `id`, `title`, `state`, `pages`, `field_count`, and
`created_at`, plus `next_cursor` if there are more.

## get_form

Status of one form.

- `form_id` (required).

When the form is `ready`, returns its `fields` (each with `id`, `label`,
`kind`, `required`, `options: [{value, label}]` for choice fields, `group`
for fields that belong to the same exclusive group, and `description` when
the form gives one) and a `download_url` for the fillable PDF.

## get_usage

No arguments. Returns this month's usage, how many free operations remain,
and the billing page link.

## create_form

Upload a PDF and detect its fields.

- `pdf_url` or `pdf_base64` (exactly one required): a public https link, or
  base64-encoded PDF bytes.
- `title` (optional).

Returns when detection finishes (usually under two minutes). Billed as one
form creation; the first 5 each month are free.

## delete_form

- `form_id` (required).

Permanently removes a form and its PDFs from the user's library. Only call
this when the user explicitly asks.

## fill_form

Fill a ready form with values.

- `form_id` (required).
- `values` (required): a dict keyed by field id or field label. Checkboxes
  take `yes`/`no`; choice fields take one of the field's option labels or
  values.
- `flatten` (optional): reserved for a future release. Do not set it; passing
  `true` returns `bad_request`.

Returns a `download_url`, the `applied` values, any `unmatched` keys
(labels that didn't match a field, or values that didn't match a checkbox
word or option; ask the user about those), and `warnings`. Billed as one
fill; the first 5 each month are free.

## fill_form_from_context

Fill a form using answers pulled out of documents or notes.

- `form_id` (for a form already in the library) or `pdf_url`/`pdf_base64`
  (to create and fill a new one), exactly one of the two forms.
- `context_text` (optional): pasted notes or text.
- `context_urls` (optional): up to 5 public https links to PDFs, Word docs,
  spreadsheets, images, or text files.

At least one of `context_text` / `context_urls` is required. Returns a
`job_id`; poll `get_job` about every 20 seconds. Billed as one context fill;
the first 5 each month are free. Passing `pdf_url`/`pdf_base64` instead of
`form_id` also creates the form, so that path is billed as one form creation
plus one context fill.

## get_job

Status of a `fill_form_from_context` job.

- `job_id` (required).

When ready, returns `download_url`, `filled` (field count), `dropped`, and
any `warnings`.

## suggest_mapping

Propose which spreadsheet column fills which form field.

- `form_id` (required).
- `csv_text` or `csv_url` (exactly one required). Only the header row
  matters.

Returns a `mapping` of `{column: field_id}` and `unmapped_columns`. Billed
as one context fill (5 free each month). `fill_batch` runs this
automatically if called without a `mapping`, so it's billed even when you
don't call it directly.

## fill_batch

Fill the form once per spreadsheet row.

- `form_id` (required).
- `csv_text` or `csv_url` (exactly one required), up to 1000 rows.
- `mapping` (optional): `{column: field_id}`. Omit it to use the suggested
  mapping (this runs `suggest_mapping` first, billed as one context fill).

Returns a `batch_id`. Batches up to 50 rows finish before this call
returns; larger ones keep running, poll `get_batch`. Each row is billed as
one fill.

## get_batch

Progress of a `fill_batch` run.

- `batch_id` (required).

Returns `status`, `total`, `filled`, `failed`, a `download_url` per
finished row (first 100), and a `zip_url` once the batch is done.

## Error codes

Errors carry a machine-readable `code` and a human `message`:

- `insufficient_scope`: the connection doesn't have the needed permission;
  reconnect Emboss (see SETUP.md in this folder, or the emboss-setup skill).
- `not_found`: the id doesn't exist, or isn't in this user's account.
- `not_ready`: the form/job/batch is still processing; try again shortly.
- `over_free_tier`: this month's free operations are used up; relay the
  message and the `billing_url`.
- `over_page_cap`: the form is over the free-tier 5-page limit; relay the
  message and the `billing_url`.
- `unsupported_file`: not a PDF; tell the user to export to PDF first.
- `bad_request`: malformed or conflicting arguments; check the message for
  which argument and fix the call.
- `fetch_failed`: a given URL couldn't be downloaded; ask the user for a
  working public link, or a pasted/base64 alternative.
- `nothing_to_fill` (`fill_form`): none of the given values matched a field;
  show `get_form`'s fields and ask the user which ones to fill.
- `no_mapping` (`fill_batch`): no spreadsheet column matched a form field;
  pass an explicit `mapping` (see `suggest_mapping`).
- `too_large`: the upload is over its size limit (PDF, context text, or CSV);
  ask the user for a smaller file or a link instead of inline content.
- `rate_limited`: too many requests; wait a minute and retry.
- `server_error`: Emboss had a problem processing the request; retry once,
  and tell the user if it persists.
- `unauthenticated`: no valid session; see SETUP.md in this folder, or the
  emboss-setup skill, to (re)connect Emboss.

402 responses (`over_free_tier`, `over_page_cap`, and similar billing
errors) include a `billing_url`.
