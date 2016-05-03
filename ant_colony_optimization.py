;; Taken and modified from Uri Wilensky's 1997 Ant Colony Optimization NetLogo code.

globals [
  find-food-diffusion        ;; amount of diffusion for find-food-pheromone
  find-food-evaporation      ;; amount of evaporation for find-food-pheromone
  find-hill-diffusion        ;; amount of diffusion for find-hill-pheromone
  find-hill-evaporation      ;; amount of evaporation for find-hill-pheromone
  default-pheromone-strength ;; amount of default pheromone strength an ant will leave
]

patches-own [
  find-food-pheromone  ;; amount of find-food-pheromone on this patch
  find-hill-pheromone  ;; amount of find-hill-pheromone on this patch
  food                 ;; amount of food on this patch
  hill?                ;; true on hill patches, false elsewhere
  food-source-number   ;; number (1, 2, 3, or 4) to identify the food sources
]

turtles-own [
  pheromone-strength   ;; strength level of pheromones that an ant leaves at each spot, must be >= 0,
]                      ;; decreases as they spend more time away from food/hill

;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup procedures ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;;; setup
;;; Will be run when the "setup" button is pressed. It will clear the entire board and make all of the ants with
;;; size 2, color red (red means not carrying food, while brown means carrying food), and an initial pheromone-strength
;;; of 0. It will then set up all of the patches. Lastly it will set all of the global variables and reset all of the
;;; ticks.
to setup
  clear-all
  set-default-shape turtles "bug"
  create-turtles population
    [ set size 2
      set color red
      set pheromone-strength 0 ]
  setup-patches
  set find-food-diffusion 20
  set find-food-evaporation 8
  set find-hill-diffusion 10
  set find-hill-evaporation 2
  set default-pheromone-strength 100
  reset-ticks
end

;;; setup-patches
;;; For each patch on the board, it will set up the hills, setup the food, and color the patches appropriately.
to setup-patches
  ask patches
    [ setup-hill
      setup-food
      recolor-patch ]
end

;;; setup-hill
;;; It will set up two hills hard-coded at the upper right and lower left corners of the board. It will set
;;; the hill? boolean as true on those spots.
to setup-hill
  if (distancexy (-0.35 * max-pxcor) (0.2 * max-pycor)) < 3
    [ set hill? true ]

  if (distancexy (0.1 * max-pxcor) (-0.3 * max-pycor)) < 3
    [ set hill? true ]
end

;;; setup-food
;;; It will set up four food sources hard-coded throughout the board. It labels each food source with a number
;;; and gives certain amounts of food (1, 2, 3, 4, or 5) to each food source.
to setup-food ;; make 4 set food sources
  if (distancexy (0.6 * max-pxcor) (-0.1 * max-pycor)) < 3
    [ set food-source-number 1 ]

  if (distancexy (0.4 * max-pxcor) (-0.9 * max-pycor)) < 3
    [ set food-source-number 2 ]

  if (distancexy (0.8 * max-pxcor) (0.85 * max-pycor)) < 3
    [ set food-source-number 3 ]

  if (distancexy (-0.9 * max-pxcor) (0.7 * max-pycor)) < 3
    [ set food-source-number 4 ]

  if food-source-number > 0
    [ set food one-of [1 2 3 4 5] ]
end

;;; recolor-patch
;;; It will set all hill spots to be violet. Then it will set all food sources to be a different color based
;;; on which number food source it is. Then it will show pheromone colors for each type of pheromone (green
;;; for find-hill-pheromone, so leading to hills, and orange for find-food-pheromone, so leading to food sources)
;;; and the colors will scale to show the evaporation of the pheromones.
to recolor-patch
  ifelse hill?
    [ set pcolor violet ]
    [ ifelse food > 0
      [ if food-source-number = 1 [ set pcolor cyan ]
        if food-source-number = 2 [ set pcolor magenta ]
        if food-source-number = 3 [ set pcolor blue ]
        if food-source-number = 4 [ set pcolor yellow ] ]
      [ ifelse find-hill-pheromone > find-food-pheromone
        [ set pcolor scale-color green find-hill-pheromone 0.1 20 ]
        [ set pcolor scale-color orange find-food-pheromone 0.1 20 ] ] ]
end

;;;;;;;;;;;;;;;;;;;;;
;;; Go procedures ;;;
;;;;;;;;;;;;;;;;;;;;;

;;; go
;;; Will run when the "go" button is pressed, and will continue until the "go" button is pressed again.
;;; For each ant, it will first release each ant one-by-one. Then it will ask if the ant is on a hill or
;;; a food source. If this is the case, then it will replenish the pheromone-strength. Then, if the ant
;;; is red (looking for food), then will run the food-procedure. If the ant is brown (looking for hill),
;;; then run the hill-procedure. After this, it will "wiggle", and then move forward. After all ants
;;; complete this, it will diffuse both pheromones and evaporate a little bit of both pheromones on every
;;; patch and recolor all of the patches. Lastly, tick.
to go
  ask turtles
    [ if who >= ticks [ stop ]
      if hill? or (food > 0)
        [ set pheromone-strength default-pheromone-strength ]
      ifelse color = red
        [ food-procedure ]
        [ hill-procedure ]
      wiggle
      fd 1 ]
  diffuse find-food-pheromone (find-food-diffusion / 100)
  diffuse find-hill-pheromone (find-hill-diffusion / 100)
  ask patches
    [ set find-food-pheromone find-food-pheromone * (100 - find-food-evaporation) / 100
      set find-hill-pheromone find-hill-pheromone * (100 - find-hill-evaporation) / 100
      recolor-patch ]
  tick
end

;;; hill-procedure
;;; If the ant is on a hill, then drop off food and recolor ant to red and turn around. If the ant is not on a
;;; hill, then see if the ant randomly walked across a food source. If not, then drop some find-food-pheromone.
;;; Then decrement the ant's pheromone-strength if possible. Lastly, find a direction to move that is following
;;; the find-hill-pheromone and move.
to hill-procedure
  ifelse hill?
    [ set color red
      rt 180 ]
    [ if food <= 0
        [ set find-food-pheromone find-food-pheromone + pheromone-strength ]
      if pheromone-strength > 0
        [ set pheromone-strength pheromone-strength - 3 ]
      if (find-hill-pheromone >= 0.05) and (find-hill-pheromone < 2)
        [ follow-hill-pheromone ] ]
end

;;; food-procedure
;;; If the ant is on a food source, then pick up food, recolor ant to brown, ad turn around. If the ant is not on a
;;; food source, then see if the ant randomly walked across a hill. If not, then drop some find-hill-pheromone. Then
;;; decrement the ant's pheromone-strength if possible. Lastly, find a direction to move that is following the
;;; find-food-pheromone and move.
to food-procedure
  ifelse food > 0
    [ set color brown + 1
      set food food - 1
      rt 180
      stop ]
    [ if not hill?
        [ set find-hill-pheromone find-hill-pheromone + pheromone-strength ]
      if pheromone-strength > 0
        [ set pheromone-strength pheromone-strength - 3 ]
      if (find-food-pheromone >= 0.05) and (find-food-pheromone < 2)
        [ follow-food-pheromone ] ]
end

;;; follow-hill-pheromone
;;; Will see how much find-hill-pheromone is ahead, to the right, and to the left of the ant. Then will determine which
;;; direction to turn by seeing which of the three directions has the most pheromones.
to follow-hill-pheromone
  let scent-ahead hill-pheromone-scent-at-angle   0
  let scent-right hill-pheromone-scent-at-angle  60
  let scent-left  hill-pheromone-scent-at-angle -60
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
    [ ifelse scent-right > scent-left
      [ rt random 60 ]
      [ lt random 60 ] ]
end


;;; follow-food-pheromone
;;; Will see how much find-food-pheromone is ahead, to the right, and to the left of the ant. Then will determine which
;;; direction to turn by seeing which of the three directions has the most pheromones.
to follow-food-pheromone
  let scent-ahead food-pheromone-scent-at-angle   0
  let scent-right food-pheromone-scent-at-angle  45
  let scent-left  food-pheromone-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
    [ ifelse scent-right > scent-left
      [ rt random 45 ]
      [ lt random 45 ] ]
end

;;; hill-pheromone-scent-at-angle: angle
;;; Looks to the given angle and determines how much find-hill-pheromone is on that patch. Returns the amount.
to-report hill-pheromone-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody
    [ report 0 ]
  report [find-hill-pheromone] of p
end


;;; food-pheromone-scent-at-angle: angle
;;; Looks to the given angle and determines how much find-food-pheromone is on that patch. Returns the amount.
to-report food-pheromone-scent-at-angle [angle]
  let p patch-right-and-ahead angle 1
  if p = nobody
    [ report 0 ]
  report [find-food-pheromone] of p
end

;;; wiggle
;;; Randomly swivel to the right and left a little bit. If the ant can't move, then turn around (the ant may be in a
;;; corner or against a wall).
to wiggle
  rt random 40
  lt random 40
  if not can-move? 1
    [ rt 180 ]
end
