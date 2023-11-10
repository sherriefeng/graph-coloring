import networkx as nx
import random
import numpy as np
import csv
import matplotlib.pyplot as plt

import numOfSolutionsDepthC
import divisionGame

p = 0.0 # rewiring probability
th = 0 # 100000 # threshohold that represents storage capacity
num_trials = 20
max_steps = 5000

def run_simulations_hom(G, n, num_trials):
    Rate = []
    steps = []

    D = {}
    for gn in list(G.nodes()):
        D[gn] = 0

    # Initialize node color for 3 items
    cycls_3 = [c for c in nx.cycle_basis(G) if len(c)==3]

    for _ in range(num_trials):
        if not cycls_3:
            print("N:", n, ", couldn't find a cycle")
            nodes = list(G.nodes())
            random_nodes = np.random.choice(nodes, size=3, replace=False)
            D[random_nodes[0]] = 1
            D[random_nodes[1]] = 2
            D[random_nodes[2]] = 3
        else:
            e = random.choice(cycls_3)
            D[e[0]] = 1
            D[e[1]] = 2
            D[e[2]] = 3
        
        th = 15
        incomp_nodes = divisionGame.runWithDL3(G, D, th)
        Rate.append(1.0 * incomp_nodes[-1] / n) # DoL function returns array w/ # of incomplete nodes

        # Check if there are any non-empty (non-zero) elements in the array
        if np.any(incomp_nodes != 0):
            # Find the last non-empty index (index of the last non-zero value)
            steps.append(np.max(np.nonzero(incomp_nodes)[0]) + 1)
        else:
            steps.append(max_steps)
    
    return Rate, steps

def run_simulations_het(G, n, num_trials):
    Rate = []
    steps = []
    n_completeness = []

    D = {}
    for gn in list(G.nodes()):
        D[gn] = 0

    # Initialize node color for 3 items
    cycls_3 = [c for c in nx.cycle_basis(G) if len(c)==3]
    
    th = nx.eigenvector_centrality(G, weight='weight')

    for _ in range(num_trials):
        if not cycls_3:
            # print("N:", n, ", couldn't find a cycle")
            nodes = list(G.nodes())
            random_nodes = np.random.choice(nodes, size=3, replace=False)
            D[random_nodes[0]] = 1
            D[random_nodes[1]] = 2
            D[random_nodes[2]] = 3
        else:
            e = random.choice(cycls_3)
            D[e[0]] = 1
            D[e[1]] = 2
            D[e[2]] = 3

        incomp_nodes, neighborhood_missing_colors = divisionGame.runWithDL3_het(G, D, th)

        Rate.append(1.0 * incomp_nodes[-1] / n) # DoL function returns array w/ # of incomplete nodes
        neighborhood_metrics = neighborhood_missing_colors / 3.0
        # print(neighborhood_metrics)

        n_completeness.append(np.sum(neighborhood_metrics)) # *** weighted sum?

        # Check if there are any non-empty (non-zero) elements in the array
        if np.any(incomp_nodes != 0):
            # Find the last non-empty index (index of the last non-zero value)
            steps.append(np.max(np.nonzero(incomp_nodes)[0]) + 1)
        else:
            steps.append(max_steps)
    
    return Rate, steps, n_completeness

def main():
    # k_file = csv.writer(open("../../data/data_all_pref_attach_het.csv", "w"))
    k_file = csv.writer(open("../../data/data_all_pref_attach_random.csv", "w"))
    k_file.writerows([["size", "k", "avg_rate", "avg_density", "avg_clustering", "avg_shortest_path", "avg_std_rate", "avg_median_rate", "avg_incomp_nodes", "avg_n_comp_nodes", "avg_steps"]])
    # n = 20

    for i in range(5, 21):
        for k in range(15):
            summary_rates = []
            summary_density = []
            summary_cluster = []
            summary_path = []
            summary_incomp = []
            summary_steps = []
            summary_n_comp = []

            filename = '../../data/networks/random_' + str(i) + '/random_' + str(i) + '_' + str(k) + '.edgelist'
            dataFile = csv.reader(open(filename, 'r'))

            G = nx.Graph()
            for data in dataFile:
                data = list(map(lambda x:x.strip(), data))
                data2 = data[0].split(" ")
                u1 = int(data2[0])
                u2 = int(data2[1])
                G.add_edge(u1, u2)

            density = nx.density(G)
            cluster = nx.average_clustering(G) # calculate clustering coeff
            path = nx.average_shortest_path_length(G) # calculate average shortest path length

            # trial_rates, steps = run_simulations(G, n, num_trials) # Returns all trial incompletion rates, # steps
            try:
                trial_rates, steps, n_comp = run_simulations_het(G, i, num_trials)
            except:
                trial_rates, steps, n_comp = 0, 0, 0
                print("Sim failed")
            
            avg_incomp_rate = np.mean(trial_rates)
            avg_comp_rate = 1 - avg_incomp_rate
            avg_incomp_nodes = i * avg_incomp_rate
            avg_steps = np.mean(steps)
            avg_n_comp = np.mean(n_comp)

            summary_rates.append(avg_comp_rate)
            summary_density.append(density)
            summary_cluster.append(cluster)
            summary_path.append(path)
            summary_incomp.append(avg_incomp_nodes)
            summary_steps.append(avg_steps)
            summary_n_comp.append(avg_n_comp)
            
            avg_summary_rate = np.mean(summary_rates)
            print("N:", i, "\tRate:%.3f " % avg_summary_rate, "\tN_Comp:%.3f " % avg_n_comp, "\tSteps:", avg_steps)
            k_file.writerows([[i, k, avg_summary_rate, np.mean(summary_density), np.mean(summary_cluster), np.mean(summary_path), np.std(summary_rates), np.median(trial_rates), np.mean(summary_incomp), np.mean(summary_n_comp), np.mean(summary_steps)]])

if __name__ == "__main__":
    main()