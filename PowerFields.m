clc
close all
clear all

dataFolder = ['..' filesep 'data'];

%change this for different meshes
filename = 'bumpy-cube';

[V,F, ~,~] = readObj([dataFolder filesep filename '.obj']);
%V - list of vertex coordinates, in row xyz format
%F - list of faces indices where each row is *oriented* indices into V

[EV, EF, FE]=make_edge_list(V,F);
%   EV: a list of edges where in each row there are [source, target] indices inside V
%   EF: a *signed* list, corresponding to EV, where the first two columns are the left and right faces, 
%   with the sign marking orientation vs. the edge (you can abs() if you don't need it, and the third and 
%   fourth columns are the location of the edge in the face (not necessary for this exercise).
%   %FE: correponsing to F, a signed (with orientation) list of edges in
%   each faces, where edge i is the one in front of vertices (i+1,i+2)
%   (modulo 3) in that face.


%%%%%%%%%%%%%%%%%%%%%%%%%%Warmup exercise: Compute normals and local bases%%%%%%%%%%%%%

%TODO: you should compute these quantities, and replaces the "zeros" stubs (which
%is are of the correct size)

normals = zeros(length(F),3);    %normalized normal to each face
triAreas = zeros(length(F),1);   %triangle ares
B1 = zeros(length(F),3);         %(B1,B2) local bases for each triangle, where (B1,B2,normals) are local right-handed orthonormal bases
B2 = zeros(length(F),3);

faceCenters = (V(F(:,1),:)+V(F(:,2),:)+V(F(:,3),:))/3;
averageEdgeLength = mean(normv(V(EV(:,1),:)-V(EV(:,2),:)),1);


%Visualizing basis and normals
figure
hold on
patch('faces', F, 'vertices', V,  'faceColor', 'white', 'edgeColor', 'none'); axis equal; cameratoolbar;
title('Mesh Normals (red) and tangent basis (blue)');
axis equal; cameratoolbar;
NSource = faceCenters;
NTarget = faceCenters + averageEdgeLength*normals/3;
PlotVectors(NSource, NTarget, 'r');
B1Source = faceCenters;
B1Target = faceCenters + averageEdgeLength*B1/3;
PlotVectors(B1Source, B1Target, 'b');
B2Source = faceCenters;
B2Target = faceCenters + averageEdgeLength*B2/3;
PlotVectors(B2Source, B2Target, 'b');


%%%%%%%%%%%%%%%%%%%%%%%%%%Section 1: Power-field interpolation%%%%%%%%%%%%%%%%%%%%%%%%%

N=4; %The order of the field (#vectors per face); user parameter.
constFaces = [1;250];   %the indices (into F) of the constrained faces; user parameter
constRawField = B1(constFaces,:);   %the constrained vectors of the constrained faces; given in raw 3d xyz form.
freeFaces = setdiff((1:length(F))', constFaces);

%TODO: compute the lhs and rhs matrices to solve the power-field
%interpolation from constraints, and put the results in fullPowerField.
%You should use the weight matrix as taught in class, and construct the
%dchi operator that encodes the face-to-face differences wrt. local bases,
%encoding the discrete connection.

constPowerField = zeros(length(constFaces), 1); %put in the power representation of the constraints
freePowerField = zeros(length(freeFaces),1);  %should be "lhs\rhs" once you generate them.
fullPowerField = zeros(length(F),1);
fullPowerField(freeFaces) = freePowerField;
fullPowerField(constFaces) = constPowerField;

%getting the roots (as a single representator of the set)
fullComplexField = fullPowerField.^(1/N);
%normalizing field
fullComplexField=fullComplexField./abs(fullComplexField);

%visualizing result
freeFacesMask = zeros(length(F),1);
freeFacesMask(constFaces)=1;
figure
hold on
patch('faces', F, 'vertices', V,  'faceColor', 'flat', 'CData', freeFacesMask, 'edgeColor', 'none'); axis equal; cameratoolbar;
title('N-Field on mesh. In yellow: constrained faces');
for i=1:N
    %this generates all the roots by i*pi/N rotations from each the
    %original.
    currRawField = B1.*real(fullComplexField*exp(complex(0,2*i*pi/N)))+B2.*imag(fullComplexField*exp(complex(0,2*i*pi/N)));
    fieldSource = faceCenters;
    fieldTarget = faceCenters + averageEdgeLength*currRawField/3;
    PlotVectors(fieldSource, fieldTarget, 'g');
end











