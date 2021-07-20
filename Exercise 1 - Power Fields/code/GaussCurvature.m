function K = GaussCurvature(V,F,EV)

%TODO: compute vertex-based discrete Gaussian curvature as taught in class

%TODO: compute corner angles, where (1,2,3) index per-face corners
angle312 = zeros(length(F),1);
angle123 = zeros(length(F),1);
angle231 = zeros(length(F),1);

%Confidence check: angles add up to pi in every single face
angleError = max(abs(angle312+angle123+angle231)-pi)

%TODO: Computing Gaussian curvature by accumarray on the face indices
K = zeros(length(V),1);

%Confidence check: Gaussian Curvature sums up to the (2pi*) Euler characteristic
eulerChar = length(V)-length(EV)+length(F);
angleDefectError = abs(sum(K)-2*pi*eulerChar)

end