using Distributions
using CSV
using DataFrames
using Plots
using DataStructures
locs= CSV.read("location.csv", DataFrame)
pop= CSV.read("pop.csv", DataFrame,header=false)

#visualisation of case numbers
heatmap(Array(pop),xlabel="",ylabel="",title="Heatmap illustrating case  numbers")        

#define our map
grp=Array(pop)


#This function generates the neighborhood over which we average
function genNegs(n)
#special case to consider only trivial neighborhood
if(n==0)
return (0,0)
end
##otherwise return all of them
collect(Iterators.product(-n:n,-n:n))
end
genNegs(4)


##compute avg number of cases in an area of size centred on centr
function compAvgCase(grp,centr,sze)
sx,sy=size(grp)
gh=genNegs(sze)
#generate all neigbors: call it area
area=[centr .+ nn for nn in gh ]
area=filter(x->( (minimum(x)>0) & (x[1]<=sx) & (x[2]<=sy)),area )
#finally compute average number of cases
avgNum=sum([grp[pt...] for pt in area])/length(area)
end


#define a start for our search
start=(60,60)



##This is the actual search algorithm
function searchOpt(start,sze,grp)
if(sze==0) 
return start
end
#compute average of cases
#compute neighbors
#
negCases=PriorityQueue(Base.Order.Reverse)
#compute true neighbors
negs=[start .+ nn for nn in genNegs(1) ]
negs=filter(x->( (minimum(x)>0) & (x[1]<=sx) & (x[2]<=sy)),negs )
#
#
#
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



#serch the origin of the outbreak
searchOpt(start,sze,grp)


