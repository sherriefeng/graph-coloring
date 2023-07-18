import numpy as np
cimport numpy as np

DTYPE = np.int64
ctypedef np.int64_t DTYPE_t

# agents (or nodes) need to choose a role (color), and they are encouraged not to choose 
# the same role as their neighbors. 

#########
# Division of labor game with 3 items
#########

# C is an array representing the current role of each agent
# A is an array representing the number of attempts each agent has made to find a role.
# In each iteration, a random agent (learner) is chosen.
# The learner checks the roles of its neighbors and tries to choose a role that none of its 
# neighbors have (if possible).

# If all roles are occupied by neighbors, the learner will randomly choose a role if it hasn't 
# exceeded the maximum allowed attempts (h), or it will give up and choose role 0 (generalist) otherwise.

# The number of agents that have neighbors with all roles is recorded in each iteration.
# The simulation stops if there are no such agents, or it continues for a fixed number of iterations (numSim) 

cdef np.ndarray[DTYPE_t, ndim=1] _runWithDL3(list Nodes, dict Neighbors, np.ndarray[DTYPE_t, ndim=1] C, np.ndarray[DTYPE_t, ndim=1] A, int h):

    cdef int nsize = len(Nodes)
    cdef int n, neighbor, learner, k, nei
    cdef int is1, is2, is3
    cdef int numD = 0
    cdef int isDef = 1
    cdef int numSim = 5000
    cdef np.ndarray[DTYPE_t, ndim=1] R = np.zeros(numSim, dtype=DTYPE)

    for i in range(numSim):

        learner = np.random.choice(Nodes)

        is1 = 0
        is2 = 0
        is3 = 0
        for neighbor in Neighbors[learner]:
            if C[neighbor] == 1:
                is1 = 1
            elif C[neighbor] == 2:
                is2 = 1
            elif C[neighbor] == 3:
                is3 = 1

        if is1 == 1 and is2 == 1 and is3 == 1:
            if A[learner] < h:
                #if C[learner] == 0:
                C[learner] = np.random.choice([1, 2, 3])
                A[learner] += 1
            else:
                C[learner] = 0
                A[learner] = 0

        elif is1 == 1 and is2 == 1 and is3 == 0:
            C[learner] = 3
            A[learner] = 0

        elif is1 == 0 and is2 == 1 and is3 == 1:
            C[learner] = 1
            A[learner] = 0

        elif is1 == 1 and is2 == 0 and is3 == 1:
            C[learner] = 2
            A[learner] = 0

        else:
            if A[learner] < h:
                if is1 == 1:
                    C[learner] = np.random.choice([2, 3])
                elif is2 == 1:
                    C[learner] = np.random.choice([1, 3])
                elif is3 == 1:
                    C[learner] = np.random.choice([1, 2])
                else:
                    if C[learner] == 0:
                        C[learner] = np.random.choice([1, 2, 3])
                A[learner] += 1
            else:
                C[learner] = 0
                A[learner] = 0

        numD = 0

        for k in range(nsize):
            is1 = 0
            is2 = 0
            is3 = 0
            if C[k] == 1:
                is1 = 1
            elif C[k] == 2:
                is2 = 1
            elif C[k] == 3:
                is3 = 1
            for neighbor in Neighbors[k]:
                if C[neighbor] == 1:
                    is1 = 1
                elif C[neighbor] == 2:
                    is2 = 1
                elif C[neighbor] == 3:
                    is3 = 1
            if is1 == 0 or is2 == 0 or is3 == 0:
                numD += 1

        R[i] = numD # R stores the number of nodes in the network that are not achieving a complete division of labor at each iteration of the simulation
        # numD is the number of nodes that lack one or more "colors" or roles in their neighborhood (i.e., among their neighbors and themselves).
        if numD == 0:
            break;

    return R


def runWithDL3(G, CD, h):
    cdef np.ndarray[DTYPE_t, ndim=1] C = np.zeros(len(G.nodes()), dtype=DTYPE)
    cdef np.ndarray[DTYPE_t, ndim=1] A = np.zeros(len(G.nodes()), dtype=DTYPE)
    cdef dict Neighbors = {}
    cdef int h2 = h
    for n in G.nodes():
        C[n] = CD[n]
        Neighbors[n] = list(G.neighbors(n))

    cdef list Nodes = list(G.nodes())

    return _runWithDL3(Nodes, Neighbors, C, A, h2)



# solution numbers of division of labour game
#def count_solutions(num_trials):
    #solution_counts = {}

    #for _ in range(num_trials):
        #result = _runWithDL3(Nodes, Neighbors, C, A, h)

        # Check if division of labor was achieved
        #if result[-1] == 0:  # Division of labor was achieved
            #solution = tuple(C)  # Snapshot of the current solution

            #if solution in solution_counts:
                #solution_counts[solution] += 1
            #else:
                #solution_counts[solution] = 1

    #return solution_counts

#print(count_solutions(10))

#########
# Division of labor game with 2 items
#########

cdef np.ndarray[DTYPE_t, ndim=1] _runWithDL2(list Nodes, dict Neighbors, np.ndarray[DTYPE_t, ndim=1] C, np.ndarray[DTYPE_t, ndim=1] A, int h):

    cdef int nsize = len(Nodes)
    cdef int n, neighbor, learner
    cdef int is1, is2
    cdef int numD = 0
    cdef int isDef = 1
    cdef int numSim = 5000
    cdef np.ndarray[DTYPE_t, ndim=1] R = np.zeros(numSim, dtype=DTYPE)
    cdef int dummy = -1

    for i in range(numSim):
        learner = np.random.choice(Nodes)

        is1 = 0
        is2 = 0
        for neighbor in Neighbors[learner]:
            if C[neighbor] == 1:
                is1 = 1
            elif C[neighbor] == 2:
                is2 = 1

        if is1 == 1 and is2 == 1:
            if A[learner] < h:
                C[learner] = np.random.choice([1, 2])
                A[learner] += 1
            else:
                C[learner] = 0
                A[learner] = 0

        elif is1 == 0 and is2 == 1:
            C[learner] = 1
            A[learner] = 0

        elif is1 == 1 and is2 == 0:
            C[learner] = 2
            A[learner] = 0

        else:
            if A[learner] < h:
                if C[learner] == 0:
                    C[learner] = np.random.choice([1, 2])
            else:
                C[learner] = 0
                A[learner] = 0

        numD = 0
        for k in range(nsize):
            is1 = 0
            is2 = 0
            if C[k] == 1:
                is1 = 1
            elif C[k] == 2:
                is2 = 1
            for neighbor in Neighbors[k]:
                if C[neighbor] == 1:
                    is1 = 1
                elif C[neighbor] == 2:
                    is2 = 1
            if is1 == 0 or is2 == 0:
                numD += 1

        R[i] = numD
        if numD == 0:
            break;

    return R

def runWithDL2(G, CD, h):
    cdef np.ndarray[DTYPE_t, ndim=1] C = np.zeros(len(G.nodes()), dtype=DTYPE)
    cdef np.ndarray[DTYPE_t, ndim=1] A = np.zeros(len(G.nodes()), dtype=DTYPE)
    cdef dict Neighbors = {}
    cdef int h2 = h
    for n in G.nodes():
        C[n] = CD[n]
        Neighbors[n] = list(G.neighbors(n))

    cdef list Nodes = list(G.nodes())

    return _runWithDL2(Nodes, Neighbors, C, A, h2)



#########
# Division of labor game with 4 items
#########

cdef np.ndarray[DTYPE_t, ndim=1] _runWithDL4(list Nodes, dict Neighbors, np.ndarray[DTYPE_t, ndim=1] C, np.ndarray[DTYPE_t, ndim=1] A, int h): #with latency

    cdef int nsize = len(Nodes)
    cdef int n, neighbor, learner, k, nei
    cdef int is1, is2, is3, is4
    cdef int numD = 0
    cdef int isDef = 1
    cdef int numSim = 5000
    cdef np.ndarray[DTYPE_t, ndim=1] R = np.zeros(numSim, dtype=DTYPE)

    for i in range(numSim):

        learner = np.random.choice(Nodes)

        is1 = 0
        is2 = 0
        is3 = 0
        is4 = 0
        for neighbor in Neighbors[learner]:
            if C[neighbor] == 1:
                is1 = 1
            elif C[neighbor] == 2:
                is2 = 1
            elif C[neighbor] == 3:
                is3 = 1
            elif C[neighbor] == 4:
                is4 = 1

        if is1 == 1 and is2 == 1 and is3 == 1 and is4 == 1:
            if A[learner] < h:
                if C[learner] == 0:
                    C[learner] = np.random.choice([1, 2, 3, 4])
                A[learner] += 1
            else:
                C[learner] = 0
                A[learner] = 0

        elif is1 == 1 and is2 == 1 and is3 == 0 and is4 == 1:
            C[learner] = 3
            A[learner] = 0

        elif is1 == 0 and is2 == 1 and is3 == 1 and is4 == 1:
            C[learner] = 1
            A[learner] = 0

        elif is1 == 1 and is2 == 0 and is3 == 1 and is4 == 1:
            C[learner] = 2
            A[learner] = 0

        elif is1 == 1 and is2 == 1 and is3 == 1 and is4 == 0:
            C[learner] = 4
            A[learner] = 0


        else:
            if A[learner] < h:
                if is1 == 1 and is2 == 1:
                    C[learner] = np.random.choice([3, 4])
                elif is1 == 1 and is3 == 1:
                    C[learner] = np.random.choice([2, 4])
                elif is1 == 1 and is4 == 1:
                    C[learner] = np.random.choice([2, 3])
                elif is2 == 1 and is3 == 1:
                    C[learner] = np.random.choice([1, 4])
                elif is2 == 1 and is4 == 1:
                    C[learner] = np.random.choice([1, 3])
                elif is3 == 1 and is4 == 1:
                    C[learner] = np.random.choice([1, 2])
                elif is1 == 1:
                    C[learner] = np.random.choice([2, 3, 4])
                elif is2 == 1:
                    C[learner] = np.random.choice([1, 3, 4])
                elif is3 == 1:
                    C[learner] = np.random.choice([1, 2, 4])
                elif is4 == 1:
                    C[learner] = np.random.choice([1, 2, 3])
                else:
                    if C[learner] == 0:
                        C[learner] = np.random.choice([1, 2, 3, 4])
                A[learner] += 1
            else:
                C[learner] = 0
                A[learner] = 0

        numD = 0

        for k in range(nsize):
            is1 = 0
            is2 = 0
            is3 = 0
            is4 = 0
            if C[k] == 1:
                is1 = 1
            elif C[k] == 2:
                is2 = 1
            elif C[k] == 3:
                is3 = 1
            elif C[k] == 4:
                is4 = 1
            for neighbor in Neighbors[k]:
                if C[neighbor] == 1:
                    is1 = 1
                elif C[neighbor] == 2:
                    is2 = 1
                elif C[neighbor] == 3:
                    is3 = 1
                elif C[neighbor] == 4:
                    is4 = 1
            if is1 == 0 or is2 == 0 or is3 == 0 or is4 == 0:
                numD += 1


        R[i] = numD
        if numD == 0:
            break;

    return R

def runWithDL4(G, CD, h):
    cdef np.ndarray[DTYPE_t, ndim=1] C = np.zeros(len(G.nodes()), dtype=DTYPE)
    cdef np.ndarray[DTYPE_t, ndim=1] A = np.zeros(len(G.nodes()), dtype=DTYPE)
    cdef dict Neighbors = {}
    cdef int h2 = h
    for n in G.nodes():
        C[n] = CD[n]
        Neighbors[n] = list(G.neighbors(n))

    cdef list Nodes = list(G.nodes())

    return _runWithDL4(Nodes, Neighbors, C, A, h2)


#########
# Division of labor game with 5 items (only without storage)
#########

cdef np.ndarray[DTYPE_t, ndim=1] _runWithDL5(list Nodes, dict Neighbors, np.ndarray[DTYPE_t, ndim=1] C): #without latency

    cdef int nsize = len(Nodes)
    cdef int n, neighbor, learner, k, nei
    cdef int is1, is2, is3, is4, is5
    cdef int numD = 0
    cdef int isDef = 1
    cdef int numSim = 5000
    cdef np.ndarray[DTYPE_t, ndim=1] R = np.zeros(numSim, dtype=DTYPE)

    for i in range(numSim):

        learner = np.random.choice(Nodes)

        is1 = 0
        is2 = 0
        is3 = 0
        is4 = 0
        is5 = 0
        for neighbor in Neighbors[learner]:
            if C[neighbor] == 1:
                is1 = 1
            elif C[neighbor] == 2:
                is2 = 1
            elif C[neighbor] == 3:
                is3 = 1
            elif C[neighbor] == 4:
                is4 = 1
            elif C[neighbor] == 5:
                is4 = 1

        if is1 == 1 and is2 == 1 and is3 == 1 and is4 == 1 and is5 == 1:
            C[learner] = 0

        elif is1 == 1 and is2 == 1 and is3 == 0 and is4 == 1 and is5 == 1:
            C[learner] = 3

        elif is1 == 0 and is2 == 1 and is3 == 1 and is4 == 1 and is5 == 1:
            C[learner] = 1

        elif is1 == 1 and is2 == 0 and is3 == 1 and is4 == 1 and is5 == 1:
            C[learner] = 2

        elif is1 == 1 and is2 == 1 and is3 == 1 and is4 == 0 and is5 == 1:
            C[learner] = 4

        elif is1 == 1 and is2 == 1 and is3 == 1 and is4 == 1 and is5 == 0:
            C[learner] = 5

        else:
            C[learner] = 0

        numD = 0

        for k in range(nsize):
            is1 = 0
            is2 = 0
            is3 = 0
            is4 = 0
            is5 = 0
            if C[k] == 1:
                is1 = 1
            elif C[k] == 2:
                is2 = 1
            elif C[k] == 3:
                is3 = 1
            elif C[k] == 4:
                is4 = 1
            elif C[k] == 5:
                is5 = 1
            for neighbor in Neighbors[k]:
                if C[neighbor] == 1:
                    is1 = 1
                elif C[neighbor] == 2:
                    is2 = 1
                elif C[neighbor] == 3:
                    is3 = 1
                elif C[neighbor] == 4:
                    is4 = 1
                elif C[neighbor] == 5:
                    is5 = 1
            if is1 == 0 or is2 == 0 or is3 == 0 or is4 == 0 or is5 == 0:
                numD += 1


        R[i] = numD
        if numD == 0:
            break;

    return R

def runWithDL5(G, CD):
    cdef np.ndarray[DTYPE_t, ndim=1] C = np.zeros(len(G.nodes()), dtype=DTYPE)
    cdef dict Neighbors = {}
    for n in G.nodes():
        C[n] = CD[n]
        Neighbors[n] = list(G.neighbors(n))

    cdef list Nodes = list(G.nodes())

    return _runWithDL5(Nodes, Neighbors, C)