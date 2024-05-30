## Date Dimension for Power BI
### datedim.pq
This script in Power Query M is used for simple generation of a date dimension for your data. Besides basic values (day, month, year, quarter, day of the week, week of the year, etc.), it also includes columns with information on whether a given day is a public holiday in the Czech Republic and Slovakia.

### Date dimension.pbix
A ready-to-use Power BI file utilizing the mentioned script for quick application. The date table is further adjusted:

All columns are correctly formatted
- Text columns (e.g., month name) are properly sorted
- A Calendar hierarchy (year – month – day) is created
- Additional data is categorized into individual folders
- Aggregation functions are disabled for numeric columns

### License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
