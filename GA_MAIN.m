



function generation = GA_MAIN()
clear all;
close all;

global pop numIndivid boundBox density;

%% INITIALIZE DATA STORAGE
boundBox = [-30.2,30,17.8]; %XYZ dimensions
numIndivid = 12;             %number of individuals
density = .0966435; %lb/in^3
ratioParents = (1/3);  %percentage of Parents kept
numKeep = ceil(numIndivid*ratioParents);
mutationRate = .20;
stopCrit = 1*10^-7;                %stopping criterion (error threshold)
offsetMultiplier = 1.6;
uMult = 2;

%% INITIALIZE POPULATION
pop = cell(numIndivid,1);   % population cell Array

mesh1 = read_wobj('Truss1.obj');
fixed = [6 7 8 9];
loaded = [2];
forces = [0 0 -10];

pop{1} = generateGraphFromMesh(mesh1,fixed,loaded,forces);

for i = 2:numIndivid
    pop{i} = randomIndivid(pop{1},offsetMultiplier);
end


updateTrusses();
[costs,currMinFit,avgCost] = assignCosts(uMult);
[matePairs] = selMatePairs(costs,numKeep);
mateTrusses(matePairs,numIndivid,ratioParents);
mutateTrusses(pop,numIndivid,costs,numKeep,mutationRate);

fprintf('INIT POP: random mutations from template\n');
fprintf('currMinCost: %2.4f, avgCost %2.4f\n',currMinFit,avgCost);
gaPlot = plotGeneration(costs,numKeep);



%RUN OPTIMIZATION LOOP
prevMinFit = Inf;
maxIter = 100;
minIter = 20;
currIter = 1;
while(1)
    %ASSIGN COSTS
    updateTrusses();
    [costs,currMinFit] = assignCosts(uMult);
    
    %VISUALIZE
        
    plotGeneration(costs,numKeep);
    fprintf('GENERATION %d\n',currIter);
    fprintf('   minCost: %2.4f, avgCost %2.5f\n',currMinFit,avgCost);
    strTitle = ['GENERATION ',num2str(currIter)];
    uicontrol('Style', 'text',...
       'String', strTitle,...
       'Units','normalized',...
       'Position', [0.9 0.2 0.1 0.1]); 

    %CHECK STOPPING CRITERIA (CONVERGENCE)
    currError = prevMinFit-currMinFit;
    if(currError < stopCrit && currIter>minIter)
        fprintf('stop crit met\n');
        break
    elseif(currIter>maxIter)
        fprintf('maxIter met\n');
        break
    end
    prevMinFit = currMinFit;

    %SELECT MATE PAIRS
    [matePairs] = selMatePairs(costs,numKeep);

    %MATE (overwrite unfit individualsin pop[])
    mateTrusses(matePairs,numIndivid,ratioParents);

    %MUTATE (overwrites individuals in pop[] with mutated versions)
    mutateTrusses(pop,numIndivid,costs,numKeep,mutationRate);
    
    currIter = currIter + 1;
    
end
generation = pop;

fprintf('exited optimization loop');



end


%---------------------------HIGH LEVEL STRUCTURE---------------------------
%initialize data storage
%create population Array D
%seed with a few parents (rand or imported objs) D

%run optimization loop
%assign Costs D
%run deflection tests D
%run mass tests D
%%% run constraint tests
%-convergence check D
%use most fit individual(s) D
%select mate pairs D
%start with rank pairing D
%mate
%start with single-point cross over
%%% point interpolation
%mutate
%include gene elitism (do not mutate best n genes)


%ouput best individuals
%save obj files
%visualize D

%---------------------------DATA STRUCTURES--------------------------------
%�create history array to save past parents (for visualization )?

%options for fitness data structure:
%1) create seperate fitness array
%2) have fitness variable in each individual <- for now seems good

%GENOME:
%.nodes
%.edges
%.areas
%.F
%.U
%.R

%constant for every genome:
%.elasticmodulus
%.restraints
%.loads

%---------------------------UNRESOLVED HIGHLEVEL---------------------------
%where to include stopping criterion?
%fitness scores:
%are the scores integers or floats??
%are the fitness scores stored in each genome or as a seperate array?

%---------------------------RESOLVED HIGHLEVEL-----------------------------
%DECISION: zero is fittest, Inf unfittest
%DECISION: stopping criterion calculated outside of runGeneration()

