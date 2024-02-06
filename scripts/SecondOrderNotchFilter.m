% Second Order Rejection Filter (Notch)

function [b, a] = SecondOrderNotchFilter(z,B,fc,T)

%
% Input: - z:  minimum attenuation at frequency fc (ex: 0.01)
%	     - B:  bandwidth corresponding to attenuation 0.707 (ex: 2-8)
% 	     - fc: middle-band frequency (ex: 50 or 60 Hz - Power-Line Frequency)
% 	     - T:  sampling interval
%
% Output: - b  filter coefficients (MA part - Moving Average part)
%	      - a  filter coefficients (AR part - Auto-Regressive part)
%

b = pi*B*T;
a = b*z;
c1 = -2*(1-a)*cos(2*pi*fc*T);
c2 = (1-a)^2;
c3 = 2*(1-b)*cos(2*pi*fc*T);
c4 = -(1-b)^2;
b = [1 c1 c2];
a = [1 -c3 -c4];

end