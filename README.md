![Version](https://img.shields.io/badge/version-v0.6-blue)
![Status](https://img.shields.io/badge/status-active-success)
![License](https://img.shields.io/badge/license-MIT-green)

# Data Quality Toolkit

Reusable Power Query toolkit for data cleaning, validation, and
transformation workflows.

Built with Power Query (M) for customer, product, supplier, inventory,
invoice, and research datasets.

------------------------------------------------------------------------

## Architecture

![Architecture](images/architecture.svg)

------------------------------------------------------------------------

## Features

-   Remove Duplicates
-   Missing Value Detection
-   Validation Status Flags
-   Issue Reason Generation
-   Text Normalization
-   Validation Rules
-   Data Transformation
-   Reporting
-   Power Query (M)
-   Reusable Validation Pipelines
-   Customer, Product, Supplier, Inventory, Invoice and Research
    Metadata Validation
-   DOI Quality Checks

------------------------------------------------------------------------

## How It Works

``` text
Input CSV
      │
      ▼
Power Query Validation
      │
      ▼
Validation Rules
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

The toolkit applies reusable validation rules to structured datasets and
generates standardized validation results that can be reused across
Business Operations, Data Analytics, and Research workflows.

------------------------------------------------------------------------

## Validation Flow

``` text
Customer Master CSV
        │
        ▼
Trim Text
        │
        ▼
Convert Empty Values to Null
        │
        ▼
Duplicate Detection
        │
        ▼
Missing Value Detection
        │
        ▼
Validation Status
        │
        ▼
Issue Reason
        │
        ▼
Validated Customer Dataset
```

This workflow ensures consistent, reusable validation across datasets.

------------------------------------------------------------------------

## Validation Rules

### CustomerValidation

  Rule                     Description
  ------------------------ -------------------------------------------
  Missing Customer ID      CustomerID is empty.
  Missing Name             Customer name is empty.
  Missing Email            Email address is empty.
  Duplicate Customer ID    CustomerID appears multiple times.
  Duplicate Email          Email address appears multiple times.
  Exact Duplicate Record   CustomerID, Name and Email are identical.

------------------------------------------------------------------------

## Sample Output

``` text
samples/invoice_master.csv
        │
        ▼
InvoiceValidation.m
        │
        ▼
samples/output/invoice_validation_result.csv
```

Generated columns include:

-   MissingCustomerID
-   MissingCustomerName
-   MissingInvoiceDate
-   InvalidAmount
-   ValidationStatus
-   IssueReason

------------------------------------------------------------------------

## Repository Structure

``` text
queries/
    CustomerValidation.m
    ProductValidation.m
    SupplierValidation.m
    InventoryValidation.m
    InvoiceValidation.m
    ResearchMetadataValidation.m

samples/
    customer_master.csv
    product_catalog.csv
    supplier_master.csv
    inventory_master.csv
    invoice_master.csv
    research_metadata.csv

    output/
        invoice_validation_result.csv

images/
    architecture.svg

shared/
    README.md
    TrimText.m
    EmptyToNull.m

README.md
LICENSE
```

------------------------------------------------------------------------

## Included Modules

### CustomerValidation.m

Features

-   Trim leading and trailing whitespace
-   Convert empty values to null
-   Detect missing Customer IDs
-   Detect missing customer names
-   Detect missing email addresses
-   Detect duplicate Customer IDs
-   Detect duplicate email addresses
-   Detect exact duplicate customer records
-   Generate Validation Status
-   Generate Issue Reason
-   Preserve original row order

Location

``` text
queries/CustomerValidation.m
```

### ProductValidation.m

-   Product validation rules
-   Duplicate ProductID detection
-   Missing SKU detection
-   Missing Product Name detection
-   Invalid Price detection

### SupplierValidation.m

-   Supplier validation rules
-   Duplicate SupplierID detection
-   Missing supplier information detection

### InventoryValidation.m

-   Inventory validation rules
-   Duplicate InventoryID detection
-   Invalid quantity detection

### InvoiceValidation.m

-   Invoice validation rules
-   Duplicate InvoiceID detection
-   Missing invoice information detection

### ResearchMetadataValidation.m

-   DOI validation
-   Duplicate DOI detection
-   Missing metadata detection

------------------------------------------------------------------------

## Shared Functions

### Implemented

``` text
TrimText.m
EmptyToNull.m
```

### Planned

``` text
BuildValidationStatus.m
BuildIssueReason.m
```

Shared functions reduce duplicated logic and keep validation behavior
consistent across modules.

------------------------------------------------------------------------

## Roadmap

### v0.7

-   AddressValidation.m

### v0.8

-   SalesValidation.m

### v0.9

-   EmployeeValidation.m

### v1.0

-   Shared Validation Functions
-   Validation Dashboard
-   Error Reporting
-   CSV Export
-   Excel Export
-   Batch Processing

### Future

-   Power Query Data Quality Library
-   GitHub Pages documentation
-   Example output gallery

------------------------------------------------------------------------

## Vision

Data Quality Toolkit is designed to become a reusable Power Query
validation framework for Business Operations, Data Analytics, Data
Engineering, and Research workflows.

Long-term goal:

**Power Query Data Quality Library**

------------------------------------------------------------------------

## License

MIT © 2026 Seiko K

------------------------------------------------------------------------

Created by Seiko-K