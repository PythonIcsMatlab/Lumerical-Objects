% This function computes the reflectivity and trasmissivity of a
% dielectric multilayer stack. The multilayer vector has to include
% the substrate (as first element) and the external medium (as lat
% layer). 
% The thickness of these two layers will not matter, since the
% computation will start at the first interface and will end at the
% last one. Indeed the values of the field r and t will be computed at
% such interfaces. 



function [R,r,t,Tr] = reflectivity (lambda,theta_in,d,n,pol)

N_out = nargout;
N_layers=length(d);
if N_layers~=length(n) 
   error("thicknesses and refractive index vectors must have same length")
end

% if you propose a multilayer which is altready optimized for this
% calculation (i.e. no dummy layers and no zero thicknes layers), you
% can comment the next line and save some computational time.
% [d,n] = prepare_multilayer(d,n);

N_layers = length(d);

theta_in = theta_in/180*pi;

K = 2*pi/lambda;

size_T = length(theta_in);
r = zeros(1,size_T);
t = zeros(1,size_T);
Tr= zeros(1,size_T);

beta = n(1)*sin(theta_in);
%% loop
for i=1:size_T
    beta_i = beta(i);
    costheta_z = sqrt(n.^2-beta(i)^2)./n;
    T = eye(2);  
%     D = eye(2);
    for j=1:N_layers-1
        P = prop(K*n(j),d(j),costheta_z(j));
        Tijc=Tij(n(j),n(j+1),beta_i,pol);
        T=Tijc*P*T;
%         P = prop(K*n(j),-d(j),costheta_z(j));
%         Dijc=Dij(n(j),n(j+1),beta_i,pol);
%         D=D*P*Dijc;
    end
%     t(i) = 1/D(1,1);
%     r(i) = D(2,1)*t(i);
    r(i) = -T(2,1)/T(2,2);
    t(i) = T(1,1)+r(i)*T(1,2);
    if N_out > 3
        Tr(i) = abs( t(i)*n(end)/n(1)*real(costheta_z(end))...
                        /costheta_z(1) )^2;
    end
end

R=abs(r).^2;
end