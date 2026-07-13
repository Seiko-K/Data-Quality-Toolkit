# Shared Validation Functions

This directory contains reusable Power Query helper functions.

The goal is to eliminate duplicated logic across validation modules and provide a consistent validation workflow.

## Implemented Functions

### TrimText.m

Removes leading and trailing whitespace from text values.

Behavior:

```text
"  ABC Corp  " → "ABC Corp"
123            → "123"
null           → null
```

Location:

```text
shared/TrimText.m
```

---

## Planned Functions

### EmptyToNull.m

Converts empty strings into null values.

### BuildValidationStatus.m

Generates a unified validation status.

```text
Valid
Invalid
```

### BuildIssueReason.m

Builds standardized issue messages from validation results.

Example:

```text
Missing CustomerID; Invalid Amount
```

---

## Design Goals

- Reusable
- Consistent
- Easy to maintain
- Shared across validation modules
- Reduced code duplication

---

Future validation modules should reuse these shared functions whenever possible.
