function out = delta_e(lab1, lab2, deltaeversion)
if nargin < 3
    deltaeversion = 'CIE76';
end

switch deltaeversion
    case 'CIE76'
        out = norm(lab1 - lab2);
    case 'CIE94'
        l1 = lab1(1);
        a1 = lab1(2);
        b1 = lab1(3);
        
        l2 = lab2(1);
        a2 = lab2(2);
        b2 = lab2(3);
        
        deltaL      = l1 - l2;
        deltaA      = a1 - a2;
        deltaB      = b1 - b2;
        
        C1          = sqrt(a1^2 + b1^2);
        C2          = sqrt(a2^2 + b2^2);
        deltaCab    = C1 - C2;
        deltaHab    = sqrt(deltaA^2 + deltaB^2 + deltaCab^2);
        
        KL          = 2;
        KC          = 1;
        KH          = 1;
        K1          = 0.048;
        K2          = 0.014;
        
        SL          = 1;
        SC          = 1 + K1*C1;
        SH          = 1 + K2*C2;
        
        LL          = deltaL    / (KL * SL);
        AA          = deltaCab  / (KC * SC);
        BB          = deltaHab  / (KH * SH);
        
        out         = sqrt(LL^2 + AA^2 + BB^2);
    otherwise
        error('Unsupported version of deltae: %s', mat2str(deltaeversion));
end

