function PlotVectors(source, target, color)
quiver3(source(:,1), source(:,2), source(:,3), target(:,1)-source(:,1), target(:,2)-source(:,2), target(:,3)-source(:,3),0, 'LineWidth', 2,'Color', color);
end