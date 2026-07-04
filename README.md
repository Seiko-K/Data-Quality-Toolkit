![Version](https://img.shields.io/badge/version-v0.1-blue)
![Status](https://img.shields.io/badge/status-active-success)
![License](https://img.shields.io/badge/license-MIT-green)

# Data Quality Toolkit

Power Query based toolkit for data cleaning, validation and transformation workflows.

Built with Power Query (M) for customer, product and research datasets.

---

## Features

✓ Remove Duplicates

✓ Missing Value Detection

✓ Validation Status Flags

✓ Issue Reason Generation

✓ Text Normalization

✓ Validation Rules

✓ Data Transformation

✓ Reporting

✓ Power Query (M)

✓ Reusable Validation Pipelines

✓ Research Metadata Validation

✓ DOI Quality Checks

---

## Example Use Cases

### Customer Master Validation

- Duplicate customer detection
- Missing customer names
- Missing email addresses
- Validation status flags
- Standardized names
- Address cleanup

### Product Catalog Validation

- SKU normalization
- Missing product information
- Category cleanup
- Duplicate products
- Price validation
- Product quality checks
- Issue reason generation

### Research Metadata Validation

- DOI parsing
- Duplicate DOI detection
- Missing DOI detection
- Missing titles
- Missing authors
- Validation status generation
- Metadata consistency checks

---

## Repository Structure

```text
queries/
    CustomerValidation.m
    ProductValidation.m
    ResearchMetadataValidation.m

samples/
    customer_master.csv
    product_catalog.csv
    research_metadata.csv

README.md

LICENSE
```

---

## Included Examples

### CustomerValidation.m

Features

- Trim whitespace
- Convert empty values to null
- Detect duplicate customer records
- Detect missing names
- Detect missing emails
- Add validation status flags
- Normalize customer records

Location

```text
queries/CustomerValidation.m
```

---

### ProductValidation.m

Features

- Trim whitespace
- Convert empty values to null
- Detect duplicate ProductID
- Detect missing SKU
- Detect missing product names
- Detect missing categories
- Detect invalid prices
- Add validation status flags
- Generate issue reason messages

Location

```text
queries/ProductValidation.m
```

---

### ResearchMetadataValidation.m

Features

- Trim whitespace
- Convert empty values to null
- Detect duplicate DOI
- Detect missing DOI
- Detect missing titles
- Detect missing authors
- Add validation status flags
- Generate issue reason messages

Location

```text
queries/ResearchMetadataValidation.m
```

---

## Sample Datasets

### customer_master.csv

Example fields

- CustomerID
- Name
- Email

Validation scenarios

- Duplicate CustomerID
- Missing Name
- Missing Email
- Text normalization

---

### product_catalog.csv

Example fields

- ProductID
- SKU
- ProductName
- Category
- Price

Validation scenarios

- Duplicate ProductID
- Missing SKU
- Missing Product Name
- Missing Category
- Invalid Price
- Issue Reason Generation
- Text normalization

---

### research_metadata.csv

Example fields

- DOI
- Title
- Author
- Journal
- Year

Validation scenarios

- Duplicate DOI
- Missing DOI
- Missing Title
- Missing Author
- Validation Status
- Issue Reason Generation

---

## Technical Highlights

✓ Power Query (M)

✓ ETL Workflows

✓ CSV Import

✓ Duplicate Detection

✓ Missing Value Checks

✓ Validation Status Flags

✓ Issue Reason Generation

✓ Text Normalization

✓ Reusable Validation Pipelines

✓ Metadata Processing

✓ DOI Quality Checks

✓ Robust Number Conversion

✓ Data Quality Automation

---

## Built With

- Microsoft Excel
- Power Query
- M Language

---

## Roadmap

□ Validation Dashboard

□ Error Reporting

□ CSV Export

□ Excel Export

□ Batch Processing

□ SupplierValidation.m

□ SalesValidation.m

□ Additional Validation Queries

---

## License

MIT © 2026 Seiko K

---

Created by Seiko-K
