function [EV, EF, FE]=make_edge_list(V,F)

nv=size(V,1);
nf=size(F,1);

I=[F(:,1);F(:,2);F(:,3)];
J=[F(:,2);F(:,3);F(:,1)];
S = [1:nf,1:nf,1:nf]';
locmatrix=[0 3 2;3 0 1; 2 1 0];

    
E = sparse(double(I),double(J),double(S)',nv,nv);
Elisto = [I,J];
sElist = sort(Elisto,2);
s = (sqrt(sum((Elisto - sElist).^2,2)) > 1e-6);
t = S.*(-1).^s;
[EV,une] = unique(sElist, 'rows');
EF = zeros(length(EV),4);
FE = zeros(nf,3);
for m=1:length(EV)
    i = EV(m,1); j = EV(m,2);
    t1 = t(une(m));
    t2 = -(E(i,j) + E(j,i) - abs(t1))*sign(t1);
    EF(m,1:2) = [t1, t2];
    f = F(abs(t1),:); loc = find(f == i | f==j);
    loc=locmatrix(loc(1),loc(2));
    FE(abs(t1),loc) = m*sign(t1);
    EF(m,3) = loc;
    if t2 ~= 0
        f = F(abs(t2),:); loc = find(f == i | f==j);
        loc=locmatrix(loc(1),loc(2));
        FE(abs(t2),loc) = m*sign(t2);
        EF(m,4) = loc;
    end
    if (EF(m, 1) <= 0) && (EF(m, 1) <= 0)  
        EF(m,1:2)=-EF(m,1:2);
        EV(m,1:2)=[j i];
    end
end
BoundEdges=(EF(:,1)==0 | EF(:,2)==0);
innerEdges=find(~BoundEdges);


%sorting boundary vertices
ne=length(EV);
nv=length(V);
boundEdges=setdiff((1:ne)', innerEdges);
nbe=length(boundEdges);
nie=length(innerEdges);

end