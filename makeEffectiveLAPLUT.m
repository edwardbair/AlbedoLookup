
mu0=linspace(0.05,1,13);
Z=linspace(0,8,8);
rg=linspace(0.03,1.8,51)*1e3;
deltavis=linspace(0,0.4,50);

[w,x,y,z]=ndgrid(deltavis,rg,mu0,Z);
lap=nan(length(deltavis),length(rg),length(mu0),length(Z));

for ii=1:2
    switch ii
        case 1
            lapname='dust';
        case 2
            lapname='soot';
    end
    for i=1:length(mu0)
        for j=1:length(Z)
            for k=1:length(rg)
                parfor kk=1:length(deltavis)
                    X=EffectiveLAP(deltavis(kk),rg(k),mu0(i),Z(j),lapname)
                    X(X<1)=0;
                    lap(kk,k,i,j)=X;
                end
                fprintf('done with %i %i %i %i\n',ii,i,j,k);
            end
        end
    end
    F=griddedInterpolant(w,x,y,z,lap,'makima','nearest');
    switch ii
        case 1
            Fdust=F;
        case 2
            Fsoot=F;
    end
end



