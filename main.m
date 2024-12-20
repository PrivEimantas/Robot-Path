%% cw2

map = im2bw(imread('random_map.bmp'));

iter=98;% Number of times it will loop over in total
population_size=100; %number of chromosomes
noOfPointsInSolution=10; %how many points line being drawn to
population = zeros(population_size,noOfPointsInSolution*2);

for i = 1:population_size
    %generate random points to be mapped..
    population(i,:) = sort(randperm(500,noOfPointsInSolution*2)); % random X,Y values
end
% add extra rows for keeping values
DistMat = population;
population = [population zeros(population_size,1)];

%Get user input for selection
selectionType=input("Pick selection type: "); %0,1,2: Roulette,Tournament,Rank
%Get user input for crossover
crossoverType=input("Pick crossover type: "); %0,1 :K-point, Uniform 
%Get user input for mutation
mutationType=input("Pick mutation type: "); %0,1: Add on value at random point, swap values between two random points

tic
%repeat iter times.. generations
for k = 1:iter
     %evaluate fitness scores
    for i = 1:population_size
        %%fitness function for initial distances: the value at top should have the smaller distance
        tempX = population(i,1:2:noOfPointsInSolution*2); %extract X,Y values
        tempY = population(i,2:2:noOfPointsInSolution*2);
        temp = zeros(noOfPointsInSolution,2);
        temp(:,1)=tempX;temp(:,2)=tempY; %insert X,Y Values
    
        tempA=zeros(noOfPointsInSolution+1,2);tempB=tempA; %Creating the chromosome with X and Y values
        
        tempA(2:noOfPointsInSolution+1,:)=temp; % Attatches values of [1 1] to start as starting point
        tempA(1,1)=1;tempA(1,2)=1;
        
        tempB(1:noOfPointsInSolution,:)=temp; % Attatches values of [500 500] on end as final point
        tempB(noOfPointsInSolution+1,1)=500;tempB(noOfPointsInSolution+1,2)=500;
        
        EuclideanDistance =norm(tempA-tempB);
        penalty = calculatePenalty(population(i,1:noOfPointsInSolution*2),map); %checks if passed thru obstacle
        if(size(penalty,2)>1)
            penalty=penalty(1); 
        end
        population(i,noOfPointsInSolution*2 +1)=EuclideanDistance+penalty*3; %adds on, if none passed thru black values then will be 0
        
    end
    %% elite, keep best 30%
    population = sortrows(population,noOfPointsInSolution*2 + 1);
    
    population_new = zeros(population_size,noOfPointsInSolution*2);
   
    population_new(1:(0.3*population_size),:) = population(1:0.3*population_size,1:noOfPointsInSolution*2);
    population_new_num = (0.3*population_size);
    %% repeat until new population is full
    while (population_new_num < population_size)
        %% use a selection method and pick two chromosomes

        choice1=0; %initialize
        choice2=0;
        if(selectionType==0) %Roulette wheel
            weights = population(:,noOfPointsInSolution*2 +1)/sum(population(:,noOfPointsInSolution*2 +1));
            choice1 = RouletteWheelSelection(weights);
            choice2 = RouletteWheelSelection(weights);

        end
        if(selectionType==1) % Tournament Selection
              choice1 = tournamentSelection(population,2);
              choice2= tournamentSelection(population,2);
    
        end
        

       if(selectionType==2) % Rank selection
           choice1= rankSelection(population);
           choice2=rankSelection(population);
       end

        
        %Select values
        temp_chromosome_1 = population(choice1, 1:noOfPointsInSolution*2);
        temp_chromosome_2 = population(choice2, 1:noOfPointsInSolution*2);
        
        %% crossover operator
        if (rand < 0.6)
            temp_chromosome = temp_chromosome_1;

            if(crossoverType==0) %K-point crossover
                kval=randi([1 noOfPointsInSolution*2-1],1);
                temp_chromosome_1(1,kval:noOfPointsInSolution*2)=temp_chromosome_2(1,kval:noOfPointsInSolution*2);
                temp_chromosome_2(1,kval:noOfPointsInSolution*2)=temp_chromosome(1,kval:noOfPointsInSolution*2);
            end
            

            if(crossoverType==1) %Uniform crossover
                    for i=1:size(temp_chromosome_1,2)
                        if rand()<0.5
                            temp = temp_chromosome_1(i);
                            temp_chromosome_1(i)=temp_chromosome_2(i);
                            temp_chromosome_2(i)=temp;
                        
                        end
                
                    end

            end
               


        end
        
        %% mutation operator
        if (rand < 0.3)
            
            

            if(mutationType==0)  %Adds on random amount at position k
                kval=randi([1 noOfPointsInSolution*2-1],1);
                x=randi([1 10],1);
                if(kval>18)
                    kval=kval-5;
                end 
                temp_chromosome_1(1,kval) = temp_chromosome_1(1,kval)+x;
               

            end

            if(mutationType==1) %Swap two values near start and end, swap mutation
                  x=randi([1 noOfPointsInSolution-1],1); %for npoints=10 this would be [1 9]
                   temp=temp_chromosome_1(1,x);
                   temp_chromosome_1(1,x)=temp_chromosome_1(1,noOfPointsInSolution*2-x);
                   temp_chromosome_1(1,noOfPointsInSolution*2-x)=temp;

            end
         

        end
        if (rand < 0.3)
            
            if(mutationType==0) % Adds on random amount at k
                 kval=randi([1 noOfPointsInSolution*2-1],1);
                 x=randi([1 10],1);
                 if(kval>18)
                    kval=kval-5;
                 end
                 temp_chromosome_2(1,kval) = temp_chromosome_2(1,kval)+x;
               
            end
          
            if(mutationType==1) % Swap two values near start and end
                    x=randi([1 noOfPointsInSolution-1],1); %for npoints=10, is [1 9]
                    temp=temp_chromosome_2(1,x);
                    temp_chromosome_2(1,x)=temp_chromosome_2(1,noOfPointsInSolution*2-x);
                    temp_chromosome_2(1,noOfPointsInSolution*2-x)=temp;
            end
          

        end
        %% put in new population, add first new chromosome
        population_new_num = population_new_num + 1;
        population_new(population_new_num,:) = temp_chromosome_1;
        % add second chromosome
        if (population_new_num < population_size)
            population_new_num = population_new_num + 1;
            population_new(population_new_num,:) = temp_chromosome_2;
        end
    end
    %% replace, last column not updated yet
    population(:,1:noOfPointsInSolution*2) = population_new;

end

% at end: evaluate fitness scores and rank them
for i = 1:population_size
        %%fitness function: higher values, the smaller the distance
        tempX = population(i,1:2:noOfPointsInSolution*2); %extract X,Y values
        tempY = population(i,2:2:noOfPointsInSolution*2);
        temp = zeros(noOfPointsInSolution,2);
        temp(:,1)=tempX;temp(:,2)=tempY; %insert X,Y Values
    
        tempA=zeros(noOfPointsInSolution+1,2);tempB=tempA;
        
        tempA(2:noOfPointsInSolution+1,:)=temp;
        tempA(1,1)=1;tempA(1,2)=1;
        
        tempB(1:noOfPointsInSolution,:)=temp;
        tempB(noOfPointsInSolution+1,1)=500;tempB(noOfPointsInSolution+1,2)=500;
        
        EuclideanDistance =norm(tempA-tempB);
        penalty = calculatePenalty(population(i,1:noOfPointsInSolution*2),map); %checks if passed thru obstacle
        if(size(penalty,2)>1)
            penalty=penalty(1); % generate penalty
        end
        
        population(i,noOfPointsInSolution*2 +1)=EuclideanDistance+penalty; %adds on, if none passed thru then will be 0
        
end
population = sortrows(population,noOfPointsInSolution*2+1);
toc %display time taken for algorithm
%end result..
start=[1 1];
finish= [500 500];
parta = population(1,1:2:noOfPointsInSolution*2)/size(map,1);
partb = population(1,2:2:noOfPointsInSolution*2)/size(map,2);
solution(1:2:noOfPointsInSolution*2) = parta;
solution(2:2:noOfPointsInSolution*2)= partb;

path=[start;[solution(1:2:end)'*size(map,1) solution(2:2:end)'*size(map,2)];finish ];
figure;
clf;
imshow(map)

rectangle('position',[1 1 size(map)-1],'edgecolor','k');
line(path(:,2),path(:,1));





disp 'Euclidean Distance of shortest path'  
population(1,noOfPointsInSolution*2+1)


function choice = rankSelection(population)
    popsize=size(population,1);
  
    ranks=zeros(popsize,1); % Like roulette wheel selection but ranks all values at end from 0.01 to top being highest
    count=1;
    for i=popsize:-1:1
        if(i==popsize)
            ranks(i)=count/popsize;
        else
            ranks(i)=ranks(i+1)+count/popsize;
        end
        count=count+1;
    end
    % Accumulate all values so likely hood of best values being picked is
    % higher
    p=randi(floor(ranks(1)),1); %Generate a probability of choosing a point
    chosen_index = -1;
    for index = length(ranks):-1:1
        if (ranks(index) >= p)
          chosen_index = index;
          break;
        end
    end
    choice = chosen_index;
      

    

end

function choice = RouletteWheelSelection(weights)
  accumulation = cumsum(weights); %Accumulate values then generate probability of picking a point
  p = rand();
  chosen_index = -1;
  for index = 1 : length(accumulation)
    if (accumulation(index) > p)
      chosen_index = index;
      break;
    end
  end
  choice = chosen_index;

end

function choice = tournamentSelection(population,n)
    % n - amount of random indices picked
    % population - my population

    tourIndices = randi(size(population,1),[n 1]);
    twoChromosomes = population(tourIndices,size(population,2));
    if(twoChromosomes(1)<twoChromosomes(2))
        choice=tourIndices(1);
    else
        choice=tourIndices(2);
    end
    

end

function penalty = calculatePenalty(points,map)
    % Have to take a heuristic approach, cannot get best path everytime
    % since many paths available, will instead take an estimate approach
    points = [1 1 points 500 500];
    penalty=0;
    size(points,2);
    for i=1:2:size(points,2)-2
        
        %Create 'box' around two points in a line
        penalty=penalty+calculateBetweenTwoPoints(points(i),points(i+1),points(i+2),points(i+3),map);
       
        % now add on a box which is half of its size inside it
        height=points(i+2)-points(i);
        width=points(i+3)-points(i+1);
         
        y1=round(points(i)+(height/4));
        x1=round(points(i+1)+(width/4));
        y2=round(points(i+2)-(height/4));
        x2=round(points(i+3)-(width/4));
        if(y1<500 && x1<500 )

            penalty=penalty+round(calculateBetweenTwoPoints(y1,x1,y2,x2,map)/2);
        end
        
    end

    function penalty = calculateBetweenTwoPoints(y1,x1,y2,x2,map)
         % Treats it like a box, go horizontally and check all black values
         % and then downwards from that end point, repeat for other side
         % and then sum all values and divide by 2 to get an estimate
        penalty=0;

        if(x1==x2) % X values the same
            getMap = map(y1:y2,x1);
            getSum = sum(getMap==0);
        
            penalty = penalty + getSum;
        
        elseif(y1==y2) %Y values the same
            getMap = map(y1,x1:x2);
            getSum = sum(getMap==0);
            penalty = penalty + getSum;

        else
       
            ay1=y1;
            ax1=x1;
            ay2=y2;
            ax2=x2;

            mapPoints =map(y1:y2,x1:x2);
            
            if(y2>y1 && x2>x1)
                rightSide = map(y1,x1:x2);
                getSum = sum(rightSide==0);
                rightDown = map(y1:y2,x2);
                getSum = getSum + sum(rightDown==0);
                
                %row,column = y,x
                leftDown = map(y1:y2,x1);
                getSum = getSum + sum(leftDown==0);
                leftRight = map(y2,x1:x2);
                getSum = getSum + sum(leftRight==0);
                penalty=penalty+getSum/4;
            end
           
            if(y2<y1 && x1<x2)
                rightBottom = map(y1,x1:x2);
                getSum= sum(rightBottom==0);
                rightUp=map(y1:y2,x2);
                getSum=sum(rightUp==0)+getSum;

                leftUp=map(y1:y2,x1);
                getSum=sum(leftUp==0)+getSum;
                leftTop=map(y2,x1:x2);
                getSum=sum(leftTop==0)+getSum;

                penalty=penalty+getSum/4;
            end

            if(y2>y1 && x2<x1)
                leftDown=map(y1:y2,x1);
                getSum = sum(leftDown==0);
                leftBottom=map(x2,y2:y1);
                getSum=sum(leftBottom==0) + getSum;

                TopLeft=map(x2,y1:y2);
                getSum= getSum + sum(TopLeft==0);
                Top=map(y1,x2:x1);
                getSum=getSum + sum(Top==0);
                penalty=penalty+getSum/4;

            end
         
        end
    end
        
end 


