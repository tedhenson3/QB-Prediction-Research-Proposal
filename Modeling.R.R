library(readr)
library(tidyverse)
football <- read_csv("C:/Program Files/PostgreSQL/11/data/football.csv")

football = na.omit(football)


football = football %>% arrange(playername, desc(yds_g))
football = football %>% 
  group_by(playername) %>% 
  filter(row_number()==1)

football = football %>% arrange(desc(total_qbr))

library(caret)
library(caretEnsemble)

library(ggplot2)

#football[,2:ncol(football)] = scale(football[,2:ncol(football)], center = T, scale = T)
ggplot(football, mapping = aes(x = yds_g, y =rating ))   + 
  geom_point(mapping = aes(size = total_qbr)) +  
  theme_bw() + 
  xlab('Maxpreps Yards Per Game') + ylab('247 Rating') + 
  ggtitle('') +
  theme(text=element_text(size=14)) + 
  guides(size=guide_legend(title="Total QBR")) + 
  scale_fill_discrete(name = "New Legend Title")




train_ind <- createDataPartition(y = football$total_qbr, p = .65, list = F)

train <- football[train_ind, ]
test <- football[-train_ind, ]




set.seed(10001)
fitControl <- trainControl(
  method = 'cv',                   # k-fold cross validation
  number = 20,  
  
  savePredictions = 'final'       # saves predictions for optimal tuning parameter
) 





library(caretEnsemble)
library(deepboost)
library(brnn)

algorithmList <- c('bridge',
                   'blasso',
                   'brnn',
                   'rf')

set.seed(100)

terms = colnames(football)[3:ncol(football)]

fmla <- as.formula(paste('total_qbr ~ ', paste(terms, collapse = " + "), sep = ""))



models <- caretList(form = fmla, data=train, trControl=fitControl, 
                    methodList=algorithmList)

results <- resamples(models)


set.seed(10001)
stackControl <- trainControl(
  method = 'cv',                   # k-fold cross validation
  number = 20,  
  savePredictions = 'final'      # saves predictions for optimal tuning parameter
) 

stack.glm <- caretStack(models, 
                        method = "glm", 
                        trControl=stackControl) 



# test[,2:ncol(test)] <- predict(knn.impute, newdata = test[,2:ncol(test)])



bridge = predict(models$bridge, test)
rf = predict(models$rf, test)
brnn = predict(models$brnn, test)
stacked <- predict(stack.glm, test)
blasso <- predict(models$blasso, test)


#compute the residuals
error.stacked <- test$total_qbr - stacked
error.bridge <- test$total_qbr - bridge
error.rf <- test$total_qbr - rf
error.brnn <- test$total_qbr - brnn
error.blasso <- test$total_qbr - blasso

rmse.stacked <- mean(sqrt((error.stacked^2)))
rmse.bridge <- mean(sqrt((error.bridge^2)))
rmse.rf <- mean(sqrt((error.rf^2)))
rmse.brnn = mean(sqrt(error.brnn^2))
rmse.blasso = mean(sqrt(error.blasso^2))


all.inputs.matrix = matrix(nrow = 5, ncol = 2)
all.inputs.matrix[1,1] = 'Stacked Model'
all.inputs.matrix[2,1] = 'Bayesian Ridge'
all.inputs.matrix[3,1] = 'Random Forest'
all.inputs.matrix[4,1] = 'brnn'
all.inputs.matrix[5,1] = 'Bayesian Lasso'

all.inputs.matrix[1,2] = rmse.stacked
all.inputs.matrix[2,2] = rmse.bridge
all.inputs.matrix[3,2] = rmse.rf
all.inputs.matrix[4,2] = rmse.brnn
all.inputs.matrix[5,2] = rmse.blasso

all.inputs.matrix = as.data.frame(all.inputs.matrix)
colnames(all.inputs.matrix)[1] = 'Model Type'
colnames(all.inputs.matrix)[2] = 'Root Mean Squared Error'
print(all.inputs.matrix)




ggplot() + 
  
  #select type of plot (such as bar graph, histogram, etc.). set x and y = to your variables
  
  geom_point(aes(x = rf, y = error.rf)) + 
  geom_hline(yintercept=0, col="skyblue", linetype="dashed") + 
  #draw line of best fit through the points
  
  #set plot title and subtitles
  labs(title = 'Random Forest Model Performance', 
       subtitle = paste('Out-of-Sample RMSE = ', round(rmse.rf, 4), sep = '')) + 
  
  #set x axis title
  xlab(label = 'Predicted Total QBR') + 
  
  #set y axis title
  ylab(label = 'Residuals')




