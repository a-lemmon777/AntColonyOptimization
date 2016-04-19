# AntColonyOptimization

An implementation of the Ant Colony Optimization. There is an ant hill and various food sources outside of the ant hill. The goal for the ants is to find the sources of food and deplete the sources. Ants leave pheromones wherever they go, so other the ants can follow each other.

An ant: an object with...
* a location: (x, y) coordinate
* a state: going to food or going back to ant hill (probably an integer)

The world: a nested array to make a grid

Each element in the world: a location object with...
* findFood pheremone amount: integer that counts pheromones that would lead to food if followed (left when an ant is going back to ant hill)
* findHill pheremone amount: integer that counts pheremones that would lead to ant hill if followed (left when an ant is going to find food)
* foodCount: integer that counts if there is any food source on that spot
* antHill: boolean that determines whether that location is an ant hill entrance/exit

Other:
* an ant, when going to find food, will follow findFood pheremones and leave a set number of findHill pheromones
* an ant, when going to find an ant hill, will follow findHill pheromones and leave a set number of findFood pheromones
  * this could possibly prevent ants from following their own pheromones and getting stuck in circles
* after every move, each location object will have its pheromones deplete by one for each type of pheromone; this ensures that pheromones get lost after a while
* to determine each move, an ant will look around at all neighboring spaces and see what the pheromone counts (for what their following) is on each spot; it will then go to the spot that has the highest pheromone count; this ensures that paths that are often followed are continually followed again
* two loops should be used to do a move:
  * one where each ant's location's pheromones are updated
  * one where each ant looks to and decides where to move; then moves
* when an ant gets to a food source, then its state switches, its pheromones switch, and it attempts to go back to the ant hill
