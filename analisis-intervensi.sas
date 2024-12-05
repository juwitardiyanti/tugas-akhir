data tambang;
input s zt;
datalines;
0 42
0 98
0 90
0 69
0 82
0 135
0 142
0 104
0 135
0 166
0 161
0 188
0 207
0 208
0 238
0 167
0 258
0 224
0 209
0 259
0 236
0 205
0 285
0 366
0 207
0 357
0 277
0 280
0 232
0 353
0 255
0 391
0 233
0 352
0 307
0 285
0 271
0 368
0 273
0 327
0 310
0 310
0 372
0 355
0 274
0 225
0 326
0 203
0 255
0 195
0 310
1 273
1 520
1 493
1 .
1 .
1 .
;
data tambang ;
set tambang ;
proc arima data = tambang;
identify var = zt(1) crosscorr = (s(1)) noprint; 
estimate p=1 q=1 input = (1$(0)s) 
noint method=cls;  
forecast out = ramalan lead = 3; 
run ;
proc print data = ramalan ;
run ;
proc univariate  data = ramalan normal plot ;
var residual ;
run ;
