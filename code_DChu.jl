using Distributions
using CSV
using DataFrames
using Plots
using DataStructures
#read the data 
locs= CSV.read("location.csv", DataFrame)
pop= CSV.read("pop.csv", DataFrame,header=false)


#Use a  heatmap to visualise the case numbers
#visualisation of case numbers
heatmap(Array(pop),xlabel="",ylabel="",title="Heatmap illustrating case  numbers")        
savefig("visualisation.pdf")


#convert the DataFrame back to array to work with it
#define our map
grp=Array(pop)


##Define helper functions


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#This function generates the neighborhood over which we average
function genNegs(n)
    #special case to consider only trivial neighborhood (unnecessary)
    if(n==0)
    return (0,0)
    end
##otherwise return all of them
collect(Iterators.product(-n:n,-n:n))
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##This function takes a grid (grp), and computes the avg cases in
#the rectangle of size sze centred around centr
function compAvgCase(grp,centr,sze)
sx,sy=size(grp)
gh=genNegs(sze)
#generate all neigbors: call it area
area=[centr .+ nn for nn in gh ]
area=filter(x->( (minimum(x)>0) & (x[1]<=sx) & (x[2]<=sy)),area )
#finally compute average number of cases
avgNum=sum([grp[pt...] for pt in area])/length(area)
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~





#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
##This is the algorithm that searches the grid
#Starting from size sze it looks for a local optimum
#once found, it reduces the search box, untill the square is of 
#size 0.
#At this point, we hope to have found the optimum
#It relies on a reasonable starting point
#
function searchOpt(start,sze,grp)
#stop when search radius is 0
    if(sze==0) 
    return start
    end
#generate a priority queue for convenience (slight overkill)
negCases=PriorityQueue(Base.Order.Reverse)
#compute neighbors (code replication from above); should be in a function
negs=[start .+ nn for nn in genNegs(1) ]
negs=filter(x->( (minimum(x)>0) & (x[1]<=sx) & (x[2]<=sy)),negs )
#
#
#populate the priority queue
    for nn in negs
    cases=compAvgCase(grp,nn,sze)
    negCases[nn]=cases
    end
#
##
#negCases now contains the number of cases in neighborhood.
#now search the neigbhborhood
maxLoc=first(negCases)[1]
    if(maxLoc != start)
    searchOpt(maxLoc,sze,grp)
    else
    searchOpt(maxLoc,sze-1,grp)
    end#if
end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



#define a start for our search
start=(60,60)
#serch the origin of the outbreak
searchOpt(start,sze,grp)


