#!/usr/bin/env python
# coding: utf-8

# # Import sales data & merging

# In[1]:


import pandas as pd
import os, glob


# In[2]:


os.chdir(r"C:\Users\annie\OneDrive\Python projects\Pandas-Data-Science-Tasks-master\SalesAnalysis\Sales_Data")


# In[3]:


#Concatenate all 12 months of sales into one csv file
path = (r"C:\Users\annie\OneDrive\Python projects\Pandas-Data-Science-Tasks-master\SalesAnalysis\Sales_Data")
all_file = glob.glob(os.path.join(path,"Sales_*.csv"))
months_sales = (pd.read_csv(f, sep=',') for f in all_file)
months_sales = pd.concat(months_sales, ignore_index=True)
months_sales.to_csv("all_data_sales.csv")


# In[4]:


# DataFrame with 12 months worth of sales
all_data = pd.read_csv("all_data_sales.csv", index_col=0)


# # Data cleaning

# In[5]:


#Select NAN columns
nan_df = all_data[all_data.columns[all_data.isna().any()]]
nan_df.head()


# In[6]:


#Drop rows with NAN 
all_data = all_data.dropna() 
print(all_data)


# In[7]:


all_data.isna().any()


# In[8]:


#Find "Or" or delete it : Find duplicates
all_data = all_data[all_data["Order Date"].str[0:2] != "Or"]


# In[9]:


#Convert columns to Int
all_data['Quantity Ordered'] = pd.to_numeric(all_data['Quantity Ordered'])
all_data['Price Each'] = pd.to_numeric(all_data['Price Each'])
all_data.dtypes


# # Organize

# #### Add month column

# In[10]:


all_data['Month'] = all_data['Order Date'].str[0:2]
all_data['Month'] = all_data['Month'].astype('int32')
all_data.head()


# #### Calculate Sales 

# In[11]:


all_data['Sales'] = all_data['Quantity Ordered'] * all_data['Price Each']
all_data.head()


# #### Create City column

# In[12]:


def get_city(address):
    return address.split(',')[1]

def get_state(address):
    return address.split(',')[2].split(' ')[1] #splits the state with the city by splittting on white spaces

all_data['City'] = all_data['Purchase Address'].apply(lambda x: f"{get_city(x)} ({get_state(x)})")

all_data.head()


# #### Create Order Date time distribution

# In[13]:


# Convert order date into a date time object with Date time library 
# Converting to date time makes it easier to parse data into various columns
all_data['Order Date'] = pd.to_datetime(all_data['Order Date'])


# In[14]:


all_data['Hour'] = all_data['Order Date'].dt.hour
all_data['Minute'] =  all_data['Order Date'].dt.minute
all_data.head()


# # Analysis

# ### 1. What was the best month for sales? How much was earned that month

# In[15]:


pd.set_option('float_format', '{:f}'.format)
total = all_data.groupby('Month').sum()


# In[16]:


#Let's look at the trend month to month
import matplotlib.pyplot as plt

months = range(1,13)

plt.bar(months,total['Sales'])
plt.xticks(months)
plt.ylabel("Sales in USD ($)")
plt.xlabel("Month")
plt.show()


# In[ ]:





# ### 2. What city had the highest number of sales?

# In[17]:


best_city = all_data.groupby('City').sum()
print(best_city)


# In[18]:


#Let's look at the trend month to month
import matplotlib.pyplot as plt

cities = [city for city, df in all_data.groupby('City')] #order matters

plt.bar(cities,best_city['Sales'])
plt.xticks(cities, rotation ='vertical', size =8)
plt.ylabel("Sales in USD ($)")
plt.xlabel("City Name")
plt.show()


# ### 3. What time should we display advertisements to maximize likelihoof of customer's buying products?

# In[19]:


hours = [hour for hour, df in all_data.groupby('Hour')] #order matters

plt.plot(hours, all_data.groupby(['Hour']).count()) # number of
plt.xticks(hours, size=9)
plt.grid()
plt.ylabel("Number of orders")
plt.xlabel("Hour of Day")
plt.show()


# Best time to advertize is betwwen the hours of 10AM -7PM


# 
# ### 4. What products are most often sold together?
# 

# In[20]:


dupes = all_data[all_data['Order ID'].duplicated(keep=False)] #find duplicates in Order_Id Column

# Groupd duplicates of Order ID rows by product column then joins products by comma and shows occurences of same pairs
dupes['Grouped'] = dupes.groupby('Order ID')['Product'].transform(lambda x: ','.join(x)) 

#drops duplicated rows in dupes dataframe
dupes = dupes[['Order ID', 'Grouped']].drop_duplicates()


# In[22]:


# Count pairs of products most often sold together

from itertools import combinations 
from collections import Counter

count = Counter()

for row in dupes['Grouped']:
    dupes_sublist = row.split(',')
    count.update(Counter(combinations(dupes_sublist,2)))  # counts the combinations of most 2 items bought togther returns in dictionnary
    
    
for key, value in count.most_common(10):
    print(key, value)


# ### What products sold the most and why?

# In[62]:


#Returns most bought item
all_data.Product.mode()


# In[63]:


#Returns the count of the each product sold
product_count = all_data.value_counts(all_data['Product'])
product_count


# In[41]:


#Let's graph it
product_count.plot.bar()
plt.ylabel("Quantity Ordered")
plt.show()


# In[64]:


prices = all_data.groupby('Product').mean()['Price Each']
prices


# In[ ]:




