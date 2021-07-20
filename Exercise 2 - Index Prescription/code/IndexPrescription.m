clc
close all
clear all

dataFolder = ['..' filesep 'data'];

%change this for different meshes
filename = 'elephant';

[V,F, ~,~] = readObj([dataFolder filesep filename '.obj']);

[EV, EF, FE]=make_edge_list(V,F);


%%%%%%%%%%%%%%%%%%%%%%%%%%Copy-paste from Exercise #1: Compute normals and local bases%%%%%%%%%%%%%

%TODO: you should compute these quantities, and replaces the "zeros" stubs (which
%is are of the correct size)

normals = zeros(length(F),3);    %normalized normal to each face
triAreas = zeros(length(F),1);   %triangle ares
B1 = zeros(length(F),3);         %(B1,B2) local bases for each triangle, where (B1,B2,normals) are local right-handed orthonormal bases
B2 = zeros(length(F),3);

faceCenter = (V(F(:,1),:)+V(F(:,2),:)+V(F(:,3),:))/3;
averageEdgeLength = mean(normv(V(EV(:,1),:)-V(EV(:,2),:)),1);

K = GaussCurvature(V,F, EV);
eulerChar = length(V)-length(EV)+length(F);
if (eulerChar~=2)
    warning('Warning: the mesh either has boundary loops or high genus and the current implementation would yield unexpected results!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%Section 1: Solving for the effort%%%%%%%%%%%%%%%%%

%user parameters - play with them (up to consistency...)
N=2;
presVertices = randi([1,length(V)], 2*N+3*eulerChar,1);
presIndices=zeros(length(V),1);
presIndices(presVertices)=[ones(2*N,1); 2*ones(eulerChar,1); -ones(2*eulerChar,1)]/N;

d0 = sparse(repmat((1:length(EV))', 1,2), EV, [-ones(length(EV),1), ones(length(EV),1)], length(EV), length(V));

%Confidence check: prescribed indices add up correctly to the Euler
%characteristic.
indexPresError = sum(presIndices)-eulerChar

%TODO: assemble and compute the Poisson system to compute the effort
%potential psi, and consequently the effort.

effort =zeros(length(EV),1);

%Confidence check: effort adds up.
effortError = max(abs(d0'*effort - (2*pi*N*presIndices-N*K)))

%%%%%%%%%%%%%%%%%%%%%%%Section 2: reconstructing the field%%%%%%%%%%%%%%

constFaces = [100];  %if you add more than one, the system will be solvable, but not have zero error.
constRawField = B1(constFaces,:);
freeFaces = setdiff((1:length(F))', constFaces);

%converting to power representation
constComplexField = complex(dot(constRawField, B1(constFaces,:),2), dot(constRawField, B2(constFaces,:),2));
constPowerField = constComplexField.^N;

%TODO: assemble the reconstruction system (a variant on the one from
%exercise #1, but with the prescribed effort), and solve for freePowerField

%solving the system
constPowerField = zeros(length(constFaces), 1); %TODO: put in the power representation of the constraints
freePowerField = zeros(length(freeFaces),1);  %TODO: should be "lhs\rhs" once you generate them.
fullPowerField = zeros(length(F),1);
fullPowerField(freeFaces) = freePowerField;
fullPowerField(constFaces) = constPowerField;

%TODO: uncomment this once you assemble the lhs and ehs to check there is no LS
%error.
%fieldFromEffortError = max(abs(lhs*freePowerField-rhs))

%%%%%%%%The same visualization procedure from excercise #1 (with possibility for more indices%%%%%%%

%getting the roots (as a single representator
fullComplexField = fullPowerField.^(1/N);
%normalizing field
fullComplexField=fullComplexField./abs(fullComplexField);

%visualizing result
posSings1 = find(N*presIndices==1);
posSings2 = find(N*presIndices==2);
negSings1 = find(N*presIndices==-1);

figure
hold on
patch('faces', F, 'vertices', V,  'faceColor', 'w', 'edgeColor', 'none'); axis equal; cameratoolbar;
for i=1:N
    %this generates all the roots by i*pi/N rotations from each the
    %original.
    currRawField = B1.*real(fullComplexField*exp(complex(0,2*i*pi/N)))+B2.*imag(fullComplexField*exp(complex(0,2*i*pi/N)));
    fieldSource = faceCenter;
    fieldTarget = faceCenter + averageEdgeLength*currRawField/3;
    PlotVectors(fieldSource, fieldTarget, 'b');
end
axis equal; cameratoolbar;
plot3(V(posSings1,1), V(posSings1,2), V(posSings1,3), '.g', 'MarkerSize', 30);
plot3(V(posSings2,1), V(posSings2,2), V(posSings2,3), '.y', 'MarkerSize', 30);
plot3(V(negSings1,1), V(negSings1,2), V(negSings1,3), '.r', 'MarkerSize', 30);
title('Singularity indices. Green is +1/N, red is -1/N');




