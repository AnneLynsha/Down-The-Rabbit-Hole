#QUESTION 1
equity<-read.csv("C:/Users/annie/OneDrive/Desktop/R Directory/CSV files/Equity.csv")

# B - Change structure of variables
equity$BAD<-as.factor(equity$BAD)
equity$LOAN<-as.numeric(equity$LOAN)
equity$REASON<-as.factor(equity$REASON)
equity$JOB<-as.factor(equity$JOB)
str(equity)

# C - Finding and removing outliers
outlier_remover <- function(a){    
  df <- read.csv(a)
  df<-na.omit(df)
  aa<-c()    
  count<-1    
  for(i in 1:ncol(df)){        
    if(is.numeric(df[,i])){            
      for(j in 1:nrow(df)){               
        if(df[j,i] > mean(df[,i], na.rm =TRUE)+2*sd(df[,i], na.rm =TRUE)|df[j,i]<mean(df[,i], na.rm =TRUE)-2*sd(df[,i], na.rm =TRUE)){                        
          aa[count]<-j                        
          count<-count+1                                  
        }            
      }        
    }    
  }    
  df<-df[-aa,]
}

new_equity<-outlier_remover("C:/Users/annie/OneDrive/Desktop/R Directory/CSV files/Equity.csv")
new_equity

# D - Creating new Bad Binary variable
new_equity$BAD_BINARY<-with(new_equity, ifelse(BAD == "Bad Risk",1, ifelse(BAD == "Good Risk",0,NA)))

table(new_equity$BAD_BINARY)
new_equity$BAD_BINARY<-as.integer(new_equity$BAD_BINARY)
new_equity$BAD<-NULL
str(new_equity)

# E - Checking for typographical errors in factor variables
library(tidyr)
par(mar = rep(2, 4))
barplot(table(new_equity$REASON))
barplot(table(new_equity$JOB))
summary(new_equity)

# F - Remove missing values
new_equity <- na.omit(new_equity)

# G - Check for multicollinerarity issues
cor(new_equity[c("LOAN","MORTDUE","VALUE","YOJ","CLAGE","DEBTINC")])
#There is multicollinearity between the mortdue and value variables

# H - Check structure
dim(new_equity)  #THERE ARE 2546 OBS AND 13 VARIABLES

# I - Set seed and train data
library(splitstackshape)
set.seed(100)
splitData<-stratified(new_equity, "BAD_BINARY", 0.8, bothSets = TRUE)
equityTraining<-as.data.frame(splitData$SAMP1)
equityTest<-as.data.frame(splitData$SAMP2)

# J - Fit a logistic regression model on BAD_BINARY
library(caret)
library(forecast)
library(ggplot2)
library(lattice)
library(e1071)
log_equity<-glm(BAD_BINARY~., data=equityTraining)
summary(log_equity)
equityPredicted<- predict(log_equity,equityTest,"response")
equityPredicted
accuracy(equityTest$BAD_BINARY,equityPredicted)
?predict

#Confusion matrix and misclassification rate

predictedFactor<-ifelse(equityPredicted>=0.5,1,0)
confusionMatrix(as.factor(equityTest$BAD_BINARY)
                ,as.factor(predictedFactor), positive = "1")

# K - Fit classification tree on BAD_BINARY 
library(rpart)
install.packages("relaimpo")
library(relaimpo)

classEquity<-rpart(BAD_BINARY~.,data=equityTraining)
Predequity<-predict(classEquity,equityTest)
accuracy(equityTest$BAD_BINARY,Predequity)
library(rpart.plot)
rpart.plot(classEquity)

EquityVar = varImp(classEquity,scale =FALSE)
EquityVar

# L - Creating different models

#1) BAD_BINARY and DIFFERENT multiple

model_1<-rpart(BAD_BINARY~CLAGE,data=equityTraining)
Predequity1<-predict(model_1,equityTest)
accuracy1<-accuracy(equityTest$BAD_BINARY,Predequity1)
accuracy1

model_2<-rpart(BAD_BINARY~CLAGE+DEBTINC,data=equityTraining)
Predequity2<-predict(model_2,equityTest)
accuracy2<-accuracy(equityTest$BAD_BINARY,Predequity2)

model_3<-rpart(BAD_BINARY~CLAGE+DEBTINC+CLNO,data=equityTraining)
Predequity3<-predict(model_3,equityTest)
accuracy3<-accuracy(equityTest$BAD_BINARY,Predequity3)

model_4<-rpart(BAD_BINARY~CLAGE+DEBTINC+CLNO+JOB,data=equityTraining)
Predequity4<-predict(model_4,equityTest)
accuracy4<-accuracy(equityTest$BAD_BINARY,Predequity4)

model_5<-rpart(BAD_BINARY~CLAGE+DEBTINC+CLNO+JOB+LOAN,data=equityTraining)
Predequity5<-predict(model_5,equityTest)
accuracy5<-accuracy(equityTest$BAD_BINARY,Predequity5)

model_6<-rpart(BAD_BINARY~CLAGE+DEBTINC+CLNO+JOB+LOAN+VALUE,data=equityTraining)
Predequity6<-predict(model_6,equityTest)
accuracy6<-accuracy(equityTest$BAD_BINARY,Predequity6)

model_7<-rpart(BAD_BINARY~CLAGE+DEBTINC+CLNO+JOB+LOAN+VALUE+MORTDUE,data=equityTraining)
Predequity7<-predict(model_7,equityTest)
accuracy7<-accuracy(equityTest$BAD_BINARY,Predequity7)

model_8<-rpart(BAD_BINARY~CLAGE+DEBTINC+CLNO+JOB+LOAN+VALUE+MORTDUE+YOJ,data=equityTraining)
Predequity8<-predict(model_8,equityTest)
accuracy8<-accuracy(equityTest$BAD_BINARY,Predequity8)

model_9<-rpart(BAD_BINARY~CLAGE+DEBTINC+CLNO+JOB+LOAN+VALUE+MORTDUE+YOJ+REASON,data=equityTraining)
Predequity9<-predict(model_9,equityTest)
accuracy9<-accuracy(equityTest$BAD_BINARY,Predequity9)

model_10<-rpart(BAD_BINARY~CLAGE+DEBTINC+CLNO+JOB+LOAN+VALUE+MORTDUE+YOJ+REASON+NINQ,data=equityTraining)
Predequity10<-predict(model_10,equityTest)
accuracy10<-accuracy(equityTest$BAD_BINARY,Predequity10)

model_11<-rpart(BAD_BINARY~CLAGE+DEBTINC+CLNO+JOB+LOAN+VALUE+MORTDUE+YOJ+REASON+NINQ+DELINQ,data=equityTraining)
Predequity11<-predict(model_11,equityTest)
accuracy11<-accuracy(equityTest$BAD_BINARY,Predequity11)

model_12<-rpart(BAD_BINARY~CLAGE+DEBTINC+CLNO+JOB+LOAN+VALUE+MORTDUE+YOJ+REASON+NINQ+DELINQ+DEROG,data=equityTraining)
Predequity12<-predict(model_12,equityTest)
accuracy12<-accuracy(equityTest$BAD_BINARY,Predequity12)


# M - Accuracy of all models

accuracy1
accuracy2
accuracy3
accuracy4
accuracy5
accuracy6
accuracy7
accuracy8
accuracy9
accuracy10
accuracy11
accuracy12

#Based on accuracy model 

#QUESTION 2
equity2<-read.csv("C:/Users/annie/OneDrive/Desktop/R Directory/CSV files/Equity.csv")

# B - Change structure of variables
equity2$BAD<-as.factor(equity2$BAD)
equity2$LOAN<-as.numeric(equity2$LOAN)
equity2$REASON<-as.factor(equity2$REASON)
equity2$JOB<-as.factor(equity2$JOB)
str(equity2)

# C - Finding and removing outliers
outlier_remover <- function(a){    
  df <- read.csv(a)
  df<-na.omit(df)
  aa<-c()    
  count<-1    
  for(i in 1:ncol(df)){        
    if(is.numeric(df[,i])){            
      for(j in 1:nrow(df)){               
        if(df[j,i] > mean(df[,i], na.rm =TRUE)+2*sd(df[,i], na.rm =TRUE)|df[j,i]<mean(df[,i], na.rm =TRUE)-2*sd(df[,i], na.rm =TRUE)){                        
          aa[count]<-j                        
          count<-count+1                                  
        }            
      }        
    }    
  }    
  df<-df[-aa,]
}

new_equity2<-outlier_remover("C:/Users/annie/OneDrive/Desktop/R Directory/CSV files/Equity.csv")
new_equity2

# D - Creating new Bad Binary variable
new_equity2$BAD_BINARY<-with(new_equity2, ifelse(BAD == "Bad Risk",1, ifelse(BAD == "Good Risk",0,NA)))

table(new_equity2$BAD_BINARY)
new_equity2$BAD_BINARY<-as.integer(new_equity2$BAD_BINARY)
new_equity2$BAD<-NULL
str(new_equity2)

# E - Checking for typographical errors in factor variables
library(tidyr)
par(mar = rep(2, 4))
barplot(table(new_equity2$REASON))
barplot(table(new_equity2$JOB))
summary(new_equity2)

# F - Remove missing values
new_equity2 <- na.omit(new_equity2)
summary(new_equity2)

#Check multicollinearity 
library(psych)
pairs.panels(new_equity2[c("LOAN","MORTDUE","VALUE","YOJ","CLAGE","DEBTINC")])

#STEPWISE REGRESSION
equity2model<-lm(LOAN~.,data = new_equity2)                   
step_equity2model<-step(equity2model)
summary(step_equity2model)
#Significant variables are : 
#MORTDUE + VALUE + REASON + JOB + YOJ + DEROG + CLAGE + 
#NINQ + CLNO + DEBTINC + BAD_BINARY

#D - CHECK ASUSUMPTIONS
#1.Normal distribution?
par(mfrow=c(1,1))
hist(residuals(step_equity2model))
#Histogram shows a perfectly normal distribution


#2.Linearity
scatter.smooth(x = predict(step_equity2model, new_equity2),                
               y = residuals(step_equity2model), ylab = "residuals",               
               xlab = "predicted", main = "Linearity")

#The model is linear 

#3.
plot(step_equity2model)
#the normal Q-Q plot shows 

#E - TRAIN DATA
library(rpart)
set.seed(100)
equity2Index<-sample(1:nrow(new_equity2), 0.8*nrow(new_equity2))
equity2Training<-new_equity2[equity2Index,]
equity2Test<-new_equity2[-equity2Index,]

#MULTIPLE REGRESSION MODEL
other_equity2model<-lm(LOAN~MORTDUE+VALUE+REASON+JOB+YOJ+DEROG+CLAGE+NINQ+CLNO+DEBTINC+BAD_BINARY,data=equity2Training)
summary(other_equity2model)
otherPredict<-predict(other_equity2model,equity2Test)
otherPredict
accuracyMulti<-accuracy(equity2Test$LOAN,otherPredict)

#Regression tree model
regress_equity<-rpart(LOAN~MORTDUE+VALUE+REASON+JOB+YOJ+DEROG+CLAGE+ 
                       NINQ+CLNO+DEBTINC+BAD_BINARY,data=equity2Training)
regressPredict<-predict(regress_equity,equity2Test)
accuracyRegress<-accuracy(equity2Test$LOAN,regressPredict)
rpart.plot(regress_equity)

#Based on the three models, the best prediction power goes to the Regression model
#The regression tree model has as RSME of 5426.699
#The multiple regression model has as RSME of 6064.207
accuracyRegress
accuracyMulti
