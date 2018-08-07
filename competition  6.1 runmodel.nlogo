extensions [ nw ]
breed [companies company]
undirected-link-breed [ strongs strong]
undirected-link-breed [weaks weak]
companies-own [ adoption disappointed judge pos neg slp wlp slnd wlnd reject slnr wlnr];; oc is organizational charateristics. slnr = strong link negtive effect by rejectors
globals [tech oc oct t0 t1 slor wlor vrejct failure l bass sse sst R2 first_satisfied judge_when];;strong-links-of-rejecters weak-links-of-rejecters. tc means technology characteristics


to setup
  clear-all
  no-display
  set judge_when 0
  set vrejct []
  set l []
  set oc (list 50 80)
  set bass [
    9.0
    21.19644
    37.5280915878
    59.0429089223
    86.7670324808
    121.455024615
    163.210738043
    211.048339005
    262.596372663
    314.249049816
    361.955332214
    402.414298961
    434.015951499
    456.968642863
    472.687832754
    482.991149913]
  setup-companies
  ask n-of k companies [set adoption true set disappointed true]
  ask n-of s companies [set adoption true set disappointed false]
  do-plots
  reset-ticks
end

to setup-companies
  nw:generate-random companies strongs number link-probability ;[ set color white]
  ;;layout-circle companies 70
  ask n-of (weak-ratio * count strongs) strongs [set breed weaks]

  ;ask strongs [set color blue]
  ask weaks [set color yellow]
  ask companies [
    set adoption false
    set disappointed false
    set judge false
    set reject false
    ;set oc (list 30 30 30)
    ]
end

to go
  set tech b + a * (80 - b) * count companies with [adoption = true] / 500
  ;set tech a * ticks + b
  set failure (1 - (similarity item 0 oc item 1 oc))
  companies-adopt-disappointed-reject
  ;kick-out
  ;set t1 count companies with [adoption = true]
  do-plots
  ;set t0 t1
  ;collect-data
  ;analyze-rejecters
  if judge_when = 0 and (count companies with [adoption = true] - count companies with [disappointed = true] > 0) [set judge_when 1 set first_satisfied ticks ]
  if ticks = stop-at [stop]
  ;if count companies with [adoption = false and reject = false] / count companies <= 0.05 [ stop ]
  ;if count companies with [adoption = true] / count companies >= 0.95 [stop]
  tick
end

to companies-adopt-disappointed-reject
  ask companies with [adoption = false and disappointed = false]; and reject = false ] ;; 访问所有无状态的company
  [
    set slp count strong-neighbors with [adoption = true and disappointed = false];; 将slp的值设为采纳了创新、不失望、且为强连接邻居的数量
    set wlp count weak-neighbors with [adoption = true and disappointed = false] ;; 将wlp的值设为采纳了创新、不失望、且为若连接邻居的数量
    set slnd count strong-neighbors with [adoption = true and disappointed = true];;将slnd的值设为采纳了创新、已失望、且为强连接邻居的数量
    set wlnd count weak-neighbors with [adoption = true and disappointed = true];; 将wlnd的值设为采纳了创新、已失望、且为弱连接邻居的数量
   ; set slnr count strong-neighbors with [adoption = false and disappointed = false and reject = true]
   ; set wlnr count weak-neighbors with [adoption = false and disappointed = false and reject = true]
    set pos 1 - (1 - p) * (1 - qs) ^ slp * (1 - qw) ^ wlp                                             ;;将pos的值设为  1 - (1 - p) * (1 - qs) ^ slp * (1 - qw) ^ wlp
    set neg 1 - (1 - m * qs) ^ slnd * (1 - m * qw) ^ wlnd * (1 - m * qs) ^ slnr * (1 - m * qw) ^ wlnr ;;将neg的值设为 1 - (1 - m * qs) ^ slnd * (1 - m * qw) ^ wlnd * (1 - m * qs) ^ slnr * (1 - m * qw) ^ wlnr

;;;;;;; adopt or not ?;;;;;;;;;
    if random-float 1 < (1 - neg) * pos + pos * neg * pos / (pos + neg) [ ;;取（0,1）之间的某个随机数，若该随机数小于 (1 - neg) * pos + pos * neg * pos / (pos + neg)则....
       if reject = false [
             if random-float 1 < (1 - failure) * (1 + gov_spt) [                                ;; 且若（0,1）之间某随机数小于1-failure
             set adoption true  ]]                                 ;;则将该企业adoption的状态改为true
       if reject = true [
             if random-float 1 < (1 - failure) * (1 + gov_spt) / m [
             set adoption true  set reject false]]
    ]

;;;;;;;; disappointed or not? ;;;;;;;;
     if adoption = true [
        if random-float 1 < failure [set disappointed true ]
      ]

;;;;;;;reject or not ?;;;;;;;;;
   ; if any-rejecters? = true [                                                                          ;;如果reject的开关为打开状态则
      if adoption = false and random-float 1 < (1 - pos) * neg + pos * neg * neg / (pos + neg)[         ;;如果adoption为假且（0，1）的随机数小于 (1 - pos) * neg + pos * neg * neg / (pos + neg)
        set reject true];]                                                                               ;;将reject改为true

  ]
end

to kick-out
  ask n-of (p_out * count companies with [reject = true]) companies with [reject = true] [die]
end

to-report similarity [x y]
  report  ((x * tc) + (y * tech)) / ( x ^ 2 + y ^ 2)
end

to analyze-rejecters
  ask companies with [ reject = true ] [set slor slor + count my-strongs]
  set-current-plot "Rejecter analysis"
  set-current-plot-pen "strong links"
  plot slor
  set slor 0
end

to collect-data
  if length l < (length bass) + 1 [
    set l lput (count companies with [adoption = true]) l]

  if length l = length bass [
    set sse (map [[x y] -> (x - y) ^ 2 ] l bass)
    set sst (map [x -> (x - (mean bass)) ^ 2] bass)
    set R2 (1 - ((sum sse) / (sum sst)))
  ]
end

to do-plots
 set-current-plot "New adopters"
 set-current-plot-pen "new adopters"
 plot t1 - t0
 set-current-plot "Adopters"
 set-current-plot-pen "total adopters"
 plot count companies with [adoption = true]
end
@#$#@#$#@
GRAPHICS-WINDOW
208
14
728
535
-1
-1
3.180124224
1
10
1
1
1
0
0
0
1
-80
80
-80
80
0
0
1
ticks
30.0

BUTTON
29
10
105
68
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
109
11
179
70
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
1

PLOT
206
12
886
377
Adopters
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"total adopters" 1.0 0 -1184463 true "" ""
"disappointed" 1.0 0 -5987164 true "" "plot count companies with [disappointed = true]"
"rejecters" 1.0 0 -2674135 true "" "plot count companies with [reject = true]"
"uneffected" 1.0 0 -14070903 true "" "plot count companies with [adoption = false and disappointed = false and reject = false]"
"total companies" 1.0 0 -14439633 true "" "plot number"

INPUTBOX
28
72
183
132
number
500.0
1
0
Number

PLOT
206
379
880
568
New adopters
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"new adopters" 1.0 0 -16777216 true "" ""

INPUTBOX
28
133
183
193
Stop-at
35.0
1
0
Number

SLIDER
26
267
198
300
p
p
0
0.04
0.037
0.0001
1
NIL
HORIZONTAL

SLIDER
26
304
198
337
qs
qs
0
1
0.2408
0.001
1
NIL
HORIZONTAL

SLIDER
26
339
198
372
qw
qw
0
1
0.0
0.001
1
NIL
HORIZONTAL

SLIDER
27
373
199
406
m
m
0
10
3.0
0.1
1
NIL
HORIZONTAL

SWITCH
27
411
199
444
any-rejecters?
any-rejecters?
0
1
-1000

MONITOR
777
139
884
184
disappointed-ratio
count companies with [adoption = true and disappointed = true] /\ncount companies
17
1
11

PLOT
1295
265
1657
536
Rejecter analysis
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"strong links" 1.0 0 -13791810 true "" ""

SLIDER
207
540
731
573
link-probability
link-probability
0
1
1.0
0.001
1
NIL
HORIZONTAL

PLOT
1414
12
1867
262
Total influence
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (sum [(1 - neg) * pos + pos * neg * pos / (pos + neg)] of companies) / count companies"

PLOT
885
12
1412
262
Similarity
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" "plot (similarity item 0 oc item 1 oc)"

SLIDER
26
199
197
232
weak-ratio
weak-ratio
0
1
0.0
0.1
1
NIL
HORIZONTAL

MONITOR
777
188
834
233
total
count companies with [reject = true] + count companies with [adoption = true]
17
1
11

SLIDER
26
447
198
480
a
a
0
3
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
26
481
198
514
b
b
0
80
30.0
1
1
NIL
HORIZONTAL

SLIDER
26
519
198
552
gov_spt
gov_spt
0
1
0.0
0.1
1
NIL
HORIZONTAL

SLIDER
26
560
198
593
tc
tc
0
50
40.0
1
1
NIL
HORIZONTAL

SLIDER
27
235
199
268
p_out
p_out
0
0.2
0.0
0.01
1
NIL
HORIZONTAL

MONITOR
777
240
846
285
adopters
count companies with [adoption = true]
17
1
11

MONITOR
780
432
837
477
NIL
R2
17
1
11

MONITOR
778
289
874
334
disappointed
count companies with [disappointed = true]
17
1
11

MONITOR
778
337
855
382
rejecters
count companies with [reject = true]
17
1
11

MONITOR
779
384
862
429
NIL
count companies with [adoption = true] - count companies with [disappointed = true]
17
1
11

PLOT
891
265
1291
544
plot 1
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count companies with [adoption = true] - count companies with [disappointed = true]"

SLIDER
27
605
199
638
k
k
0
50
10.0
1
1
NIL
HORIZONTAL

MONITOR
781
480
876
525
when satisified adopter occur
first_satisfied
17
1
11

TEXTBOX
775
528
925
593
只要产生一个满意采纳者，就会结束拒绝者高原，因而拒绝者高原是一个脆弱状态，因此要让平台良性运行要在初始状态安插一个满意者
12
0.0
1

SLIDER
213
603
385
636
s
s
0
50
1.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?



## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)
This is an agent-based model for simulating the energy efficiency technologies' diffusion among small and medium size enterprises.

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="rejecter variation experiment" repetitions="30" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count companies with [reject = true]</metric>
    <steppedValueSet variable="link-probability" first="0" step="0.001" last="0.4"/>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="number">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="any-rejecters?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="qs">
      <value value="0.304"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="disappointed-each-tick?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="qw">
      <value value="0.154"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p">
      <value value="0.0025"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Stop-at">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="link-probability">
      <value value="0.001"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="EET adoption experiment" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count companies with [adoption = true]</metric>
    <metric>count companies with [disappointed = true]</metric>
    <metric>count companies with [reject = true]</metric>
    <metric>count companies with [adoption = true] + count companies with [reject = true]</metric>
    <steppedValueSet variable="gov_spt" first="0" step="0.1" last="1"/>
    <steppedValueSet variable="a" first="1" step="2" last="15"/>
    <steppedValueSet variable="weak-ratio" first="0.2" step="0.1" last="0.8"/>
    <steppedValueSet variable="b" first="10" step="5" last="60"/>
    <enumeratedValueSet variable="tc">
      <value value="10"/>
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="EET adoption experiment 2" repetitions="15" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count companies with [adoption = true]</metric>
    <metric>count companies with [disappointed = true]</metric>
    <metric>count companies with [reject = true]</metric>
    <metric>count companies with [adoption = true] + count companies with [reject = true]</metric>
    <enumeratedValueSet variable="number">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="any-rejecters?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="qs" first="0.02" step="0.01" last="0.08"/>
    <steppedValueSet variable="qw" first="0.004" step="0.002" last="0.018"/>
    <enumeratedValueSet variable="disappointed-each-tick?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="a">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="p" first="0.001" step="0.002" last="0.01"/>
    <enumeratedValueSet variable="b">
      <value value="68"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="link-probability">
      <value value="0.2"/>
      <value value="0.4"/>
      <value value="0.6"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gov_spt">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weak-ratio">
      <value value="0.2"/>
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tc">
      <value value="42.5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="number">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="any-rejecters?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="qs">
      <value value="0.121"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="a">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p">
      <value value="0.0051"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Stop-at">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="21"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="link-probability">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gov_spt">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p_out">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="qw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weak-ratio">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m">
      <value value="1.6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tc">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="best_fitness_recheck" repetitions="100" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count companies with [adoption = true]</metric>
    <metric>count companies with [reject = true]</metric>
    <metric>count companies with [disappointed = true]</metric>
    <enumeratedValueSet variable="number">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="any-rejecters?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="qs">
      <value value="0.2408"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="a">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p">
      <value value="0.037"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Stop-at">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="link-probability">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gov_spt">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p_out">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="qw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weak-ratio">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="m">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tc">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="initial_disappointed_influence" repetitions="500" sequentialRunOrder="false" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count companies with [adoption = true]</metric>
    <metric>count companies with [reject = true]</metric>
    <metric>count companies with [disappointed = true]</metric>
    <enumeratedValueSet variable="number">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="any-rejecters?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="qs">
      <value value="0.2408"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="a">
      <value value="2.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="p">
      <value value="0.037"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Stop-at">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="b">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="link-probability">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="gov_spt">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="k" first="5" step="2" last="25"/>
    <enumeratedValueSet variable="p_out">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="qw">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="weak-ratio">
      <value value="0"/>
    </enumeratedValueSet>
    <steppedValueSet variable="m" first="1" step="0.2" last="3"/>
    <enumeratedValueSet variable="tc">
      <value value="40"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
