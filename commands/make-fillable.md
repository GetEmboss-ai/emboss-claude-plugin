---
description: Turn a flat PDF into a fillable form with Emboss
argument-hint: <path or https URL to a PDF>
---

Turn the PDF at $ARGUMENTS into a fillable form with Emboss. If the argument
is a local path, read the file and call `create_form` with `pdf_base64`; if
it is an https URL, call `create_form` with `pdf_url`. When it returns
ready, call `get_form` and reply with the download link and a short list of
the detected fields. If it returns failed, show the error and suggest
exporting the form to PDF again.
