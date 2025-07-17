function [R_an L_an]= analytical_two_circular_conductors (radius, dist, sigma, mu_r_1, mu_r_2, f)

mu0=4*pi*1e-7;
om=2*pi*f;

a=sqrt(dist^2/4-radius^2);
Rs=sqrt(om/2*mu0/sigma);

%parameters for analytical calculation of resistance
R0=1/(sigma*pi*radius^2);
k=sqrt(-j*om*mu0*sigma);
delta=radius/dist;

ord=8;%order of analytical solution
for nn=1:ord
    lambda(nn)=-nn*besselj(nn-1,k*radius)/besselj(nn+1,k*radius);
    del(nn)=delta^(2*nn);
    for mm=1:ord
        T(nn,mm)=factorial(mm+nn-1)/(factorial(nn-1)*factorial(mm-1));
    endfor
endfor
LL=(mu0/pi)*log(dist/radius);
Q=T-diag(lambda./del);
A=Q\ones(ord,1);
Zprox=0;

for nn=1:ord
    Zprox=Zprox+j*om*mu0*A(nn)/pi;
endfor

Zsk=R0*k*radius*besselj(0,k*radius)/(2*besselj(1,k*radius));
Z=Zsk+Zprox/2+i*om*LL/2;
R_an=real(Z);
L_an=imag(Z)/om;

endfunction
