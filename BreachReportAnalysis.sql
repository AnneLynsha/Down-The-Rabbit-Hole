-- Looking at the data
select Lost_records, Year, Sector, Method, [Data_sensitivity level], Displayed_records from BreachReport
order by Sector

-- Showing Organization with Highest Records Lost and Data Sensitivity Level
select Org_name, Lost_records, [Data_sensitivity level], Year
from BreachReport
order by Lost_records desc

-- Showing Records Lost by Breach Type
select Method ,count(Method) as CountofMethod, sum(Lost_records) as TotalRecLost_byMethod
from BreachReport
group by Method
order by TotalRecLost_byMethod desc

-- Showing Trends of Breaches( all method types )
select Year, sum(Lost_records) as YearlyRecordsLost
from BreachReport
group by Year
order by YearlyRecordsLost desc

-- What are the companies with more than one breaches?
SELECT Org_name, COUNT(*) as MultipleBreaches, sum(Lost_Records) as SumLost_Records
FROM BreachReport
GROUP BY Org_name
HAVING COUNT(*) > 1
order by MultipleBreaches desc

-- Total lost records by Breach Method 
select distinct Method, sum(Lost_records) as Total_RecLostMethod
from BreachReport
group by Method
order by Total_RecLostMethod  desc

-- Showing most sensitive sector?  
SELECT Sector, count(Sector) Count_Sector, sum(Lost_Records) as SumLost_Records
FROM BreachReport
GROUP BY Sector
HAVING COUNT(*) > 1
order by Count_Sector desc


 



 
