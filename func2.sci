// One significant digit

function x = signal(t)
   //require input periodic function
    x = cos(%pi*t/2) - sin(%pi*t/8) + 3* cos(%pi*t/4 + %pi/3)
    //x = 3 * sin(100 * %pi *t)
endfunction

W = [%pi / 2, %pi / 8, %pi / 4];
//W = [100 * %pi];

delta = input("Quantization Step: ");

//L  = input("Quantization levels: ");


// STEP 1: Sampler
F = W ./ (2 * %pi) ;
F_max = max(F) ;
F_s = 4 * F_max;

// STEP 2: Quantizer
W_new = W .* (1 / F_s) ;
T_list = (2 * %pi) ./ W_new;

T_lcm = lcm(T_list) ;

t = [0: 0.1 : T_lcm - 1]' ;
n = [0: 1 : T_lcm - 1]'; // n: number need to apply to function such that find max, min

x = signal(t) ;

x_q = signal(n ./ F_s);

max_q = max (x_q);
min_q = min (x_q);

// x_q_truncation of signal(n ./F_s)
x_q_truncation = [];
for i = 1:T_lcm
   if x_q(i) < 0 then
      x_q_truncation(i) = ceil(x_q(i)*10) / 10;
   else
      x_q_truncation(i) = floor(x_q(i) *10) / 10;
   end;
end;


//x_q_rounding  of signal(n ./F_s)
x_q_rounding = round(x_q .*10) ./ 10; // round 1 chu so sau dau phay

// max_q_truncation
 max_q_truncation = max (x_q_truncation);

// min_q_truncation
min_q_truncation = min (x_q_truncation);

// max_q_rounding
max_q_rounding = max (x_q_rounding);

// min_q_rounding
min_q_rounding = min (x_q_rounding);

// // constant delta to find 'L'
//delta = (max_q - min_q) / (L - 1
L = (max_q - min_q) / delta + 1;


b = ceil(log2(L)); // number of bits


x_q_rounding_binary = [];

for i = 1:T_lcm
   x_q_rounding_binary(i) = dec2bin( int( (x_q_rounding(i) - min_q_rounding ) / delta ), b);
end;

x_q_truncation_binary = [];

for i = 1:T_lcm
   x_q_truncation_binary(i) = dec2bin( int( (x_q_truncation(i) - min_q_truncation) / delta ), b);
end;


clf();

subplot(2,2,1);
title("Analog Singal");
plot(x);
xlabel('t');
ylabel('x(t)');

subplot(2,2,2);
title("After sampler");
plot(x_q);
xlabel('n');
ylabel('x(n)');

subplot(2,2,3);
plot2d3(n, x_q_rounding);
scatter(n, x_q_rounding, "red", "fill");
xstring(n, x_q_rounding, string(x_q_rounding));
title("Quantizing signal");
xlabel('n');
ylabel('x_q_rounding(n)');

subplot(2,2,4);
plot2d2(n, x_q_rounding);
scatter(n, x_q_rounding, "red", "fill");
xstring(n, x_q_rounding, string(x_q_rounding_binary));
title("Binary Code");
xlabel('n');
ylabel('Binary');

scf(1);
subplot(2,2,1);
title("Analog Singal");
plot(x);
xlabel('t');
ylabel('x(t)');

subplot(2,2,2);
title("After sampler");
plot(x_q);
xlabel('n');
ylabel('x(n)');


subplot(2,2,3);
plot2d3(n, x_q_truncation);
scatter(n, x_q_truncation, "red", "fill");
xstring(n, x_q_truncation, string(x_q_truncation));
title("Quantizing signal");
xlabel('n');
ylabel('x_q_truncation(n)');

subplot(2,2,4);
plot2d2(n, x_q_truncation);
scatter(n, x_q_truncation, "red", "fill");
xstring(n, x_q_truncation, string(x_q_truncation_binary));
title("Binary Code");
xlabel('n');
ylabel('Binary');


fd = mopen("C:\Users\16526\Desktop\SciLab_code\Lib\output2.txt",'wt');

mputl(          '                                 x(n)                       x_q(n)                    x_q(n)             e_q(n) = x_q(n) - x(n)', fd);
mputl(          "             n              Discrate_time signal          (Truncation)               (Rounding)                (Rounding)     ", fd);
for i = 1: T_lcm
   e_q = x_q_rounding(i) - x_q(i);
   mfprintf(fd, "             %d                       %f                        %.1f                       %.1f                         %f        \n", n(i), x_q(i), x_q_truncation(i), x_q_rounding(i), e_q);
end;

mclose(fd);
