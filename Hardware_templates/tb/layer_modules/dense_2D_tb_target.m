% Convolution Test Bench calculation

Kernel1 = [ 1 1 2 2; 1 1 2 2; 2 2 1 1; 2 2 1 1 ]
Kernel2 = [ -2 -2 3 3; -2 -2 3 3; -2 -2 3 3; -2 -2 3 3 ]

window_a = [15 14 13 12; 11 10 9 8; 7 6 5 4; 3 2 1 0 ]
window_b = [16 15 14 13; 12 11 10 9; 8 7 6 5; 4 3 2 1 ]

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

    -2    -2     3     3
    -2    -2     3     3
    -2    -2     3     3
    -2    -2     3     3


window_a =

    15    14    13    12
    11    10     9     8
     7     6     5     4
     3     2     1     0


window_b =

    16    15    14    13
    12    11    10     9
     8     7     6     5
     4     3     2     1


a1 = 180

a2 = 20

b1 = 204

b2 = 28

%}