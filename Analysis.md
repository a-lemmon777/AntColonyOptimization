# Analysis of our Ant Colony Optimization Problem

Note: For this analysis, we will count time in ticks until all food has been collected and returned to an ant hill. Also, the population count of the ants was kept the same throughout the entire testing process at 125.

More details about out test runs can be seen on this [Google Spreadsheet](https://docs.google.com/spreadsheets/d/1rTsikyOYHbQl1uOJhZzLAHbG8j_v6kVKUMnNYH3bgdc/edit?usp=sharing).

## Our Initial Runs

The first thing we ran had no pheromones. All of the ants wandered randomly until all food was found and collected. Our average tick count was 5110. This is pretty slow.

<img src="https://github.com/lemmo031/AntColonyOptimization/blob/master/ants_no_pheromones.png" width="500">

Using pheromones brings a lot of parameters with it. Therefore, we selected a base configuration for all of the parameters that we thought would give us promising results:

```
find-food-diffusion:        20
find-hill-diffusion:        20
find-food-evaporation:      7
find-hill-evaporation:      7
food-pheromone-falloff:     3
hill-pheromone-falloff:     3
default-pheromone-strength: 60
average tick count:         1546
```

<img src="https://github.com/lemmo031/AntColonyOptimization/blob/master/ants_base_config.png" width="500">

This is improved from when there were no pheromones at all because now all of the ants have paths to follow that will guide them to the food sources and back to the ant hills.

From this, we ran a set of trials with each value above lowered and raised from the base configuration amount. The settings that caused "cloud-like" structures of pheromones around ant hills and food sources resulted in the best performance.

## What Worked and What Didn't

We found that generally, these clouds occur when there are high levels of diffusion on both pheromones, which allows the pheromones to spread out after they're released. When the diffusion levels are low, the paths become very narrow, which makes them more difficult to follow. However, when there are high levels of diffusion, it's important that we maintain falloff levels (will be explained below).

<img src="https://github.com/lemmo031/AntColonyOptimization/blob/master/ants_high_diffusion.png" width="500">

We also noticed that it is best when there is a moderate rate of evaporation. When the evaporation is too low, the average performance decreased because the pheromones didn't fade quickly enough, leading to the clouds being too big; the ants couldn't find the center of the clouds because they were so big. When the evaporation is too high, the pheromone clouds disappear too quickly; ants cannot sniff the trails quick enough to follow and reinforce.

As an ant moves away from an ant hill or food source, the amount of pheromones it puts down per tick decreases. This is referred to as _falloff_. A falloff of 0 means that the strength of pheromones an ant puts down never decreases. If the falloff is higher, say 5, then if an ant releases 10 pheromones last tick, it will put down 5 this tick. Next tick, it'll put down 0. For `food-pheromone-falloff`, we found that it's best when there is a high level of falloff. This means the pheromones will stay condensed around the food source; ants will know pretty much exactly where the food is. For `hill-pheromone-falloff`, we found that a moderate amount of falloff worked the best.

`default-pheromone-strength` refers to how many pheromones an ant leaves when it has _just_ been to an ant hill or food source. We found that the best value here was also somewhere in the middle. If the level is very low, the performance decreases because the clouds aren't big enough to follow. If the level is high, the performance also decreases because there are too many pheromones, and the clouds are too large.

## The Ultimate Best and Worst Configurations

Using all of this, the worst configuration we found was:

```
find-food-diffusion:        40
find-hill-diffusion:        40
find-food-evaporation:      16
find-hill-evaporation:      16
food-pheromone-falloff:     0
hill-pheromone-falloff:     0
default-pheromone-strength: 10
average tick count:         10142
```

<img src="https://github.com/lemmo031/AntColonyOptimization/blob/master/ants_worst_config.png" width="500">

There are several reasons why the above configuration was so poor. Firstly, there was no falloff. Ants will leave pheromone trails everywhere, regardless of how close or far they actually are from an ant hill or food source. Secondly, the diffusion levels were really high, allowing the pheromones to spread far. When the pheromones spread this far in these locations, they're quite misleading. Lastly, the evaporation was of medium level, allowing the ants to follow each other in unhelpful circles (what we've termed "partying"). In this case, parties are bad.

The best configuration we found was:

```
find-food-diffusion:        20
find-hill-diffusion:        40
find-food-evaporation:      4
find-hill-evaporation:      4
food-pheromone-falloff:     8
hill-pheromone-falloff:     4
default-pheromone-strength: 60
average tick count:         1486
```

<img src="https://github.com/lemmo031/AntColonyOptimization/blob/master/ants_best_config.png" width="500">

Here, we raised the diffusion level of the hill pheromone, making it easier for ants to find their way back to ant hills. We also lowered the hill falloff level, allowing larger clouds to gather near ant hills. We raised the food falloff level; this makes the clouds a little smaller, but there are so many food sources that the ants don't need the extra help finding food. Lastly, we lowered the evaporation rates so that the pheromones would stick around a little longer, allowing more ants to follow the trails.

## Conclusion

In general, we found that `find-hill-pheromone` is more critical than `find-food-pheromone`. If need be, ants can sort of stumble upon food sources randomly, but the ants really need `find-hill-pheromone` to bring the food back. This could be because we have five food sources, but only two ant hills.

Overall, using pheromones to guide ants improves performance over having no pheromones at all. However, proper pheromone configuration plays a large role in the performance improvements. Configured incorrectly, having pheromones can actually cause much worse performance than having no pheromones. Badly configured pheromones can cause the ants to blindly follow each other around rather than searching for food and bringing it back to the hill.


