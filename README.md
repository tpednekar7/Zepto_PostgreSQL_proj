# 🛒 Zepto Inventory & Business Analysis — SQL Project

A business analysis project using PostgreSQL and pgAdmin, built on real-world e-commerce inventory data scraped from Zepto's product listings. The project covers data import, cleaning, exploration, and business insights through structured SQL queries.

---

## 📁 Dataset

- **Source:** [Kaggle — Zepto Inventory Dataset](https://www.kaggle.com/datasets/palvinder2006/zepto-inventory-dataset/data?select=zepto_v2.csv)
- **Origin:** Scraped from Zepto's official product listings
- **Structure:** Each row represents a unique cid

> Duplicate product names exist intentionally — the same product can appear in different package sizes, weights, or discount tiers, mirroring how real catalog data looks.

### 🧾 Schema — `zepto` Table

| Column | Description |
|--------|-------------|
| `cid` | Unique identifier for each product entry (Synthetic Primary Key) |
| `name` | Product name as it appears on the Zepto app |
| `category` | Product category (e.g., Fruits, Snacks, Beverages) |
| `mrp` | Maximum Retail Price (converted from paise to ₹) |
| `discountPercent` | Discount percentage applied on MRP |
| `discountedSellingPrice` | Final selling price after discount (in ₹) |
| `availableQuantity` | Units currently available in inventory |
| `weightInGms` | Product weight in grams |
| `outOfStock` | Boolean flag — `true` if product is out of stock |
| `quantity` | Number of units per package (mixed with grams for loose produce) |

---

## 🛠️ Tools Used

- **PostgreSQL** — Relational database
- **pgAdmin 4** — GUI for database management and query execution

---

## 🚀 Getting Started

### 1. Prerequisites
- PostgreSQL installed (v13 or above recommended)
- pgAdmin 4

### 2. Create the Table

```sql
CREATE TABLE zepto (
    cid        SERIAL PRIMARY KEY,
    name          VARCHAR(150),
    category      VARCHAR(50),
    mrp           NUMERIC(10,2),
    discountPercent     NUMERIC(5,2),
    discountedSellingPrice  NUMERIC(10,2),
    availableQuantity   INT,
    weightInGms   INT,
    outOfStock    BOOLEAN,
    quantity      VARCHAR(50)
);
```

### 3. Import the Data

**Option A — pgAdmin Import (Recommended):**
1. Right-click the `zepto` table → **Import/Export**
2. Select the CSV file, enable header toggle, set delimiter to `,`
3. Click OK


---

## 🔍 Analysis Breakdown

### 1. Data Exploration
- Total record count
- Sample data preview
- Null value check across all columns
- Distinct product categories
- In-stock vs out-of-stock product counts
- Products with multiple cids (duplicate names)

### 2. 🧹 Data Cleaning
- Removed rows where MRP or discounted selling price was zero
- Converted `mrp` and `discountedSellingPrice` from paise to rupees

```sql
UPDATE zepto
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

DELETE FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;
```

### 3. 📊 Business Insights

| # | Query | Insight |
|---|-------|---------|
| 8 | Top 10 best-value products | Ranked by discount percentage |
| 9 | High MRP out-of-stock products | Revenue at risk |
| 10 | Estimated revenue per category | Category-level revenue potential |
| 11 | Premium products with low discount | MRP > ₹500 and discount < 10% |
| 12 | Top 5 high-discount categories | Average discount per category |
| 13 | Best price-per-gram products | Value-for-money above 100g |
| 14 | Weight-based product groups | Low / Medium / Bulk segmentation |
| 15 | Inventory weight per category | Total stock weight analysis |

### 4. 🪟 Advanced Queries (Window Functions & CTEs)

| # | Query |
|---|-------|
| 16 | Highest discounted product **within each category** (PARTITION BY) |
| 17 | Top 3 highest MRP products **per category** |
| 18 | Products priced above their **category average MRP** |
| 19 | Products contributing the **highest potential revenue** |
| 20 | Each category's **share of total inventory value** |
| 21 | Detection of **duplicate product names** |
| 22 | Discount strategy classification — Heavy / Moderate / Low |
| 23 | MRP quartile segmentation — Premium / High / Medium / Budget (NTILE) |

---

## 💡 Key SQL Concepts Used

- `GROUP BY`, `ORDER BY`, `HAVING`
- `JOINS` and subqueries
- `CASE WHEN` for conditional logic
- `WINDOW FUNCTIONS` — `ROW_NUMBER()`, `RANK()`, `NTILE()`, `PARTITION BY`
- Aggregate functions — `SUM()`, `AVG()`, `COUNT()`, `MAX()`
- Data type conversion and filtering

---

## 📂 Repository Structure

```
zepto-sql-project/
│
├── zepto_project.sql     # All SQL queries (exploration, cleaning, insights)
├── README.md             # Project documentation
```

---

## 🙋 About

This project was built to practice real-world SQL on a dataset that mimics actual e-commerce inventory challenges — duplicate cids, encoding issues, paise-to-rupee conversion, and business KPI analysis.
