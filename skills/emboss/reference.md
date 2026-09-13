# Emboss tool reference

Argument details for the Emboss MCP tools. See SKILL.md for when to use
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

When ready, returns `download_url`, `filled` (field count), `dropped`, any
`warnings`, and `artifacts`: one entry per file, each with `artifact_id`,
`role` (`filled`, `receipt`, or `package`), and `mime_type`.

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

## send_fax

Fax a PDF to a fax number. Billed per page at delivery; a failed fax is not
charged.

- `to` (required): destination in E.164 form, for example `+15025551212`.
- Exactly one of `sources` (a list of up to twenty entries, each an
  `artifact_id` with an optional `pages` range, comma-separated 1-based page
  numbers as `n` or `n-m`, for example `1-3,7`; pay-per-call callers add an
  `artifact_token` per entry, to fax several artifacts as one packet),
  `artifact_id` (from any earlier result), `job_id` (a ready
  `fill_form_from_context` or `commit_proposal` job; its filled PDF is
  faxed), `form_id` (a ready form; its fillable PDF is faxed), `pdf_url`, or
  `pdf_base64`.

Returns `job_id`, `status` (`working`), `pages`, `price_cents`,
`destination_masked`, and `artifact_id` (the transmitted copy) and
`source_artifact_ids`. A repeat of the same artifact to the same
destination within ten minutes returns the same job with
`deduplicated: true`. Poll `get_fax` with the `job_id`.

## get_fax

Status and receipt of a `send_fax` job.

- `job_id` (required).

Returns a receipt with `status` (`working`, `delivered`, `failed`, or
`expired`), `to_masked`, `pages`, `provider`, `submitted_at`, `artifact_id`,
and `source_artifact_ids`; when delivered a `price`; a failed or expired job
carries `error` (category, reason, `retryable`) and `refund` (`mode`,
`state`).

## Free PDF utilities

Seven tools that operate directly on PDF bytes rather than a form: merge,
compose, extract pages, delete pages, reorder pages, rotate pages, and
inspect. They are free, do not count against any free-tier limit, and are
not billed. Page selections (`pages` arguments) follow the same grammar as
elsewhere in this reference: a comma-separated, 1-based list such as `1-3,7`;
repeats are kept; an omitted `pages` means every page.

Limits: at most twenty sources per call, up to one hundred pages per source,
up to five hundred pages in an output, up to one hundred megabytes of
sources together, and at most one hundred and twenty utility runs an hour.

Outputs of a free utility are deleted sixty to seventy minutes after they
are created, for every caller.

### compose_pdf

Build one PDF from several artifacts.

- `sources` (required): a list of `{artifact_id, pages, rotate}`. `pages` is
  a page selection (see above), omit for every page. `rotate` is `90`,
  `180`, or `270`.

Returns the new `artifact_id`.

### merge_pdf

Join whole PDFs in order.

- `sources` (required): a list of `{artifact_id}`. For page selections, use
  `compose_pdf` instead.

Returns the new `artifact_id`.

### extract_pages

Keep only the named pages of one artifact.

- `artifact_id` (required).
- `pages` (required): a page selection (see above), for example `2,5-9`.

Returns the new `artifact_id`.

### delete_pages

Remove the named pages from one artifact; every other page stays in order.

- `artifact_id` (required).
- `pages` (required): a page selection (see above), for example `1-2,17`.

Returns the new `artifact_id`.

### reorder_pages

Reorder one artifact's pages.

- `artifact_id` (required).
- `order` (required): every page number, exactly once, in the new order.

Returns the new `artifact_id`.

### rotate_pages

Rotate pages of one artifact.

- `artifact_id` (required).
- `rotations` (required): a list of `{pages, degrees}`, `pages` a page
  selection (see above) and `degrees` one of `90`, `180`, `270`, added
  clockwise to each page's current rotation.

Returns the new `artifact_id`.

### inspect_pdf

Structural facts about one artifact: no text, no field values.

- `artifact_id` (required).

Returns page count, each page's size and rotation, and whether the PDF is
encrypted, has form fields, has annotations, has outlines, has embedded
files, or has JavaScript.

## Artifacts

Every result that hands back a file carries an `artifact_id`: `create_form`,
`get_form` (plus `source_artifact_id` when the form came from another
file), `fill_form`, `fill_form_from_context`/`get_job`, `get_batch` (per
row), and `send_fax`/`get_fax`. Chain operations by passing that id forward
(for example `send_fax` with `artifact_id`) instead of downloading and
re-uploading the file. `get_job` also returns `artifacts`, one entry per
file with `artifact_id`, `role` (`filled`, `receipt`, or `package`), and
`mime_type`. Under ephemeral processing a file is deleted after its
retention window; using its `artifact_id` after that returns the `gone`
error code. Once an `artifact_id` exists, the bytes behind it never change;
a new render, transformation or copy is a new artifact.

## Error codes

Errors carry a machine-readable `code` and a human `message`:

- `insufficient_scope`: the connection doesn't have the needed permission;
  reconnect Emboss (see SETUP.md in this folder, or the emboss-setup skill).
- `not_found`: the id doesn't exist, or isn't in this user's account.
- `not_ready`: the form/job/batch is still processing; try again shortly.
  For `send_fax` by `job_id` or `form_id`, poll `get_job` or `get_form` until
  ready, then send again.
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
- `refused` (`send_fax`): the destination is blocked or the per-destination
  cap is reached; tell the user and do not retry the same number.
- `provider_unavailable` (`send_fax`): the fax provider did not accept the
  job and nothing was charged; retry once after a minute.
- `gone` (`send_fax`, or any free PDF utility): the file behind that
  `artifact_id` was deleted under ephemeral processing; the error's `detail`
  gives the retention sentence. Recreate or refetch the file and send again.
- `server_error`: Emboss had a problem processing the request; retry once,
  and tell the user if it persists.
- `unauthenticated`: no valid session; see SETUP.md in this folder, or the
  emboss-setup skill, to (re)connect Emboss.
- `invalid_page_spec` (free PDF utilities): a `pages`/`order` argument isn't
  a valid page selection; fix its grammar (see Free PDF utilities above).
- `page_out_of_range` (free PDF utilities): a page number named in `pages`
  or `order` doesn't exist in the source artifact.
- `duplicate_page` (free PDF utilities): `order` repeats a page number; it
  must name every page exactly once.
- `missing_page` (free PDF utilities): `order` omits a page number from the
  source artifact.
- `empty_output` (free PDF utilities): the requested operation would leave
  zero pages; adjust `pages`/`order` to keep at least one.
- `pdf_required` (free PDF utilities): one of the sources isn't a PDF.
- `too_many_pages` (free PDF utilities): a source is over the hundred-page
  limit.
- `too_many_inputs` (free PDF utilities): `sources` is over the twenty-entry
  limit.
- `file_too_large` (free PDF utilities): the sources together are over the
  hundred-megabyte limit.
- `pdf_encrypted` (free PDF utilities): the source PDF is password-protected;
  ask the user for a decrypted copy.
- `pdf_corrupt` (free PDF utilities): the source PDF could not be parsed;
  ask the user for a valid file.

402 responses (`over_free_tier`, `over_page_cap`, and similar billing
errors) include a `billing_url`.
