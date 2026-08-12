![Version](https://img.shields.io/badge/version-v0.9.0-blue)
![Status](https://img.shields.io/badge/status-portfolio--ready-success)
![License](https://img.shields.io/badge/license-MIT-green)

# Data Quality Toolkit

Reusable Power Query toolkit for structured data cleaning, normalization, and validation workflows.

Built with Power Query (M) for customer, product, supplier, inventory, invoice, and research metadata datasets.

The project demonstrates how reusable validation patterns and shared preprocessing functions can be used to standardize data quality checks across different business datasets.

---

## Architecture

![Architecture](images/architecture.svg)

---

## Features

* Text normalization
* Missing value detection
* Duplicate detection
* Validation status generation
* Human-readable issue reasons
* Numeric validation
* DOI quality checks
* Reusable Power Query (M) validation pipelines
* Shared normalization logic
* Sample CSV datasets
* Sample validation output
* Customer data validation
* Product data validation
* Supplier data validation
* Inventory data validation
* Invoice data validation
* Research metadata validation

---

## How It Works

```text
Input CSV
      │
      ▼
Normalize Data
      │
      ▼
Apply Validation Rules
      │
      ▼
Generate Validation Flags
      │
      ▼
Validation Status
      │
      ▼
Issue Reason
      │
      ▼
Validated Output
```

Each validation module reads a structured dataset, normalizes relevant fields, applies dataset-specific validation rules, and generates columns that make data quality issues easier to identify.

---

## Shared Normalization Flow

The validation modules use the shared `NormalizeText.m` function for common text preprocessing.

```text
Raw Value
    │
    ▼
Convert to Text
    │
    ▼
Trim Leading / Trailing Whitespace
    │
    ▼
Convert Empty String to Null
    │
    ▼
Normalized Value
```

This removes repeated preprocessing logic from individual validation modules and keeps normalization behavior consistent across the toolkit.

---

## Validation Modules

### CustomerValidation.m

Validates customer master data.

Checks include:

* Missing CustomerID
* Missing customer name
* Missing email address
* Duplicate CustomerID
* Duplicate email address
* Exact duplicate customer records
* Validation status
* Issue reason generation
* Original row order preservation

Location:

```text
queries/CustomerValidation.m
```

---

### ProductValidation.m

Validates product catalog data.

Checks include:

* Duplicate ProductID
* Missing SKU
* Missing product name
* Missing category
* Invalid price
* Validation status
* Issue reason generation

Location:

```text
queries/ProductValidation.m
```

---

### SupplierValidation.m

Validates supplier master data.

Checks include:

* Duplicate SupplierID
* Missing supplier name
* Missing email address
* Missing country
* Validation status
* Issue reason generation

Location:

```text
queries/SupplierValidation.m
```

---

### InventoryValidation.m

Validates inventory data.

Checks include:

* Duplicate InventoryID
* Missing ProductID
* Missing warehouse
* Invalid quantity
* Validation status
* Issue reason generation

A quantity of `0` is treated as valid because it can represent an out-of-stock item.

Location:

```text
queries/InventoryValidation.m
```

---

### InvoiceValidation.m

Validates invoice data.

Checks include:

* Duplicate InvoiceID
* Missing CustomerID
* Missing invoice date
* Invalid invoice amount
* Validation status
* Issue reason generation

Invoice amounts must be numeric and greater than `0`.

Location:

```text
queries/InvoiceValidation.m
```

---

### ResearchMetadataValidation.m

Validates research metadata.

Checks include:

* Duplicate DOI
* Missing DOI
* Missing title
* Missing author
* Validation status
* Issue reason generation

Missing DOI values are handled separately from duplicate DOI detection.

Location:

```text
queries/ResearchMetadataValidation.m
```

---

## Sample Output

An example invoice validation workflow is included in the repository.

```text
samples/invoice_master.csv
        │
        ▼
InvoiceValidation.m
        │
        ▼
samples/output/invoice_validation_result.csv
```

The validation output preserves the source data while adding data-quality information.

Generated validation columns include:

* `IsDuplicateInvoiceID`
* `MissingCustomerID`
* `MissingInvoiceDate`
* `InvalidAmount`
* `ValidationStatus`
* `IssueReason`

---

## Repository Structure

```text
Data-Quality-Toolkit/
│
├── images/
│   └── architecture.svg
│
├── queries/
│   ├── CustomerValidation.m
│   ├── ProductValidation.m
│   ├── SupplierValidation.m
│   ├── InventoryValidation.m
│   ├── InvoiceValidation.m
│   └── ResearchMetadataValidation.m
│
├── samples/
│   ├── customer_master.csv
│   ├── product_catalog.csv
│   ├── supplier_master.csv
│   ├── inventory_master.csv
│   ├── invoice_master.csv
│   ├── research_metadata.csv
│   │
│   └── output/
│       └── invoice_validation_result.csv
│
├── shared/
│   ├── NormalizeText.m
│   └── README.md
│
├── .gitignore
├── LICENSE
└── README.md
```

---

## Shared Functions

### NormalizeText.m

`NormalizeText.m` provides the common preprocessing step used by the validation modules.

It:

* Converts values to text
* Trims leading and trailing whitespace
* Converts empty strings to `null`
* Preserves `null` values

Example:

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

Additional shared functions should only be introduced when repeated logic across multiple modules provides a clear reason for abstraction.

---

## Sample Datasets

The repository includes example CSV files for each validation module.

```text
samples/customer_master.csv
samples/product_catalog.csv
samples/supplier_master.csv
samples/inventory_master.csv
samples/invoice_master.csv
samples/research_metadata.csv
```

These datasets provide representative inputs for demonstrating the validation structure.

---

## Technical Highlights

* Power Query (M)
* CSV ingestion
* ETL-style transformation workflows
* Reusable data normalization
* Duplicate detection
* Missing value checks
* Numeric validation
* Validation flags
* Human-readable issue reporting
* Metadata validation
* DOI validation
* Shared helper functions
* Modular validation design

---

## Built With

* Microsoft Excel
* Power Query
* M Language
* Visual Studio Code
* Git
* GitHub

---

## Development Approach

This project uses a modular development approach in which each validation query is responsible for a specific dataset while reusable preprocessing logic is extracted into shared functions.

The source code includes English and Japanese comments to make implementation intent easier to review and maintain.

Development and static code review are performed on macOS using Visual Studio Code and Git-based change tracking.

### Runtime Validation Status

The current portfolio version has been statically reviewed on macOS.

Full end-to-end runtime validation of all Power Query modules in a Windows-compatible Excel / Power Query environment is pending.

The repository therefore represents a **portfolio-ready preview**, rather than a fully runtime-certified production release.

---

## Current Scope

Version `v0.9.0` includes:

* Six validation modules
* Shared text normalization
* Sample datasets
* Sample invoice validation output
* Architecture documentation
* Validation issue reporting
* Git-based source management

The current scope is intentionally limited to a clear, reusable validation foundation.

---

## Future Extensions

Possible future improvements include:

* Additional shared validation helpers
* Additional dataset-specific validation modules
* Validation dashboard
* Batch processing
* Standardized export workflows
* Additional sample outputs
* GitHub Pages documentation

These items are potential extensions and are not part of the current portfolio-ready scope.

---

## Portfolio Status

**v0.9.0 — Portfolio Ready Preview**

The core validation structure is complete for the current portfolio scope.

Further feature development is paused while the project is used as a demonstration of Power Query data-quality design and reusable validation patterns.

A future `v1.0.0` release may follow after full runtime validation in a Windows-compatible Power Query environment.

---

## License

MIT © 2026 Seiko K

---

Created by Seiko-K
