turtles-own [
  flockmates ;;agentset of nearby turtles
  nearest-neighbor ;; closest one of our flockmates
]

breed [BTSfans BTSfan]
breed [SHINeefans SHINeefan]
breed [BlackSwanfans BlackSwanfan]
breed [BigBangfans BigBangfan]
breed [Twicefans Twicefan]

;; this procedures sets up the model
to setup
  clear-all
  ask patches [
    set pcolor 139
  ]
  create-BTSfans 20 [  ;; create the initial people that move at random
    setxy random-xcor random-ycor
    set color black ;; the color they have before choosing their preference
    set shape "person"
    set size 2
    set flockmates no-turtles
  ]
  create-SHINeefans 15 [
    setxy random-xcor random-ycor
    set color black ;; the color they have before choosing their preference
    set shape "person"
    set size 2
    set flockmates no-turtles
  ]
  create-BlackSwanfans 10 [
    setxy random-xcor random-ycor
    set color black ;; the color they have before choosing their preference
    set shape "person"
    set size 2
    set flockmates no-turtles
  ]
  create-BigBangfans 13 [
    setxy random-xcor random-ycor
    set color black ;; the color they have before choosing their preference
    set shape "person"
    set size 2
    set flockmates no-turtles
  ]
  create-Twicefans 12 [
    setxy random-xcor random-ycor
    set color black ;; the color they have before choosing their preference
    set shape "person"
    set size 2
    set flockmates no-turtles
  ]
  set concert false ;; the global variable 'concert' defined with the switch
  ;;it is set to false to allow the program to start with random movement
  reset-ticks
end

;; define the go procedure
;; this function will allow to change between random movement and regular movement depending
;; on whether the switch is set on or off. If the switch is off, we have random movement.
;; If the switch is on we have a regular movement
to go
  if concert = false [random-mov]
  if concert [move-random-away]
end

;;---------------------------------RANDOM MOVEMENT-------------------------------------------------
;; this procedure sets the random movement
to random-mov
  ask turtles [
    wiggle  ;; first turn a little bit in each direction
    move    ;; then step forward
  ]
  if concert [ stop ] ;; if the switch is on, this procedure stops working
  tick
end

;; turtle procedure, the turtle changes its heading
to wiggle
  right  random 40
  left random 10
end

;; turtle procedure
to move
  forward 1 + random 3  ;; take a random amount of steps forward between 1 and 4
end

;;--------------------------------CLUSTERED MOVEMENT-----------------------------------------------

;; this procedure creates a grouped movement
;; people only group if they have chosen their preference beforehand
to set-color
  ask BTSfans[
    set color 126] ;;purple
  ask SHINeefans[
    set color 96] ;;blue
  ask BlackSwanfans [
    set color 13] ;;burgundy
  ask BigBangfans [
    set color 45] ;;yellow
  ask Twicefans [
    set color 27] ;;light orange
end
to group
  set-color
  ask turtles [ flock ]
  if concert [stop] ;; this procedure only works when the switch is off
  tick
end

to flock  ;; turtle procedure
  set flockmates other turtles with [color = [color] of myself]in-radius 100
  if any? flockmates
    [ find-nearest-neighbor
      ifelse distance nearest-neighbor < 0
          [ separate ] ;; it separates from turtles that don't have the same color
      [ align ;; it brings the turtle close to the turles of their color
             cohere]]  ;; it keeps the turtles of the same color together
end



to find-nearest-neighbor ;; turtle procedure
  set nearest-neighbor min-one-of flockmates [distance myself]
end

;;; SEPARATE

to separate  ;; turtle procedure
  turn-away ([heading] of nearest-neighbor) 20
end

;;; ALIGN

to align  ;; turtle procedure
  turn-towards average-flockmate-heading 20
end



to-report average-flockmate-heading  ;; turtle procedure
  ;; We can't just average the heading variables here.
  ;; For example, the average of 1 and 359 should be 0,
  ;; not 180.  So we have to use trigonometry.
  let x-component sum [dx] of flockmates
  let y-component sum [dy] of flockmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

;;; COHERE

to cohere  ;; turtle procedure
  turn-towards average-heading-towards-flockmates 20
end

to-report average-heading-towards-flockmates  ;; turtle procedure
  ;; "towards myself" gives us the heading from the other turtle
  ;; to me, but we want the heading from me to the other turtle,
  ;; so we add 180
  let x-component mean [sin (towards myself + 180)] of flockmates
  let y-component mean [cos (towards myself + 180)] of flockmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

;;; HELPER PROCEDURES

to turn-towards [new-heading max-turn]  ;; turtle procedure
  turn-at-most (subtract-headings new-heading heading) max-turn
end


to turn-away [new-heading max-turn]  ;; turtle procedure
  turn-at-most (subtract-headings heading new-heading) max-turn
end

;; turn right by "turn" degrees (or left if "turn" is negative),
;; but never turn more than "max-turn" degrees
to turn-at-most [turn max-turn]  ;; turtle procedure
  ifelse abs turn > max-turn
    [ ifelse turn > 0
        [ rt max-turn ]
        [ lt max-turn ] ]
    [ rt turn ]
end

;;----------------------------------------REGULAR MOVEMENT-------------------------------------------

;; this procedure is used to create a regular movement
to move-random-away ;; turtle procedure
  set-color
  ask turtles [
  set nearest-neighbor min-one-of other turtles [distance myself] ;; it distances the turtles in groups
  face nearest-neighbor
  rt 180
  fd 1
  ]
  if concert = false [ stop ] ;; this procedure only works when the switch is on
  tick

end

;;-----------------------------------------EXPORT COORDINATES----------------------------------------
;; this procedure is used to export the coordinates in any chosen moment
;; it allows the user to choose where to store it and how to name it
to export-coord
  let file user-new-file
   if is-string? file
  [
    ;; If the file already exists, we begin by deleting it, otherwise
    ;; new data would be appended to the old contents.
    if file-exists? file
      [ file-delete file ]
    file-open file
    ;; record the initial turtle data
    write-to-file
  ]
end

;; this procedure it is used to define what we want written in the file
to write-to-file
  file-print (word "person\txcor\tycor")
  ;; use SORT so the turtles print their data in order by who number,
  ;; rather than in random order
  foreach sort turtles [ t ->
    ask t [
      file-print (word self "\t" pxcor "\t" pycor)
    ]
  ]
  file-print ""
 file-close ;; blank line
end
@#$#@#$#@
GRAPHICS-WINDOW
272
19
700
448
-1
-1
12.0
1
10
1
1
1
0
1
1
1
-17
17
-17
17
1
1
1
ticks
20.0

BUTTON
60
43
126
76
Setup
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
157
42
220
75
Go
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

BUTTON
88
84
192
117
Fangirl event
group
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
68
170
204
203
Export coordinates
export-coord
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SWITCH
85
130
191
163
Concert
Concert
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

This model is an attempt to mimic the behaviour of kpop fans (a music genre, where there are many different bands and artists). The fans in this model follow three kinds of behaviour depending on the situation. At first, each person lives their normal life, so they move at random. Once they choose the band or the artist that they like (they are assigned a different colour) they can either keep on living normally or start to group according to their preference when there is an event such as a fanmeeting. When there is a music festival where all the singers perform, the fans attend and have to put themselves in order (regular movement), because the bodyguards would take them out if they were to create chaos or empty spaces.

## HOW IT WORKS

The kpop fans follow three movements: "random" "group", and "regular"

"Random" means that each person moves individually and differently from any other person.

"Group" means that they start flocking together according to their colours. The group movement follows three rules: "alignment", "separation", and "cohesion".
 
* "Alignment" means that a person tends to turn so that it is moving in the same direction that nearby people are moving.

* "Separation" means that a person will turn to avoid another person with a different preference who gets too close.

* "Cohesion" means that a person will move towards other nearby people of the same preference (color).

* When two people with a different preference are too close, the "separation" rule overrides the other two, which are deactivated until the minimum separation is achieved.

"Regular" means that if the person has any other person too close they will distance themselves until they are at the same distance from all the other people.


## HOW TO USE IT

First, press "Setup" to create the people, and press "GO" to have them start moving around randomly. 

To make them form groups according to their preferences, press the "Fangirl event" button. This button assigns a colour to each person that represents their band preference, and they start grouping according to their preferences.
By unclicking the "Fangirl event" button the movement can be reversed to random. However, the band preference is maintained through the rest of the simulation, because once you get into a fandom, you can never get out.

To create a regular movement (at a Concert), the switch must be turned ON. When the switch turns ON, the random and grouped movement stops and the regular movement starts automatically. It is important to be noticed that the grouped movement cannot be activated while the switch is ON. To go back to a random movement, the switch must be turned OFF. Once the switch is OFF, the Fangirl event button can be pressed to start a grouped movement again.

## THINGS TO NOTICE

Central to the model is the observation that groups form without a leader.

There are random numbers used in this model, mainly to position the people initially and create the random movement (Normal life).

Also, notice that each group is not dynamic.  A flock, once together, is guaranteed to keep all of its members, unless the grouping movement is stopped. After running the model for a while, all of the people in a group have approximately the same heading, since they are programmed to always stay together.

## RELATED MODELS

* Wolf Sheep Simple 1
* Moths
* Flocking Vee Formation
* Flocking - Alternative Visualizations
* Segregation Simple
* Scatter

## REFERENCES

* Wilensky, U. (1998).  NetLogo Flocking model.  http://ccl.northwestern.edu/netlogo/models/Flocking.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

* Wilensky, U. (2007).  NetLogo Wolf Sheep Simple 1 model.  http://ccl.northwestern.edu/netlogo/models/WolfSheepSimple1.  Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.

* Wilensky, U. (2004).  NetLogo Scatter model.  http://ccl.northwestern.edu/netlogo/models/Scatter.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

* Wilensky, U., Rand, W. (2006).  NetLogo Segregation Simple model.  http://ccl.northwestern.edu/netlogo/models/SegregationSimple.  Center for Connected Learning and Computer-Based Modeling, Northwestern Institute on Complex Systems, Northwestern University, Evanston, IL.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

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

link
true
0
Line -7500403 true 150 0 150 300

link direction
true
0
Line -7500403 true 150 150 30 225
Line -7500403 true 150 150 270 225

moose
false
0
Polygon -7500403 true true 196 228 198 297 180 297 178 244 166 213 136 213 106 213 79 227 73 259 50 257 49 229 38 197 26 168 26 137 46 120 101 122 147 102 181 111 217 121 256 136 294 151 286 169 256 169 241 198 211 188
Polygon -7500403 true true 74 258 87 299 63 297 49 256
Polygon -7500403 true true 25 135 15 186 10 200 23 217 25 188 35 141
Polygon -7500403 true true 270 150 253 100 231 94 213 100 208 135
Polygon -7500403 true true 225 120 204 66 207 29 185 56 178 27 171 59 150 45 165 90
Polygon -7500403 true true 225 120 249 61 241 31 265 56 272 27 280 59 300 45 285 90

moose-face
false
0
Circle -7566196 true true 101 110 95
Circle -7566196 true true 111 170 77
Polygon -7566196 true true 135 243 140 267 144 253 150 272 156 250 158 258 161 241
Circle -16777216 true false 127 222 9
Circle -16777216 true false 157 222 8
Circle -1 true false 118 143 16
Circle -1 true false 159 143 16
Polygon -7566196 true true 106 135 88 135 71 111 79 95 86 110 111 121
Polygon -7566196 true true 205 134 190 135 185 122 209 115 212 99 218 118
Polygon -7566196 true true 118 118 95 98 69 84 23 76 8 35 27 19 27 40 38 47 48 16 55 23 58 41 71 35 75 15 90 19 86 38 100 49 111 76 117 99
Polygon -7566196 true true 167 112 190 96 221 84 263 74 276 30 258 13 258 35 244 38 240 11 230 11 226 35 212 39 200 15 192 18 195 43 169 64 165 92

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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
NetLogo 6.2.2
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
