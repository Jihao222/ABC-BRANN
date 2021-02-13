clear all;
close all;
clc;
load data0;
XX=AB(:,1:2);
YY=AB(:,3);
[Pn,mp]=mapminmax(XX(:,1)');
[Tn,mt]=mapminmax(XX(:,2)');
XX=[Pn',Tn'];
inp=size(XX,2);
out=size(YY,2);
hidden=20;%% 
X = XX';
YY= YY';
save data2 X YY % 


%/* Control Parameters of ABC algorithm*/
NP=50; %/* The number of colony size (employed bees+onlooker bees)*/
FoodNumber=NP/2; %/*The number of food sources equals the half of the colony size*/
maxCycle=1000; %/*The number of cycles for foraging {a stopping criteria}*/
net=newff(minmax(X),[hidden,1],{'tansig','purelin'});
%/* Problem specific variables*/
objfun='nntrainxor221b'; %cost function to be optimized
D=inp*hidden+out*hidden+hidden+1; %/*The number of parameters of the problem to be optimized*/
ub=ones(1,D)*100; %/*lower bounds of the parameters. */
lb=ones(1,D)*(-100);%/*upper bounds of the parameters.*/
limit=FoodNumber*D; %/*A food source which could not be improved through "limit" trials is abandoned by its employed bee*/
runtime=1;%/*Algorithm can be run many times in order to see its robustness*/



%Foods [FoodNumber][D]; /*Foods is the population of food sources. Each row of Foods matrix is a vector holding D parameters to be optimized. The number of rows of Foods matrix equals to the FoodNumber*/
%ObjVal[FoodNumber];  /*f is a vector holding objective function values associated with food sources */
%Fitness[FoodNumber]; /*fitness is a vector holding fitness (quality) values associated with food sources*/
%trial[FoodNumber]; /*trial is a vector holding trial numbers through which solutions can not be improved*/
%prob[FoodNumber]; /*prob is a vector holding probabilities of food sources (solutions) to be chosen*/
%solution [D]; /*New solution (neighbour) produced by v_{ij}=x_{ij}+\phi_{ij}*(x_{kj}-x_{ij}) j is a randomly chosen parameter and k is a randomlu chosen solution different from i*/
%ObjValSol; /*Objective function value of new solution*/
%FitnessSol; /*Fitness value of new solution*/
%neighbour, param2change; /*param2change corrresponds to j, neighbour corresponds to k in equation v_{ij}=x_{ij}+\phi_{ij}*(x_{kj}-x_{ij})*/
%GlobalMin; /*Optimum solution obtained by ABC algorithm*/
%GlobalParams[D]; /*Parameters of the optimum solution*/
%GlobalMins[runtime]; /*GlobalMins holds the GlobalMin of each run in multiple runs*/

GlobalMins=zeros(1,runtime);

for r=1:runtime
  
% /*All food sources are initialized */
%/*Variables are initialized in the range [lb,ub]. If each parameter has different range, use arrays lb[j], ub[j] instead of lb and ub */

Range = repmat((ub-lb),[FoodNumber 1]);
Lower = repmat(lb, [FoodNumber 1]);
Foods = rand(FoodNumber,D) .* Range + Lower;

ObjVal=feval(objfun,Foods,net);
Fitness=calculateFitness(ObjVal);

%reset trial counters
trial=zeros(1,FoodNumber);

%/*The best food source is memorized*/
BestInd=find(ObjVal==min(ObjVal));
BestInd=BestInd(end);
GlobalMin=ObjVal(BestInd);
GlobalParams=Foods(BestInd,:);

iter=1;
S=[];
time=[];
while ((iter <= maxCycle))

%%%%%%%%% EMPLOYED BEE PHASE %%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:(FoodNumber)
        
        %/*The parameter to be changed is determined randomly*/
        Param2Change=fix(rand*D)+1;
        
        %/*A randomly chosen solution is used in producing a mutant solution of the solution i*/
        neighbour=fix(rand*(FoodNumber))+1;
       
        %/*Randomly selected solution must be different from the solution i*/        
            while(neighbour==i)
                neighbour=fix(rand*(FoodNumber))+1;
            end;
        
       sol=Foods(i,:);
       %  /*v_{ij}=x_{ij}+\phi_{ij}*(x_{kj}-x_{ij}) */
       sol(Param2Change)=Foods(i,Param2Change)+(Foods(i,Param2Change)-Foods(neighbour,Param2Change))*(rand-0.5)*2;
        
       %  /*if generated parameter value is out of boundaries, it is shifted onto the boundaries*/
        ind=find(sol<lb);
        sol(ind)=lb(ind);
        ind=find(sol>ub);
        sol(ind)=ub(ind);
        
        %evaluate new solution
        ObjValSol=feval(objfun,sol,net);
        FitnessSol=calculateFitness(ObjValSol);
        
       % /*a greedy selection is applied between the current solution i and its mutant*/
       if (FitnessSol>Fitness(i)) %/*If the mutant solution is better than the current solution i, replace the solution with the mutant and reset the trial counter of solution i*/
            Foods(i,:)=sol;
            Fitness(i)=FitnessSol;
            ObjVal(i)=ObjValSol;
            trial(i)=0;
        else
            trial(i)=trial(i)+1; %/*if the solution i can not be improved, increase its trial counter*/
       end;
         
         
    end;

%%%%%%%%%%%%%%%%%%%%%%%% CalculateProbabilities %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%/* A food source is chosen with the probability which is proportioal to its quality*/
%/*Different schemes can be used to calculate the probability values*/
%/*For example prob(i)=fitness(i)/sum(fitness)*/
%/*or in a way used in the metot below prob(i)=a*fitness(i)/max(fitness)+b*/
%/*probability values are calculated by using fitness values and normalized by dividing maximum fitness value*/
% 
% prob=(0.9.*Fitness./max(Fitness))+0.1;
prob=Fitness./sum(Fitness);
%   
%%%%%%%%%%%%%%%%%%%%%%%% ONLOOKER BEE PHASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

i=1;
t=0;
while(t<FoodNumber)
    if(rand<prob(i))
        t=t+1;
        %/*The parameter to be changed is determined randomly*/
        Param2Change=fix(rand*D)+1;
        
        %/*A randomly chosen solution is used in producing a mutant solution of the solution i*/
        neighbour=fix(rand*(FoodNumber))+1;
       
        %/*Randomly selected solution must be different from the solution i*/        
            while(neighbour==i)
                neighbour=fix(rand*(FoodNumber))+1;
            end;
        
       sol=Foods(i,:);
       %  /*v_{ij}=x_{ij}+\phi_{ij}*(x_{kj}-x_{ij}) */
       sol(Param2Change)=Foods(i,Param2Change)+(Foods(i,Param2Change)-Foods(neighbour,Param2Change))*(rand-0.5)*2;
        
       %  /*if generated parameter value is out of boundaries, it is shifted onto the boundaries*/
        ind=find(sol<lb);
        sol(ind)=lb(ind);
        ind=find(sol>ub);
        sol(ind)=ub(ind);
        
        %evaluate new solution
        ObjValSol=feval(objfun,sol,net);
        FitnessSol=calculateFitness(ObjValSol);
        
       % /*a greedy selection is applied between the current solution i and its mutant*/
       if (FitnessSol>Fitness(i)) %/*If the mutant solution is better than the current solution i, replace the solution with the mutant and reset the trial counter of solution i*/
            Foods(i,:)=sol;
            Fitness(i)=FitnessSol;
            ObjVal(i)=ObjValSol;
            trial(i)=0;
        else
            trial(i)=trial(i)+1; %/*if the solution i can not be improved, increase its trial counter*/
       end;
    end;
    
    i=i+1;
    if (i==(FoodNumber)+1) 
        i=1;
    end;   
end; 


%/*The best food source is memorized*/
         ind=find(ObjVal==min(ObjVal));
         ind=ind(end);
         if (ObjVal(ind)<GlobalMin)
         GlobalMin=ObjVal(ind);
         GlobalParams=Foods(ind,:);
         end;
         
         
%%%%%%%%%%%% SCOUT BEE PHASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%/*determine the food sources whose trial counter exceeds the "limit" value. 
%In Basic ABC, only one scout is allowed to occur in each cycle*/

ind=find(trial==max(trial));
ind=ind(end);
if (trial(ind)>limit)
    Bas(ind)=0;
    sol=(ub-lb).*rand(1,D)+lb;
    ObjValSol=feval(objfun,sol,net);
    FitnessSol=calculateFitness(ObjValSol);
    Foods(ind,:)=sol;
    Fitness(ind)=FitnessSol;
    ObjVal(ind)=ObjValSol;
end;

fprintf('Ýter=%d ObjVal=%g\n',iter,GlobalMin);
S(iter)=GlobalMin;
time(iter)=iter;

iter=iter+1;
end % End of ABC

GlobalMins(r)=GlobalMin;
end; %end of runs
% figure(1)
    plot(time,S)
title('The Best Individual Fitness','fontsize',12)
xlabel('Number of Iteration','fontsize',12);ylabel('MSE','fontsize',12);

for i=1:5  
     x=GlobalParams; 
     iw = reshape(x(1:hidden*inp),hidden,inp);
    b1 = reshape(x(hidden*inp+1:hidden*inp+hidden),hidden,1);
    lw = reshape(x(hidden*inp+hidden+1:hidden*inp+hidden+hidden*out),out,hidden);
    b2 = reshape(x(hidden*inp+hidden+hidden*out+1:hidden*inp+hidden+hidden*out+out),out,1);  
    net=newff(minmax(X),[hidden,1],{'tansig','purelin'},'trainbr','traingdx');
      
net.IW{1,1}=iw;
net.LW{2,1}=lw;
net.b{1}=b1;
net.b{2}=b2;
net.divideFcn = 'dividerand';  % Divide data randomly
net.divideMode = 'sample';  % Divide up every sample
net.divideParam.trainRatio =85/100;
net.divideParam.valRatio = 0/100;
net.divideParam.testRatio =15/100;
net.trainParam.show = 1; 
net.trainParam.lr = 0.05; 
net.trainParam.mc = 0.5; 
net.trainParam.epochs =200; 
net.trainParam.goal = 1e-10; 
%ÑµÁ·ÍøÂç
net=train(net,X,YY);
iw=net.IW{1,1};
lw=net.LW{2,1};
b1=net.b{1};
b2=net.b{2};

load data1;
dd=AB1(:,1:2);  
dd1=mapminmax('apply',dd(:,1)',mp);
dd2=mapminmax('apply',dd(:,2)',mt);
dd=[dd1',dd2']';
ee=AB1(:,3);
ff(:,i)=sim(net,dd)'; 
[k1,k2]=size(ff)
for k=1:k1
    if ff(k)<0
        ff(k)=0;
    end
end
yy(:,i)=sim(net,X)';
r2(i)=corr(YY',yy(:,i),'type','pearson');
r1(i)=corr(ff(:,i),ee,'type','pearson');
 end

