% Make up a model for TE mode
clc; clear; close all;

%% Backgroud
x = 0:5;
z = 0:5;
ep = 9*ones(length(x),length(z));
mu = ones(size(ep));
sig = 0.001*ones(size(ep));


dx = 0.02;
dz = 0.02;
x2 = min(x):dx:max(x);
z2 = min(z):dx:max(z);
ep = gridinterp(ep,x,z,x2,z2,'spline');
mu = gridinterp(mu,x,z,x2,z2,'spline');
sig = gridinterp(sig,x,z,x2,z2,'spline');
x = x2;
z = z2;

dt = 0.1e-9;

figure();
subplot(1,3,1); imagesc(x,z,ep'); axis image; title('\epsilon'); colorbar;
subplot(1,3,2); imagesc(x,z,mu'); axis image; title('\mu'); colorbar;
subplot(1,3,3); imagesc(x,z,sig'); axis image; title('\sigma'); colorbar;
saveas(gcf,'model_homo.png')
save('rtm_model.mat','ep','mu','sig','x','z','dx','dz','dt')


%% True Model
x0 = 4;
z0 = 2.5;
width = 2*dx;
len = 20*width;
k = [0, 1, -1, 1e20];
% k = 1e20;

for ii = 1:length(x)
    for ik = 1:length(z)
        if sqrt((x(ii) - x0)^2 + (z(ik) - z0)^2) <= len
            for idum=1:length(k)
                dd = abs(z(ik)- k(idum)*x(ii) - (z0-k(idum)*x0))/sqrt(1+k(idum)^2);
                if dd <= width
                    ep(ii, ik)  = 9;
                    sig(ii, ik) = 0.01;
                end
            end
        end
    end
end

figure();
subplot(1,3,1); imagesc(x,z,ep'); axis image; title('\epsilon'); colorbar;
subplot(1,3,2); imagesc(x,z,mu'); axis image; title('\mu'); colorbar;
subplot(1,3,3); imagesc(x,z,sig'); axis image; title('\sigma'); colorbar;
saveas(gcf,'model.png')
save('true_model.mat','ep','mu','sig','x','z','dx','dz','dt')



%%
srcx = [2.5];
srcz = [2.5];
% recx = [12];
% recz = srcz;
% srcx1 = 0:0.5:5;
% srcz1 = srcx1 .* 0;

% srcz2 = 0:0.5:z(end);
% srcx2 = srcz2 .* 0;

% srcx3 = 0:0.5:5;
% srcz3 = srcx3 .* 0 + 5;
% 
% srcz4 = 0:0.5:5;
% srcx4 = srcz4 .* 0 + 5;

% recx1 = 0:0.1:5;
% recz1 = recx1 .* 0;

recz2 = 0:0.1:z(end);
recx2 = recz2 .* 0 + 2.5;

% recx3 = 0:0.1:5;
% recz3 = recx3 .* 0 + 5;

% recz4 = 0:0.1:11;
% recx4 = recz4 .* 0 + 6;
% 
% srcx = [srcx1,srcx2,srcx3,srcx4];
% srcz = [srcz1,srcz2,srcz3,srcz4];
% recx = [recx1,recx2,recx3,recx4];
% recz = [recz1,recz2,recz3,recz4];

% srcx = [srcx2];
% srcz = [srcz2];
recx = [recx2]';
recz = [recz2]';
% srcx = [srcx1];
% srcz = [srcz1+0.5];
% recx = [recx3];
% recz = [recz3-0.5];
%(1=Ex, 2=Ez)
srctype = 2*ones(size(srcz));
rectype = 2*ones(size(recz));
srcloc = [srcx  srcz  srctype];
recloc = [recx  recz  rectype];

subplot(1,3,1)
hold on
plot(recloc(:,1), recloc(:,2), 'xr')
plot(srcloc(:,1), srcloc(:,2), '*y')
subplot(1,3,3)
hold on
plot(recloc(:,1), recloc(:,2), 'xr')
plot(srcloc(:,1), srcloc(:,2), '*y')

% save('src_rec.mat','srcx','srcz','recx','recz','x','z')
save('src_rec.mat','srcloc','recloc','x','z')

%%
Hz = 100e6;
T = 1/Hz * 10;
nsrc = length(srcloc(:,1));
t = 0:dt:T;
% signal=blackharrispulse(Hz,t);
signal = ricker(Hz, t);
srcpulse =repmat(signal,nsrc,1);
figure()
subplot(2,1,1)
plot(t, signal)
subplot(2,1,2)
imagesc(t,1:nsrc, srcpulse)
save('srcpulse.mat','srcpulse','t','srcloc')

%% Test dx, dz, dt
epmin = min(min(ep));
epmax = max(max(ep));
mumin = min(min(mu));
mumax = max(max(mu));
dtmax = finddt(epmin,mumin,dx,dz);

[dxmax,wlmin,fmax] = finddx(epmax,mumax,srcpulse,t,0.02);
disp(['Maximum frequency contained in source pulse = ',num2str(fmax/1e6),' MHz']);
disp(['Minimum wavelength in simulation grid = ',num2str(wlmin),' m']);
disp(['Maximum possible electric/magnetic field discretization (dx,dz) = ',num2str(dxmax),' m']);


disp(['Maximum possible time step with this discretization = ',num2str(dtmax/1e-9),' ns']);
disp(' ');
disp(['(dx, dz, dt) chosen: (',num2str(dx),' m, ',num2str(dz),' m, ',num2str(dt/1e-9),' ns)'])

if dt > dtmax
	disp('dt too big!!!');
	pause
end
if dx > dxmax
	disp('dx too big!!!');
	pause
end


