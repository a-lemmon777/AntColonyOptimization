;; Code written by Aaron Lemmon and Emma Sax
;; Code, interface, and info modified from Uri Wilensky's 1997 Ant Colony Optimization
;; Used in the University of Minnesota Morris's CSci 4553

globals [
  food-counter
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
;;; of 0. It will then set up all of the patches. Lastly it will reset all of the ticks.
to setup
  clear-all
  set-default-shape turtles "bug"
  create-turtles population
    [ set size 2
      set color red
      set pheromone-strength 0 ]
  set food-counter 0
  setup-patches
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
;;; It will set up two hills hard-coded diagonally in the center of the board. It will set the hill? boolean as true
;;; on those spots and false everywhere else.
to setup-hill
  ifelse ((distancexy (-0.35 * max-pxcor) (0.2 * max-pycor)) < 3) or ((distancexy (0.1 * max-pxcor) (-0.3 * max-pycor)) < 3)
    [ set hill? true ]
    [ set hill? false ]
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

  if (distancexy (-0.9 * max-pxcor) (-0.85 * max-pycor)) < 3
    [ set food-source-number 5 ]

  if food-source-number > 0
    [ set food 4
      set food-counter food-counter + 4 ]
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
        if food-source-number = 4 [ set pcolor yellow ]
        if food-source-number = 5 [ set pcolor pink ] ]
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
    [ if hill? or (food > 0)
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
  if food-counter = 0
    [ stop ]
end

;;; hill-procedure
;;; If the ant is on a hill, then drop off food and recolor ant to red and turn around. If the ant is not on a
;;; hill, then see if the ant randomly walked across a food source. If not, then drop some find-food-pheromone.
;;; Then decrement the ant's pheromone-strength if possible. Lastly, find a direction to move that is following
;;; the find-hill-pheromone and move.
to hill-procedure
  ifelse hill?
    [ set color red
      set food-counter food-counter - 1
      rt 180 ]
    [ if food <= 0
        [ set find-food-pheromone find-food-pheromone + pheromone-strength ]
      ifelse pheromone-strength >= food-pheromone-falloff
        [ set pheromone-strength pheromone-strength - food-pheromone-falloff ]
        [ set pheromone-strength 0 ]
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
      ifelse pheromone-strength >= hill-pheromone-falloff
        [ set pheromone-strength pheromone-strength - hill-pheromone-falloff ]
        [ set pheromone-strength 0 ]
      if (find-food-pheromone >= 0.05) and (find-food-pheromone < 2)
        [ follow-food-pheromone ] ]
end

;;; follow-hill-pheromone
;;; Will see how much find-hill-pheromone is ahead, to the right, and to the left of the ant. Then will determine which
;;; direction to turn by seeing which of the three directions has the most pheromones.
to follow-hill-pheromone
  let scent-ahead hill-pheromone-scent-at-angle   0
  let scent-right hill-pheromone-scent-at-angle  45
  let scent-left  hill-pheromone-scent-at-angle -45
  if (scent-right > scent-ahead) or (scent-left > scent-ahead)
    [ ifelse scent-right > scent-left
      [ rt 45 ]
      [ lt 45 ] ]
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
      [ rt 45 ]
      [ lt 45 ] ]
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
@#$#@#$#@
GRAPHICS-WINDOW
512
10
1228
747
35
35
9.944
1
10
1
1
1
0
0
0
1
-35
35
-35
35
1
1
1
ticks
30.0

BUTTON
142
16
247
49
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
294
16
397
49
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
54
59
457
92
population
population
0
200
125
1
1
NIL
HORIZONTAL

SLIDER
54
141
458
174
find-hill-diffusion
find-hill-diffusion
0
40
3
1
1
NIL
HORIZONTAL

SLIDER
54
100
458
133
find-food-diffusion
find-food-diffusion
0
40
3
1
1
NIL
HORIZONTAL

SLIDER
54
182
458
215
find-food-evaporation
find-food-evaporation
0
20
7
1
1
NIL
HORIZONTAL

SLIDER
54
222
458
255
find-hill-evaporation
find-hill-evaporation
0
20
7
1
1
NIL
HORIZONTAL

SLIDER
54
349
460
382
default-pheromone-strength
default-pheromone-strength
0
100
60
1
1
NIL
HORIZONTAL

PLOT
12
399
503
746
Food Amount per Food Pile
time
food
0.0
50.0
0.0
120.0
true
false
"" ""
PENS
"Pile 1" 1.0 0 -11221820 true "" "plotxy ticks sum [food] of patches with [pcolor = cyan]"
"Pile 2" 1.0 0 -5825686 true "" "plotxy ticks sum [food] of patches with [pcolor = magenta]"
"Pile 3" 1.0 0 -13345367 true "" "plotxy ticks sum [food] of patches with [pcolor = blue]"
"Pile 4" 1.0 0 -1184463 true "" "plotxy ticks sum [food] of patches with [pcolor = yellow]"
"Pile 5" 1.0 0 -2064490 true "" "plotxy ticks sum [food] of patches with [pcolor = pink]"

SLIDER
53
264
459
297
food-pheromone-falloff
food-pheromone-falloff
0
10
3
1
1
NIL
HORIZONTAL

SLIDER
53
306
460
339
hill-pheromone-falloff
hill-pheromone-falloff
0
10
3
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

In this project, a colony of ants forages for food. Though each ant follows a set of simple rules, the colony as a whole acts in a sophisticated way.

## HOW IT WORKS

When an ant finds a piece of food, it carries the food back to either ant hill, dropping a `find-food-pheromone` as it moves. When other ants "sniff" the `find-food-pheromone`, they follow it toward the food. As more ants carry food to the ant hill, they reinforce the pheromone trail.

Similarly, when an ant walks over an ant hill, they drop a `find-hill-pheromone`. This pheromone can be used to help ants find their way back to the ant hill after they've collected food.

## HOW TO USE IT

Click the SETUP button to set up the ant hills (in violet) and five piles of food. Click the GO button to start the simulation. The `find-food-pheromone` is shown in an orange-to-white gradient. The `find-hill-pheromone` is shown in a green-to-white gradient. The entire simulation will stop when all of the food has been collected and returned to an ant hill.

Use the sliders on the left to change the parameters. The lower the FIND-FOOD-DIFFUSION and FIND-HILL-DIFFUSION levels, the less the pheromones will spread. The lower the FIND-FOOD-EVAPORATION and FIND-HILL-EVAPORATION levels, the slower the pheromones will disappear. FOOD-PHEROMONE-FALLOFF and HILL-PHEROMONE-FALLOFF determine how quickly the pheromone strength fades as an ant travels. The higher the number, the quicker the fade.

The higher the DEFAULT-PHEROMONE-STRENGTH, the more pheromones will be left behind. The chart on the bottom shows how much food remains in each food pile at every tick. To change the number of ants, move the POPULATION level higher or lower.

## THINGS TO NOTICE

The ant colony generally exploits the food sources in order, starting with the food closest to the center/ant hills, and finishing with the food most distant from the ant hills. It is more difficult for the ants to form a stable trail to the more distant food, since the pheromone trails are more likely to evaporate before being reinforced.

Once the colony finishes collecting the closest food, the pheromone trail to that food naturally disappears, freeing up ants to help collect the other food sources. The more distant food sources require a larger "critical number" of ants to form a stable trail.

## NETLOGO FEATURES

The built-in `diffuse` primitive allows us to diffuse the chemical easily without complicated code.

The primitive `patch-right-and-ahead` is used to make the ants smell in different directions without actually turning.

## WHERE THIS CODE CAME FROM

This code was originally written by Aaron Lemmon and Emma Sax, although it was modified from Uri Wilensky's 1997 Ant Colony Optimization version on NetLogo. It was designed for  the University of Minnesota Morris's CSci 4553.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
