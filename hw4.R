##Q1
library(Matrix)
library(lme4)
DATA<-read.csv("~/Desktop/613/hw4/Koop-Tobias.csv")
set.seed(100)
#Randomly select 5 individuals 
vect<-as.vector(sample(1:2178, size=5))
#Set a vector to store the panel dimension of these 5 individuals 
freque<-c()
w<-table(DATA$PERSONID)
w<-as.data.frame(w)
w<-as.matrix(w)
for (i in 1:5){
  ans<-w[vect[i],2]
  freque<-c(freque,ans)
}
#Print the outcome
print(vect)
print(freque)

#Q2
library(nlme)
model_q2<-gls(LOGWAGE~EDUC+POTEXPER, data=DATA)
summary(model_q2)

#Q3
##Between Estimator
fact<-as.factor(DATA$PERSONID)
#Calculate average logwage_i overtime
groupDATAwage<-as.matrix(tapply(DATA$LOGWAGE,fact,FUN=mean))
freque<-as.data.frame(table(DATA$PERSONID))
Freque<-as.matrix(freque$Freq)
DATAlogwagenew<-c()
for (i in 1:nrow(Freque)){
  DATAlogwagenew<-c(DATAlogwagenew,as.vector(rep(groupDATAwage[i,1],Freque[i,1])))
}
#Calculate average educ_i overtime
groupDATAeduc<-as.matrix(tapply(DATA$EDUC,fact,FUN=mean))
DATAeducnew<-c()
for (i in 1:nrow(Freque)){
  DATAeducnew<-c(DATAeducnew,as.vector(rep(groupDATAeduc[i,1],Freque[i,1])))
}
#Calculate average potexper_i overtime
groupDATApote<-as.matrix(tapply(DATA$POTEXPER,fact,FUN=mean))
DATApotenew<-c()
for (i in 1:nrow(Freque)){
  DATApotenew<-c(DATApotenew,as.vector(rep(groupDATApote[i,1],Freque[i,1])))
}
DATApersonidnew<-as.matrix(DATA$PERSONID)
constant<-matrix(1,nrow=17919,ncol=1)
###Do Estimation (Between model)
DATA_q3between<-data.frame(DATApersonidnew,DATAlogwagenew,DATAeducnew,DATApotenew)
DATA_q3between<- DATA_q3between[!duplicated(DATA_q3between$DATApersonidnew),]
model_between<-lm(DATAlogwagenew~DATAeducnew+DATApotenew,data=DATA_q3between)
summary(model_between)$coefficients

##Within Estimator
###Modify the data
DATAlogwagenew_deta<-as.matrix(DATA$LOGWAGE)-DATAlogwagenew
DATAeducnew_deta<-as.matrix(DATA$EDUC)-DATAeducnew
DATApotenew_deta<-as.matrix(DATA$POTEXPER)-DATApotenew
DATApersonidnew<-as.matrix(DATA$PERSONID)
DATA_q3within<-as.matrix(data.frame(DATApersonidnew,DATAlogwagenew_deta,DATAeducnew_deta,DATApotenew_deta))
###Use ols method to calculate within model estimators
X_q3within<-DATA_q3within[,3:4]
Y_q3within<-as.matrix(DATAlogwagenew_deta)
beta_q3within<-solve((t(X_q3within)%*%X_q3within))%*%(t(X_q3within)%*%Y_q3within)
print(beta_q3within)
###Use lm package to check the answer
DATA_q3within<-data.frame(DATApersonidnew,DATAlogwagenew_deta,DATAeducnew_deta,DATApotenew_deta)
model_within<-lm(DATAlogwagenew_deta~DATAeducnew_deta+DATApotenew_deta,data=DATA_q3within)
summary(model_within)$coefficients

##First time difference Estimator
diff_wage<-c()
diff_educ<-c()
diff_potex<-c()
logwage<-as.matrix(DATA$LOGWAGE)
educ<-as.matrix(DATA$EDUC)
potex<-as.matrix(DATA$POTEXPER)
index<-1
### Take the difference of the data
for (i in 1:2178){
  if(Freque[i]>=2){
    #Take variables at time t-1: logwage_t-1, educ_t-1, potexper_t-1
    i_lag_wage<-logwage[index:(index-1+Freque[i]-1),1]
    i_lag_educ<-educ[index:(index-1+Freque[i]-1),1]
    i_lag_potex<-potex[index:(index-1+Freque[i]-1),1]
    #Take variables at time t: logwage_t, educ_t, potexper_t
    #print(index+1)
    #print(freque[i,1])
    i_t_wage<-logwage[(index+1):(index-1+Freque[i]),1]
    i_t_educ<-educ[(index+1):(index-1+Freque[i]),1]
    i_t_potex<-potex[(index+1):(index-1+Freque[i]),1]
    i_diff_wage<-i_t_wage-i_lag_wage
    i_diff_educ<-i_t_educ-i_lag_educ
    i_diff_potex<-i_t_potex-i_lag_potex
    diff_wage<-c(diff_wage,i_diff_wage)
    diff_educ<-c(diff_educ,i_diff_educ)
    diff_potex<-c(diff_potex,i_diff_potex)
    index<-index+Freque[i,1]
  }
}
###Do estimation (First Difference Model)
DATA_q3diff<-as.matrix(data.frame(diff_wage,diff_educ,diff_potex))
X_q3diff<-DATA_q3diff[,2:3]
Y_q3diff<-DATA_q3diff[,1]
beta_q3diff<-solve((t(X_q3diff)%*%X_q3diff))%*%(t(X_q3diff)%*%Y_q3diff)
###Print out the outcome
print(beta_q3diff)
###Use lm package to check the answer
DATA_q3diff<-data.frame(diff_wage,diff_educ,diff_potex)
model_diff<-lm(diff_wage~diff_educ+diff_potex,data=DATA_q3diff)
summary(model_diff)$coefficients


###Q3.4 Compare beta_1 and beta_2 under different models. 
###The beta calculated by using between model and using first difference model are very close. 
###The coefficient of potexper calculated by using all three types of fixed effect model and that by using the random effect model are very similar as well. 
###However, the coefficient of education of the random effect model is a little bit different from that calculated by using fixed effect models.
###This implies that the individual effect might be somekind correlated with the explaining variables 

#Q4
##Q4.1
###Select 100 samples
set.seed(613)
Sample_q4<-sample(1:2178, 100)
DATA_q4<-matrix(0,nrow=1,ncol=9)
for (i in 1:100){
  WAGE_i<-as.matrix(DATA$LOGWAGE[DATA$PERSONID==Sample_q4[i]])
  EDUC_i<-as.matrix(DATA$EDUC[DATA$PERSONID==Sample_q4[i]])
  POTEXPER_i<-as.matrix(DATA$POTEXPER[DATA$PERSONID==Sample_q4[i]])
  PERSONID_i<-as.matrix(DATA$PERSONID[DATA$PERSONID==Sample_q4[i]])
  ABILITY_i<-as.matrix(DATA$ABILITY[DATA$PERSONID==Sample_q4[i]])
  MOTHERED_i<-as.matrix(DATA$MOTHERED[DATA$PERSONID==Sample_q4[i]])
  FATHERED_i<-as.matrix(DATA$FATHERED[DATA$PERSONID==Sample_q4[i]])
  BRKNHOME_i<-as.matrix(DATA$BRKNHOME[DATA$PERSONID==Sample_q4[i]])
  SIBLINGS_i<-as.matrix(DATA$SIBLINGS[DATA$PERSONID==Sample_q4[i]])
  PERSONID_i<-as.matrix(DATA$PERSONID[DATA$PERSONID==Sample_q4[i]])
  individual<-as.matrix(data.frame(PERSONID_i,WAGE_i,EDUC_i,POTEXPER_i,ABILITY_i,MOTHERED_i,FATHERED_i,BRKNHOME_i,SIBLINGS_i))
  DATA_q4<-rbind(DATA_q4,individual)
}

M<-nrow(DATA_q4)
DATA_q4<-DATA_q4[2:M,]
DATA_q4df<-as.data.frame(DATA_q4)
###Get frequency matrix which stores the frequency of each individual's observations
W_q4<-as.data.frame(table(DATA_q4df$PERSONID_i))
Freque_q4<-as.matrix(W_q4$Freq)
###Construct a likelihood function
likelihood<-function(par,DATA.=DATA_q4){
  likewage<-DATA.[,2]
  likeeduc<-DATA.[,3]
  likepotexper<-DATA.[,4]
  alfa<-par[2:101]
  beta1<-par[102]
  beta2<-par[103]
  alfanew<-rep(alfa,Freque_q4)
  alfanew<-as.matrix(alfanew)
  Estimation<-alfanew+likeeduc*beta1+likepotexper*beta2
  proEstimation<-dnorm((likewage- Estimation)/par[1])
  proEstimation[proEstimation<0.00001]<-0.00001
  proEstimation[proEstimation>0.99999]<-0.99999
  loglikelihood<--sum(log(proEstimation))
  return(loglikelihood)
}
###Set initial value for the parameter
parameter<-rnorm(100)
parameter<-c(0.04,parameter,-1.15,0.08)
###Optimize the likelihood function
result_q4.1<-optim(par = parameter,likelihood)
print(result_q4.1)

##Q4.2
###Get alfa by using ols method (Sample: 100 individuals)
result_q4.2<-lm(WAGE_i~EDUC_i+POTEXPER_i+factor(PERSONID_i),data=DATA_q4df)
alfa_q4.2<-as.matrix(coef(result_q4.2))
alfa_q4.2<-alfa_q4.2[3:102]
DATA_q4dfNEW<- DATA_q4df[!duplicated(DATA_q4df$PERSONID_i),]
DATA_4.2dfnew<-data.frame(alfa_q4.2,DATA_q4dfNEW)
#Run a regression of estimated individual ﬁxed eﬀets on the invariant variables.
result_q4.2new<-lm(alfa_q4.2~ABILITY_i+MOTHERED_i+FATHERED_i+BRKNHOME_i+SIBLINGS_i,data=DATA_4.2dfnew)
#Print the outcome
print(summary(result_q4.2new))



## Q4.3
### The standard errors in the previous model are wrong because that there might be some estimation errors which is caused when we generate individual fixed effects.
### We can solve the problem by using bootstrap to try to eliminate the estimation errors generated from individual effects estimation.
coeff<-matrix(0,nro=6,ncol=1)
for (i in 1:100){
  #Sampling
    DATA_q4.3<-matrix(0,nrow=1,ncol=10)
    colnames(DATA_q4.3)<-c("PERSONID","EDUC","LOGWAGE","POTEXPER","TIMETRND","ABILITY","MOTHERED","FATHERED","BRKNHOME","SIBLINGS")
    k<-sample(1:2178,100)
    for (i in 1:100){
      trans<-DATA[DATA$PERSONID==k[i],]
      DATA_q4.3<-rbind(DATA_q4.3,trans)
    }
    DATA_q4.3<-as.matrix(DATA_q4.3)
    n<-nrow(DATA_q4.3)
    DATA_q4.3<-as.data.frame(DATA_q4.3[2:n,])
    #Estimate individual effect
    result_q4.3<-lm(LOGWAGE~EDUC+POTEXPER+factor(PERSONID),data=DATA_q4.3)
    alfa_q4.3<-as.matrix(coef(result_q4.3))
    alfa_q4.3<-alfa_q4.3[3:102]
    DATA_q4.3<-DATA_q4.3[!duplicated(DATA_q4.3$PERSONID),]
    DATA_4.3dfnew<-data.frame(alfa_q4.2,DATA_q4.3)
    #Run a regression of estimated individual ﬁxed eﬀets on the invariant variables.
    result_q4.3new<-lm(alfa_q4.3~ABILITY+MOTHERED+FATHERED+BRKNHOME+SIBLINGS,data=DATA_4.3dfnew)
    result<-summary(result_q4.3new)
    result<-as.matrix(coef(result))
    coeff<-cbind(coeff,result[,1])
}
coeff<-as.matrix(coeff)
coeff<-coeff[,2:101]
result_q4.3<-apply(coeff,1,FUN=var)
#Print the outcome
print(sqrt(result_q4.3))



