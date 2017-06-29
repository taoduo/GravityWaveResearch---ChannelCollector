function [theta,phi] = healpix2ang(pixelfile)

data = load(pixelfile);
theta = data(:,1);
phi = data(:,2);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% number of pixels
fprintf('Number of pixels = %d\n',length(theta));

% plot points
figure(1)
plot(phi, theta, '*');
xlim([0 2*pi])
ylim([0 pi])
xlabel('phi')
ylabel('theta')

figure(2)
x=sin(theta).*cos(phi);
y=sin(theta).*sin(phi);
z=cos(theta);
plot3(x,y,z,'+b');

return
