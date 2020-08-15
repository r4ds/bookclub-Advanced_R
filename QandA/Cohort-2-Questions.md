Chapter 2 Questions: 
- For exercise 2, section 2.5.1, why do I get one less copy when running code?
    - It could be a difference between R and Rstudio. You also may need to switch your environment to something other than global. 
- How does R allocate memory for different length character strings? 
    - Seems to be allocating bytes in increments of ~8 characters (https://youtu.be/pCiNj2JRK50?t=988) 
- Why don’t lists with repeated values that aren’t characters point to the same object, like character vectors do? (https://youtu.be/pCiNj2JRK50?t=2916) 
- If you have to run garbage collector, are you doing something wrong with your code? (https://youtu.be/pCiNj2JRK50?t=1686) 
- How is removing objects dealt with in the garbage collection process? (https://youtu.be/pCiNj2JRK50?t=1811) 
- When might you want to use local? (https://youtu.be/pCiNj2JRK50?t=1869) 
- Why does the example in section 2.5.1 make 3 copies when its a data frame? (https://youtu.be/pCiNj2JRK50?)t=2096) 
- Where can I learn more about copy behavior with primitive functions? (https://youtu.be/pCiNj2JRK50?t=2587) 

Chapter 3 Questions:
- There don’t seem to be as many differences between tibbles and data frames as we thought. What would be an ideal situation in which to use tibbles? (https://youtu.be/EuNFK3Ob1QQ?t=1424) 
- How do I remove the ‘spec’ attributes that are printed when I use tibbles? (https://youtu.be/EuNFK3Ob1QQ?t=1551) 
- How are we creating slides, is it in markdown? (https://youtu.be/Da6TodA0O9Q?t=79)
- Why does Hadley recommend against using is.numeric()? (https://youtu.be/Da6TodA0O9Q?t=215) 
- In 3.2.5 exercises #3, why is “one” < 2 false? (https://youtu.be/Da6TodA0O9Q?t=455) 
- In what case would you want a data frame, matrix or list as a column in a dataframe? (https://youtu.be/Da6TodA0O9Q?t=755) 

```
library(tidyverse)
library(lubridate)
​
df <-
  tibble(
    visit_key = 1:3,
    enter_date = ymd("2020-01-01"),
    exit_date = enter_date + 3:5
  )
​
df %>%
  mutate(
    date = map2(enter_date, exit_date, seq.Date, by = "day")
  ) %>%
  unnest(date)

  ```
  