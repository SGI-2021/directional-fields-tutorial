
%%%%%%%%%%%%%%%Section 2: Principal matching and singularities%%%%%%%%%%%%%

%TODO: create the basis-cycle matrix d0

eulerChar = length(V)-length(EV)+length(F);

K = GaussCurvature(V,F,EV);

%plotting Gaussian curvature
figure
hold on
patch('faces', F, 'vertices', V,  'faceColor', 'interp', 'CData', K); axis equal; cameratoolbar;
title('Gaussian Curvature');
axis equal; cameratoolbar;

%TODO: compute the edge-based effort of the complex field.
effort = zeros(length(EV),1);

%TODO: compute the vertex-based indices according to the effort and the
%basis-cycles matrix.
indices = rand(length(V),1);  %using rand() so that it triggers the indicesIntegerError...

%confidence check: indices are integer
indicesIntegerError = max(abs(indices - round(indices)))
indices = round(indices);

%Confidence check: indices add up to the Euler char
indicesSumError = sum(indices)/N - eulerChar

%classifying indices
posSings = find(indices>0);
negSings = find(indices<0);

figure
hold on
patch('faces', F, 'vertices', V,  'faceColor', 'w', 'edgeColor', 'none'); axis equal; cameratoolbar;
for i=1:N
    %this generates all the roots by i*pi/N rotations from each the
    %original.
    currRawField = B1.*real(fullComplexField*exp(complex(0,2*i*pi/N)))+B2.*imag(fullComplexField*exp(complex(0,2*i*pi/N)));
    fieldSource = faceCenters;
    fieldTarget = faceCenters + averageEdgeLength*currRawField/3;
    PlotVectors(fieldSource, fieldTarget, 'b');
end
axis equal; cameratoolbar;
plot3(V(posSings,1), V(posSings,2), V(posSings,3), '.g', 'MarkerSize', 30);
plot3(V(negSings,1), V(negSings,2), V(negSings,3), '.r', 'MarkerSize', 30);
title('Singularity indices. Green is +1/N, red is -1/N');











