% Convolution Test Bench calculation

Kernel1 = [ 1 1 2 2; 1 1 2 2; 2 2 1 1; 2 2 1 1 ]
Kernel2 = [ 2 2 -3 -3; 2 2 -3 -3; 2 2 -3 -3; 2 2 -3 -3 ]

window_a = [21 20 19 18; 15 14 13 12; 9 8 7 6; 3 2 1 0 ]
window_b = [22 21 20 19; 16 15 14 13; 10 9 8 7; 4 3 2 1 ]

a1 = sum(sum(Kernel1 .* window_a))
a2 = sum(sum(Kernel2 .* window_a))
b1 = sum(sum(Kernel1 .* window_b))
b2 = sum(sum(Kernel2 .* window_b))

%{

Kernel1 =

     1     1     2     2
     1     1     2     2
     2     2     1     1
     2     2     1     1


Kernel2 =

     2     2    -3    -3
     2     2    -3    -3
     2     2    -3    -3
     2     2    -3    -3


window_a =

    21    20    19    18
    15    14    13    12
     9     8     7     6
     3     2     1     0


window_b =

    22    21    20    19
    16    15    14    13
    10     9     8     7
     4     3     2     1

a1 =  252

a2 = -44

b1 = 276

b2 = -52

%}