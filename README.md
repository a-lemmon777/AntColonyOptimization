# AntColonyOptimization

An implementation of the Ant Colony Optimization. There is an ant hill and various food sources outside of the ant hill. The goal for the ants is to find the sources of food and deplete the sources. Ants leave pheromones wherever they go, so other the ants can follow each other. The run is considered successful if all of the food is eventually eaten.

## Running Our Code

Go to [this website](https://ccl.northwestern.edu/netlogo/5.3.1/) to download NetLogo for your computer. Then, after you install everything, go to File -> Open -> `AntColonyOptimization.nlogo` to open our model.

Or... you can run the `ant_colony_optimization.py` (although it isn't a Python file) through [this website](http://www.netlogoweb.org/launch#http://www.netlogoweb.org/assets/modelslib/Sample%20Models/Biology/Ants.nlogo) by copy-pasting the file into where this link says NetLogo Code, and then recompiling.

## Our Implementation of Ant Colony Optimization

An ant: an object with...
* a location: (x, y) coordinate
* a state: going to food or going back to ant hill (boolean)

The world: a 2D array to make a grid

Each element in the world: a location object with...
* findFood pheremone amount: double that counts pheromones that would lead to food if followed (left when an ant is going back to ant hill)
* findHill pheremone amount: double that counts pheremones that would lead to ant hill if followed (left when an ant is going to find food)
* foodCount: integer that counts if there is any food source on that spot
* antHill: boolean that determines whether that location is an ant hill

Other:
* global variable for total amount of food source
* an ant, when going to find food, will follow findFood pheremones and leave a set number of findHill pheromones
* an ant, when going to find an ant hill, will follow findHill pheromones and leave a set number of findFood pheromones
  * this could possibly prevent ants from following their own pheromones and getting stuck in circles
* after every move, each location object will have its pheromones deplete (either by one or by a half-life formula) for each type of pheromone; this ensures that pheromones get lost after a while
* to determine each move, an ant will look around at all neighboring spaces and see what the pheromone counts (for what their following) is on each spot; an ant is more likely to go to a spot with higher pheromone levels
* two loops should be used to do a move:
  * one where each ant's location's pheromones are updated
  * one where each ant looks to and decides where to move; then moves
* when an ant gets to a food source, then its state switches, its pheromones switch, the food source at that location and global variable is decremented, and the ant attempts to go back to the ant hill

Different parameters that might affect performance:
* number of ants in a run
* how many maximum steps the ants have to try to get all of the food (process will stop if all food gets eaten before max steps is reached)
* the number of food sources and ant hills
* the amount that the pheromones are depleted by each step
* the size of the world in a x's and y's (width and height of the world)
* maybe if barriers are put into the world
