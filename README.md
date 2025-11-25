# Clinical-Trials-SQL-Analytics

<img src="0_Images/clinicaltrials.png" alt="ct" width="900">

## Description

In this challenging SQL project, I have extracted insights on clinical trials registered in the AACT (Aggregate Analysis of ClinicalTrials.gov) database, a publicly available relational database that contains all information - protocol and result data elements - about every study registered in ClinicalTrials.gov. The AACT database is considered the main source of information on clinical trials since 2005, when the Internal Commitee of Medical Journal Editors (ICMJE) announced that any clinical trial must be registered in the AATC before enrollment, otherwise it wouldn't be eligible for publication in major journals.

The project is organized into five analytical themes, each addressing a set of relevant business questions:

1. Study volume & trends
2. Sponsor & collaboration landscape
3. Global & geographic distribution
4. Study design & methodology
5. Patient eligibility & population

The analysis focuses on the protocol-level data only, excluding outcome analyses.

## Objective

The aim of this project is to have a more deep understading of protocol-related trends in clinical trials conducted all over the world.

## Tools & Skills

The tools that I have used in this project are the following:

- PgAdmin4: the GUI client from which SQL queries are sent to the PostgreSQL Server.
- SQL: the language to design queries to the database.
- PostgreSQL: the database management system (Server).

In addition, this project demonstrates my intermediate-level SQL skills and my ability to apply them in order to extract valuable information from real-world data. Some of these skills are:

- Beginner functions: Select, From, Group by, Order By, Count().
- Beginner filtering: Where, Having, Limit, In, Between, Is, Not, Like, Ilike,...
- Beginner structures: Joins, Subqueries.
- Intermediate functions: Case When, Extract Year/Month/Day From, Split_, Window functions: Lag(), Over(), Partition by(), Order by(),...
- Intermediate stuctures: Common Table Expressions (CTE), Temporary tables, Views.

## Structure

```bash
Clinical_Trials_SQL_Analytics/
│
├─ 0_Images/
│
├── clinicaltrials.png #the project's frontpage image
│
├── 1_Project_Plan/ #contains the project's guideline.
│   │
│   └── AACT_Clinical_Trials_SQL_Project_Plan.docx
│ 
├── 2_Database_Documentation/
│   │
│   ├── ER_Schema.png #an image of the Entity-Relationship Schema from ClinicalTrials.gov website.
│   │
│   └── Tables_and_fields.csv #contains a summary of all tables and fields in the database (data types, descriptions and documentation links).
│
├── 3_ERD.pgerd #the generated Entity-Relationship Diagram downloaded from PgAdmin4.
│
├── 4_SQL_Queries #contains all the SQL queries that answer the 20 business questions included in the guideline.
│
└── README.md

```

## Which steps did I follow?

### 1. Documentation

The first step was to understand the database: purpose, structure, definitions and limitations. I managed to gather all this information from the AATC website (Check: https://aact.ctti-clinicaltrials.org/).

#### 1.1 Database purpose

Data collection purpose is to





