## Introduction
This project uses a dataset of Coca-cola historical daily stock price (1962-2021) and SQL Server to query for important and useful information for stock analysis purpose. The project is also a demonstration of ability to write advanced and powerful SQL queries to not only bring out the important details of a dataset, but to also transform it into a different format.

## Skill summary 
* Writing basic *SELECT* statements
* Writing math operations
* Creating and inserting into tables/temp tables
* Using the *ORDER BY()* clause with *DESC/ASC* query to sort data
* Applying boolean logic and sub-queries inside the *WHERE* clause
* Using aggregate functions such as *ROW_NUMBER()*, *SUM()*, or *AVG()*
* Using the *OVER()*, *PARTITION BY()*, and *GROUP BY()* clauses 
* Using the *CAST()* statement to change the data type
* Using *Common Table Expressions (CTEs)* and *nested CTEs* 
* Using all the above skills together to transform the dataset from **daily** to **yearly**

## Viewing the query
If you just want to view the queries, click on the *KO Stock Query.sql* file. 

However, if you want  see the results of the queries, you must already have Microsoft SQL Server Management Studio (MSSMS) on your computer, download the original dataset, which can be download from the link in the *Source.txt* file, then import it into your database. 

Finally, for each *FROM* clause, find and replace all **dbo.** text with **[whatever your database name is]..**, and then execute the queries.

## Statement of originality 
Aside from the dataset, which was downloaded from [Kaggle](https://www.kaggle.com/meetnagadia/coco-cola-stock-data-19622021), I hereby declare that the work presented in this project is an outcome of my independene and original work. The project is free from any plagiarism and has not been submitted elsewhere for publication.
