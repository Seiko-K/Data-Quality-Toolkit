# Shared Validation Functions

This directory contains reusable Power Query helper functions used across the Data Quality Toolkit.

The goal is to centralize common data-cleaning logic, reduce duplicated code, and provide consistent behavior across validation modules.

---

## Implemented Functions

### NormalizeText.m

Normalizes text-based input values before validation.

It performs three common preprocessing steps:

1. Converts input values to text.
2. Removes leading and trailing whitespace.
3. Converts empty strings to `null`.

Example behavior:

```text
"  ABC Corp  " → "ABC Corp"
123            → "123"
""             → null
"   "           → null
null           → null
```

Location:

```text
shared/NormalizeText.m
```

---

## Usage

Validation modules can use the shared function through `Table.TransformColumns`.

Example:

```powerquery
Normalized =
    Table.TransformColumns(
        Source,
        {
            {
                "CustomerID",
                each NormalizeText(_),
                type nullable text
            }
        }
    )
```

This replaces repeated normalization logic inside individual validation modules.

---

## Current Usage

`NormalizeText.m` is used as the common normalization step for:

* Customer validation
* Product validation
* Supplier validation
* Inventory validation
* Invoice validation
* Research metadata validation

---

## Design Goals

* Reusable
* Consistent
* Easy to maintain
* Shared across validation modules
* Reduced code duplication
* Clear separation between normalization and validation

---

## Future Extensions

Additional shared functions may be introduced if repeated validation logic emerges across multiple modules.

Potential examples include:

```text
BuildValidationStatus.m
BuildIssueReason.m
```

New shared functions should only be introduced when they provide clear reuse and simplify multiple validation modules.
