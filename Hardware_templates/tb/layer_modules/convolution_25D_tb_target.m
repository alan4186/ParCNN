% Convolution Test Bench calculation
Kernel1 = zeros(4,4,2);
Kernel1(:,:,1) = [ 1 1 2 2; 1 1 2 2; 2 2 1 1; 2 2 1 1 ];
Kernel1(:,:,2) = ones(4,4)*3

Kernel2 = zeros(4,4,2);
Kernel2(:,:,1) = [ 2 2 3 3; 2 2 3 3; 2 2 3 3; 2 2 3 3 ];
Kernel2(:,:,2) = ones(4,4)*4

window_a = zeros(4,4,2);
window_a(:,:,1) = [21 20 19 18; 15 14 13 12; 9 8 7 6; 3 2 1 0 ];
window_a(:,:,2) = [21 20 19 18; 15 14 13 12; 9 8 7 6; 3 2 1 0 ]
window_b = zeros(4,4,2);
window_b(:,:,1) = [22 21 20 19; 16 15 14 13; 10 9 8 7; 4 3 2 1 ];
window_b(:,:,2) = [22 21 20 19; 16 15 14 13; 10 9 8 7; 4 3 2 1 ]

a1 = sum(sum(sum(Kernel1 .* window_a)))
a2 = sum(sum(sum(Kernel2 .* window_a)))
b1 = sum(sum(sum(Kernel1 .* window_b)))
b2 = sum(sum(sum(Kernel2 .* window_b)))

%{

Kernel1(:,:,1) =

     1     1     2     2
     1     1     2     2
     2     2     1     1
     2     2     1     1


Kernel1(:,:,2) =

     3     3     3     3
     3     3     3     3
     3     3     3     3
     3     3     3     3


Kernel2(:,:,1) =

     2     2     3     3
     2     2     3     3
     2     2     3     3
     2     2     3     3


Kernel2(:,:,2) =

     4     4     4     4
     4     4     4     4
     4     4     4     4
     4     4     4     4


window_a(:,:,1) =

    21    20    19    18
    15    14    13    12
     9     8     7     6
     3     2     1     0


window_a(:,:,2) =

    21    20    19    18
    15    14    13    12
     9     8     7     6
     3     2     1     0


window_b(:,:,1) =

    22    21    20    19
    16    15    14    13
    10     9     8     7
     4     3     2     1


window_b(:,:,2) =

    22    21    20    19
    16    15    14    13
    10     9     8     7
     4     3     2     1


a1 = 756

a2 = 1084

b1 = 828

b2 = 1188
%}