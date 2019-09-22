setwd("~/analytics/recruiting project")
#maxpreps <- c("http://www.maxpreps.com/leaders/basketball-winter-16-17/,scoring/alaska/stat-leaders-2.htm?classyear=all&position=all")

#vector of state names: state.name

#two word states, seperate by a plus
#http://www.maxpreps.com/leaders/basketball-winter-16-17/,scoring/stat-leaders-10.htm?classyear=all&position=all
#each page only goes to 10 no matter what

#state.list <- c("california", "georgia", "alabama", ....)


my.states <- tolower(state.name)

my.states <- gsub(" ", "+", my.states, fixed = T)

library(tidyverse)
library(rvest)

b <- 12
r <- 1
while(r <  length(my.states)){

  print((r / 50)*100)
  state <- my.states[r]
  
  q <- 1
  while(q < 11){
    if(q > 1){
      
      
      
      maxpreps <- paste("http://www.maxpreps.com/leaders/football-fall-", b, "/offense,passing/", 
                        state, 
                        "/stat-leaders-", 
                        q, 
                        ".htm?classyear=all&position=all", 
                        sep = "")
    }
    
    if(q == 1) {
      
      maxpreps <- paste("http://www.maxpreps.com/leaders/football-fall-", b, "/offense,passing/", 
                        state, 
                        "/stat-leaders", 
                        ".htm?classyear=all&position=all", 
                        sep = "")
    }
    
    
    stats = maxpreps %>%
      read_html() %>%
      html_table()
    
    if(q == 1 & r == 2){
      
      
    }
    
    if(length(stats) == 0){
      
      q <- 11
    
    }
    
    else{
      
      
      
      
      high.school <- as.data.frame(stats[[1]])
      
      high.school$State <- state
      
      high.school$Year <- b
      
      split <- strsplit(high.school$Name, ' - ')
      
      
      
      
      
      for(i in 1:length(split)){
        
        
        high.school[i, 'Name'] <-  split[[i]][1]
        
        
        substring_list <- c("Sr", "Jr", "So", "Fr")
        junk <- split[[i]][2]
        
        high.school[i, 'Class'] <- substr(junk, 1,2)
        
        high.school[i, 'High.School'] <- substr(junk, 3, nchar(junk))
        
        
        
      }
      
      
      
      
      if(r == 1 & q == 1){
        
        all.stats <- high.school
      }
      
      
      
      
      if(r > 1 | q > 1){
        
        
        
        
        
        
        all.stats <- rbind(all.stats, high.school)

        
        
        
      }
      q <- q + 1
      
    }
    
    
    if(q == 11){
      r <- r + 1
      
    } 
  }
}
  

write.csv(all.stats, file = "maxpreps.qb.stats.12.csv", row.names = F)
