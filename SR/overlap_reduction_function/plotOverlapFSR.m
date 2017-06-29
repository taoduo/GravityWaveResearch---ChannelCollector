load('overlapH1H2-fsr.mat');
close all

% calculate exact and single pole fabry response
c = 299792458;
T1 = 3995.08/c;
T2 = T1/2;
w = 2 * pi * f;
s = i * w;

% exact fabry perot
q0 = 0.98584073941991; % taken from malik's param.m file
fp1 = (1 - q0)./(1 - q0 * exp(-2 * s * T1));
fp2 = (1 - q0)./(1 - q0 * exp(-2 * s * T2));

% include fp response in definition of overlap reduction function
Gamma12 = fp1.*conj(fp2).*o12; 

% make plots
figure(1)
subplot(3,2,1)
plot(f, sqrt(real(o11)), 'r');
xlabel('Frequency (Hz)');
ylabel('D_1(f)');
xlim([flow fhigh])
set(gca, 'XTick', [37320 37420 37520 37620 37720])
grid on

subplot(3,2,2)
plot(f, sqrt(real(o22)), 'r');
xlabel('Frequency (Hz)');
ylabel('D_2(f)');
xlim([flow fhigh])
set(gca, 'XTick', [37320 37420 37520 37620 37720])
grid on

subplot(3,2,3)
plot(f, real(o12), 'r')
xlabel('Frequency (Hz)');
ylabel('Re(\gamma_{12}(f))');
xlim([flow fhigh])
set(gca, 'XTick', [37320 37420 37520 37620 37720])
grid on

subplot(3,2,4)
plot(f, imag(o12), 'r')
xlabel('Frequency (Hz)');
ylabel('Imag(\gamma_{12}(f))');
xlim([flow fhigh])
set(gca, 'XTick', [37320 37420 37520 37620 37720])
grid on

subplot(3,2,5)
plot(f, real(Gamma12), 'r')
xlabel('Frequency (Hz)');
ylabel('Re(\Gamma_{12}(f))');
xlim([flow fhigh])
set(gca, 'XTick', [37320 37420 37520 37620 37720])
grid on

subplot(3,2,6)
plot(f, imag(Gamma12), 'r')
xlabel('Frequency (Hz)');
ylabel('Imag(\Gamma_{12}(f))');
xlim([flow fhigh])
set(gca, 'XTick', [37320 37420 37520 37620 37720])
grid on

print -depsc2 overlapH1H2-fsr
return
