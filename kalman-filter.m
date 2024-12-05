clc;
clear all;
format long;
tic;

%% Data yang digunakan
data = readtable("data_TA.xlsx");
a = data.aktual;
b = data.trans2;
c = data.residual;
d = data.stepFunction;
e = data.stasioner;
f = data.forecast;

% Tahap inisialisasi
n = length(a);

% Tahap inisalisasi
q_0 = 10^(-3);
Q_0 = eye(6)*q_0;             % Nilai awal Q
r_0 = 10^(-3);
R_0 = eye(6)*r_0;             % Nilai awal R
x_0 = [-0.51039 0.41034 247.90810 27.46528 0.1 3.32443]';  % Nilai awal x
P_0 = eye(6)*(10^(-3));                           % Nilai awal P

H = [0 0 0 0 0 1];                % Matriks H 
B = [0; 0; 0; 0; 0; 1];             % Matriks B 
I = eye(6);                   % Matriks Identitas 

x0kf = x_0;
xtot0 = x_0;
xsist0 = x_0;
x0sist = x_0;

for t=56:n
    A = [1 0 0 0 0 0;            % Matriks A 
         0 1 0 0 0 0;
         0 0 1 0 0 0;
         0 0 0 1 0 0;
         0 0 0 0 1 0;
         (b(t-1)-b(t-2)) -c(t-1) d(t-1) d(t-2) d(t-3) 0]; 
    z = e(t);                % Model Pengukuran
    ut = c(t);               % Error

    % Tahap prediksi
    x_hat = A*x0kf+B*ut;                   
    p_hat = (A*P_0*A') + (Q_0);

    % Tahap koreksi
    Kalmgain = p_hat*H'*(inv((H*p_hat*H')+r_0));
    P_koreksi = (I-Kalmgain*H)*p_hat;
    x_kor = x_hat+Kalmgain*(z-(H*x_hat));

    x0kf = x_kor;
    P_0 = P_koreksi;

    xtot = [xtot0 x_kor];
    xtot0=xtot;
end
%% Hasil
hasil = strcat('Nilai Yt = ', num2str(xtot(6,:)));
disp(hasil);

Zt0 = 0;
for t = 1:3
    t;
    b(t+53);
    Zt = xtot(6,t)+b(t+53); 
    Mt = sqrt(Zt);
    Wt = exp(Mt);
    Zttot = [Zt0 Wt];
    Zt0 = Zttot;
end
hasil2 = strcat(['Hasil prediksi menggunakan Analisis ' ...
    'Intervensi-Kalman Filter: '],num2str(Zttot(1,2:4)));
disp(hasil2);
%% Plot Aktual dan Analisis Intervensi
figure(1)
hold on
plot(a(55:57),'b','LineWidth',1)
plot(f(55:57),'r','LineWidth',1)
xticks([1 2 3])
xticklabels({'1','2','3'})
title(['Plot Nilai Prediksi Model Analisis Intervensi dan Data Out-Sample'])
legend('Aktual','Analisis Intervensi')
xlabel('Data ke-')
ylabel('Jumlah Proyek PMA Sektor Pertambangan')
%% Plot Aktual, Analisis Intervensi, dan Analisis Intervensi-Kalman Filter
figure(2)
hold on
plot(a(55:57),'b','LineWidth',1) 
plot(f(55:57),'r','LineWidth',1) 
plot(Zttot(1,2:4),'g','LineWidth',1)
xticks([1 2 3])
xticklabels({'1','2','3'})
title(['Plot Nilai Prediksi Model Analisis Intervensi, ' ...
    'Analisis Intervensi-Kalman Filter, dan Data Out-Sample'])
legend('Aktual','Analisis Intervensi','Analisis Intervensi−Kalman Filter')
xlabel('Data ke-')
ylabel('Jumlah Proyek PMA Sektor Pertambangan')
%% Perhitungan MAPE
aa(1) = 0;
bb(1) = 0;
for t=1:3
    %%% Persamaan MAPE Analisis Intervensi
    apl(t)=(abs(a(t+54)-f(t+54))/a(t+54))*100;
    aa(t+1)=apl(t)+aa(t);
    %%% Persamaan MAPE Analisis Intervensi-Kalman Filter
    ape(t)=(abs(a(t+54)-Zttot(1,t+1))/a(t+54))*100;
    bb(t+1)=ape(t)+bb(t);
    %%% Persamaan Absolute Error
    AE_AI(t,1)=abs(a(t+54)-f(t+54));
    AE_KF(t,1)=abs(a(t+54)-Zttot(1,t+1));
end
mape_aikf=bb(t+1)/3;    % MAPE Analisis Intervensi-Kalman Filter
mape_ai=aa(t+1)/3;  % MAPE Analisis Intervensi
mapeINTV=strcat('MAPE Analisis Intervensi (%): ',num2str(mape_ai));
mapeKF=strcat('MAPE Analisis Intervensi-Kalman Filter (%): ',num2str(mape_aikf));
disp(mapeINTV)
disp(mapeKF)

%% Plot Error
dataAsli=a(55:57);
dataIntv = f(55:57);
Kalfil=Zttot(1,2:4)';
AI=abs(dataAsli-dataIntv);
KFer=abs(dataAsli-Kalfil);

figure(3)
hold on
plot(AI,'-r','LineWidth',1)
plot(KFer,'-g','LineWidth',1)
xticks([1 2 3])
xticklabels({'1','2','3'})
title(['Plot Nilai Error Hasil Simulasi Estimasi Data Out-Sample Jumlah Proyek PMA ' ...
    'Sektor Pertambangan'])
legend('Analisis Intervensi', 'Analisis Intervensi Kalman-Filter')
xlabel('Data ke-')
ylabel('Error')
