
#football url
# url_247 <- c("https://247sports.com/Season/2018-Football/CompositeCompositeRecruitRankings/?InstitutionGroup=highschool")




pg_url_247 <- c("https://247sports.com/Season/2017-Basketball/CompositeRecruitRankings/?InstitutionGroup=highschool&Position=PG")

url_247 <- c("https://247sports.com/Season/2012-Football/CompositeRecruitRankings/?InstitutionGroup=highschool&PositionGroup=QB")


library(tidyverse)
library(rvest)

css_tags <- '.score , .other , .position , .rank , .sttrank , .posrank , .natrank , .hw , .rankings-page__name-link , .meta , .metrics , .pos , .name'
rankings_2018 = url_247 %>%
  read_html() %>%
  html_nodes(css=css_tags) %>% html_text()

#View(rankings_2018)

#mycolnames <- rankings_2018[1:5]


rankings_2018 <- rankings_2018[6:length(rankings_2018)]


indices <- seq(from = 1, to = length(rankings_2018), by = 10)



clean.data <- data.frame(matrix(ncol = 10, nrow = 0))


for(i in 1:c(length(indices)-1)){
  
  start <- indices[i]
  
  
  end <- indices[i+1] - 1
  
  row <- rankings_2018[start:end]
  
  
  
  clean.data[i,] <- row
  
}


colnames(clean.data) <- c("Previous.National.Ranking", "Name", "Hometown", "Position", 
                          "Height.Weight", "Rating", "All Ratings", "National.Ranking",
                          "Position.Ranking", "State.Ranking")




for(i in 1:length(clean.data$Name)){
  
  player <- clean.data[i, 'Name']
  
  lower.player <- tolower(player)
  
  lower.player <- gsub(" jr.", "jr", lower.player, fixed = T)
  lower.player <- gsub(" sr.", "sr", lower.player, fixed = T)
  
  lower.player <- gsub(" iii", "iii", lower.player, fixed = T)
  lower.player <- gsub(" ii", "ii", lower.player, fixed = T)
  lower.player <- gsub(" iv", "iv", lower.player, fixed = T)
  
  
  lower.player <- gsub(".", "", lower.player, fixed = T)
  first.last <- strsplit(lower.player, ' ')
  
  #print(first.last)
  
  clean.data[i, 'player.id'] <- paste(first.last[[1]][1:length(first.last[[1]])], collapse = "-")
  
}
poslist <- c("PG", "SG", "CG", "SF", "PF", "C")

clean.data$bball.ref.link = paste("https://www.sports-reference.com/cfb/players/", clean.data$player.id, "-1.html",
                                  sep = "")

rankings.247 <- clean.data

print(rankings.247)

#write.csv(rankings.247, file = 'qb.rankings.247.2012.csv', row.names = F)


# team.tag = '.png" title="'
# 
# 
# teams = readLines(pg_url_247)
# 
# top.50.pos = grep('ViewPath=', teams)
# 
# teams <- teams[1:top.50.pos]
#View(teams)



