% Convolution Test Bench calculation
Kernel1 = zeros(4,4,4);
Kernel1(:,:,1) = [ -1 -1 2 2; -1 -1 2 2; 2 2 -1 -1; 2 2 -1 -1 ];
Kernel1(:,:,2) = ones(4,4)*3;
Kernel1(:,:,3) = ones(4,4)*3;
Kernel1(:,:,4) = ones(4,4)*3

Kernel2 = zeros(4,4,4);
Kernel2(:,:,1) = [ 2 2 3 3; 2 2 3 3; 2 2 3 3; 2 2 3 3 ];
Kernel2(:,:,2) = ones(4,4)*4;
Kernel2(:,:,3) = ones(4,4)*4;
Kernel2(:,:,4) = ones(4,4)*4

window_a = zeros(4,4,4);
window_a(:,:,1) = [21 20 19 18; 15 14 13 12; 9 8 7 6; 3 2 1 0 ];
window_a(:,:,2) = [21 20 19 18; 15 14 13 12; 9 8 7 6; 3 2 1 0 ];
window_a(:,:,3) = [21 20 19 18; 15 14 13 12; 9 8 7 6; 3 2 1 0 ];
window_a(:,:,4) = [21 20 19 18; 15 14 13 12; 9 8 7 6; 3 2 1 0 ]
window_b = zeros(4,4,4);
window_b(:,:,1) = [22 21 20 19; 16 15 14 13; 10 9 8 7; 4 3 2 1 ];
window_b(:,:,2) = [22 21 20 19; 16 15 14 13; 10 9 8 7; 4 3 2 1 ];
window_b(:,:,3) = [22 21 20 19; 16 15 14 13; 10 9 8 7; 4 3 2 1 ];
window_b(:,:,4) = [22 21 20 19; 16 15 14 13; 10 9 8 7; 4 3 2 1 ]

disp('Device #1');
a1 = sum(sum(sum(Kernel1 .* window_a)))
a2 = sum(sum(sum(Kernel2 .* window_a)))
b1 = sum(sum(sum(Kernel1 .* window_b)))
b2 = sum(sum(sum(Kernel2 .* window_b)))

disp('Device #2');
a1 = sum(sum(sum(Kernel1(:,:,1:2) .* window_a(:,:,1:2))))
a2 = sum(sum(sum(Kernel2(:,:,1:2) .* window_a(:,:,1:2))))
b1 = sum(sum(sum(Kernel1(:,:,1:2) .* window_b(:,:,1:2))))
b2 = sum(sum(sum(Kernel2(:,:,1:2) .* window_b(:,:,1:2))))

%{
Kernel1(:,:,1) =

    -1    -1     2     2
    -1    -1     2     2
     2     2    -1    -1
     2     2    -1    -1


Kernel1(:,:,2) =

     3     3     3     3
     3     3     3     3
     3     3     3     3
     3     3     3     3


Kernel1(:,:,3) =

     3     3     3     3
     3     3     3     3
     3     3     3     3
     3     3     3     3


Kernel1(:,:,4) =

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


Kernel2(:,:,3) =

     4     4     4     4
     4     4     4     4
     4     4     4     4
     4     4     4     4


Kernel2(:,:,4) =

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


window_a(:,:,3) =

    21    20    19    18
    15    14    13    12
     9     8     7     6
     3     2     1     0


window_a(:,:,4) =

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


window_b(:,:,3) =

    22    21    20    19
    16    15    14    13
    10     9     8     7
     4     3     2     1


window_b(:,:,4) =

    22    21    20    19
    16    15    14    13
    10     9     8     7
     4     3     2     1

Device #1

a1 = 1596
a2 = 2428
b1 = 1748
b2 = 2660

Device #2

a1 = 588
a2 = 1084
b1 = 644
b2 = 1188

%}