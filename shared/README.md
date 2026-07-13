# Shared Validation Functions

This directory is reserved for reusable Power Query helper functions.

The goal is to eliminate duplicated logic across validation modules and provide a consistent validation workflow.

## Planned Functions

### TrimText.m

Removes leading and trailing whitespace from text values.

### EmptyToNull.m

Converts empty strings into null values.

### BuildValidationStatus.m

Generates a unified validation status (Valid / Invalid).

### BuildIssueReason.m

Builds standardized issue messages from validation results.

---

## Design Goals

- Reusable
- Consistent
- Easy to maintain
- Shared across all validation modules

---

Future validation modules should reuse these shared functions whenever possible.
