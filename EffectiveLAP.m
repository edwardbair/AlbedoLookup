function lap=EffectiveLAP(deltavis,rg,mu0,Z,varargin)
%solve for effective lap concentration of dust (ppmw) given deltavis
%only scalar input/output
%you must run this in a loop for images, cubes, etc
%inputs, all scalars
%deltavis, 0 to 0.40, expressed as a fraction, eg 0.05
%rg - grain radius, um, 30-1800 um, e.g. 500
%mu0 - solar zenith 0-1, e.g. 0.6
%Z - altitude in km of snowcover, 0 to 8 km, e.g. 3.5
%optional
% LAPname - 'dust'  is the default, but can be changed to 'soot'
% LUT - logical, use lookup table table? default is true

%output
% lap - LAP concentration (dust or soot) in ppm

persistent already S

narginchk(4,8)

%load lookup table
if isempty(already) || ~already
    already = true;
    S = load('EffectiveLAPLUT.mat');
end
Fdust = S.Fdust;
Fsoot = S.Fsoot;
    
p=inputParser;
addRequired(p,'deltavis',@(x) isnumeric(x) && (x>=0) && (x<=0.40))
addRequired(p,'rg',@(x) isnumeric(x) && (x>=30) && (x<=1800))
addRequired(p,'mu0',@(x) isnumeric(x) && (x>=0) && (x<=1))
addRequired(p,'Z',@(x) isnumeric(x) && (x>=0) && (x<=8))
addOptional(p,'LAPname','dust',@(x) isempty(x) ||...
    (ischar(x) && (strcmpi(x,'soot') || strcmpi(x,'dust'))))
addOptional(p,'LUT',true,@(x) isempty(x) || islogical(x))
parse(p,deltavis,rg,mu0,Z,varargin{:})


if p.Results.LUT % if use a LUT
    if isempty(p.Results.LAPname)
        F=Fdust; %use dust
    else
        switch lower(p.Results.LAPname)
            case 'dust'
                F=Fdust;
            case 'soot'
                F=Fsoot;
        end
    end
    lap=F(deltavis,rg,mu0,Z);
else %if no LUT
    lapname=p.Results.LAPname;
    x1=0;
    switch lapname
        case 'dust'
         x2=1000; %ppm 
        case 'soot'
         x2=50; %ppm
    end
    lap=fminbnd(@ADiff,x1,x2);
end

%find the rms difference of clean-dirty snow, varying only dust conc
%return the "lap", i.e. effective dust concentration
    function y=ADiff(x)
        dvp=0.63; %Portion of the spectrum that deltavis encompasses.
        %Note that deltavis is not properly named as it includes nIR region
        % 0.350 to 0.876 um
        %Bair et al 2019 WRR

        dv=AlbedoLookup(rg,mu0,Z)-AlbedoLookup(rg,mu0,Z,lapname,x*1e-6);
        y=sqrt((dv-dvp.*deltavis).^2);
    end

end
