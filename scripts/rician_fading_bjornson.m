% ####################################################################### %
%% LIMPEZA
% ####################################################################### %

clear;
close all;
clc;

% ####################################################################### %
%% PARÂMETROS PRINCIPAIS
% ####################################################################### %

M=40:20:100;     % Antenas
K=40;            % Usuários 
tau_p=5;         % Comprimento dos pilotos
tau_c=200;       % Tamanho do bloco de coerência
cellRange=1000;  % Tamanho da célula em metros (1km x 1km)

noiseFigure = 7; % Figura de ruído (dB)
B=20e6;          % Largura de banda (Hz)

noiseVariancedBm = -174 + 10*log10(B) + noiseFigure;
sigma2=db2pow(noiseVariancedBm-30); % Potência de ruído em Watts

p=0.2;          % Potência de transmissão uplink por UE em Watts (200mW)
pv=p*ones(1,K); % Vetor com a potência para todos os UEs

nbrOfSetups=50;        % Número de configurações de APs/UEs
nbrOfRealizations=5e2; % Número de realizações de canal por configuração

% ####################################################################### %
%% ALOCANDO MEMÓRIA
% ####################################################################### %

% Single-layer decoding
% Prepare to save simulation results for Theoretical and Monte-Carlo
% MR for Monte-Carlo and CC for theoretical
sumSE_MR_MMSE= zeros(length(M),nbrOfSetups);
sumSE_CC_MMSE= zeros(length(M),nbrOfSetups);
sumSE_MR_LMMSE= zeros(length(M),nbrOfSetups);
sumSE_CC_LMMSE= zeros(length(M),nbrOfSetups);
sumSE_MR_LS= zeros(length(M),nbrOfSetups);
sumSE_CC_LS= zeros(length(M),nbrOfSetups);

% Two-layer decoding
% Prepare to save simulation results for Theoretical and Monte-Carlo
sumSE_MR_MMSE_LSFD= zeros(length(M),nbrOfSetups);
sumSE_CC_MMSE_LSFD= zeros(length(M),nbrOfSetups);
sumSE_MR_LMMSE_LSFD= zeros(length(M),nbrOfSetups);
sumSE_CC_LMMSE_LSFD= zeros(length(M),nbrOfSetups);
sumSE_MR_LS_LSFD= zeros(length(M),nbrOfSetups);
sumSE_CC_LS_LSFD= zeros(length(M),nbrOfSetups);

% ####################################################################### %
%% TRANSMISSÃO E RECEPÇÃO
% ####################################################################### %

% Go through the number of APs
for m=1:length(M)
    
    % Distribui as antenas aleatoriamente dentro da célula, usando coordenadas complexas.
    APpositions=cellRange*(rand(M(m),1) + 1i*rand(M(m),1));
    
    % Para decodificação de camada única, defina todos os coeficientes de desvanecimento em larga escala como 1
    A_singleLayer=reshape(repmat(eye(M(m)),1,K),M(m),M(m),K);
    
    for n=1:nbrOfSetups
      
       % Implantar usuários e gerar as matrizes de covariância e média
       [R,HMeanWithoutPhase,channelGain] = functionCellFreeSetup( M(m),K,cellRange,APpositions,sigma2,1);
       
       % Crie gerações de canais para cada par Usuário-Antena
       [H,HMean] = functionChannelGeneration( R,HMeanWithoutPhase,M(m),nbrOfRealizations,K );
       
       % Pilot allocation 
       [Pset] = functionPilotAllocation( R,HMeanWithoutPhase,A_singleLayer,K,M(m),pv,tau_p);
       
       % Second Layer Decoding
       % Generate Large-scale fading coefficients for phase-aware MMSE,
       % Linear MMSE and LS estimators
       [ A_MMSE,A_LMMSE,A_LS] = functionLSFD( R,HMeanWithoutPhase,M(m),K,pv,tau_p,Pset);
       
       % Channel estimation 
       % Channel estimation with phase-aware MMSE estimator
       [Hhat_MMSE] =functionCellFreeMMSE(R,HMean,H,nbrOfRealizations,M(m),K,pv,tau_p,Pset);
       % Channel estimation with LMMSE estimator
       [Hhat_LMMSE] =functionCellFreeLMMSE(R,HMeanWithoutPhase,H,nbrOfRealizations,M(m),K,pv,tau_p,Pset);
       % Channel estimation with LS estimator
       [Hhat_LS] = functionCellFreeLS( H,nbrOfRealizations,M(m),K,pv,tau_p,Pset);      
       
       %Second layer decoding Spectral Efficiency (SE) computation
       %SE with MMSE estimator
       [SE_MR_MMSE_LSFD ]= functionMonteCarloSE_UL(Hhat_MMSE,H,A_MMSE,tau_c,tau_p,nbrOfRealizations,M(m),K,pv);
       [SE_CC_MMSE_LSFD] = functionTheoreticalCellFreeULSE_MMSE( R,HMeanWithoutPhase,A_MMSE,M(m),K,pv,tau_p,tau_c,Pset);
       
       %SE with LMMSE estimator
       [SE_MR_LMMSE_LSFD ]= functionMonteCarloSE_UL(Hhat_LMMSE,H,A_LMMSE,tau_c,tau_p,nbrOfRealizations,M(m),K,pv);
       [SE_CC_LMMSE_LSFD] = functionTheoreticalCellFreeULSE_LMMSE( R,HMeanWithoutPhase,A_LMMSE,M(m),K,pv,tau_p,tau_c,Pset);
      
       %SE with LS estimator
       [SE_MR_LS_LSFD ]= functionMonteCarloSE_UL(Hhat_LS,H,A_LS,tau_c,tau_p,nbrOfRealizations,M(m),K,pv);
       [SE_CC_LS_LSFD] = functionTheoreticalCellFreeULSE_LS( R,HMeanWithoutPhase,A_LS,M(m),K,pv,tau_p,tau_c,Pset);
       
       %One-layer decoding
       %SE with MMSE estimator LSFD coefficients are set to 1
       [SE_MR_MMSE ]= functionMonteCarloSE_UL(Hhat_MMSE,H,A_singleLayer,tau_c,tau_p,nbrOfRealizations,M(m),K,pv);
       [SE_CC_MMSE] = functionTheoreticalCellFreeULSE_MMSE( R,HMeanWithoutPhase,A_singleLayer,M(m),K,pv,tau_p,tau_c,Pset);
       
       %SE with LMMSE estimator LSFD coefficients are set to 1
       [SE_MR_LMMSE]= functionMonteCarloSE_UL(Hhat_LMMSE,H,A_singleLayer,tau_c,tau_p,nbrOfRealizations,M(m),K,pv);
       [SE_CC_LMMSE] = functionTheoreticalCellFreeULSE_LMMSE( R,HMeanWithoutPhase,A_singleLayer,M(m),K,pv,tau_p,tau_c,Pset);
       
       %SE with LS estimator LSFD coefficients are set to 1
       [SE_MR_LS]= functionMonteCarloSE_UL(Hhat_LS,H,A_singleLayer,tau_c,tau_p,nbrOfRealizations,M(m),K,pv);
       [SE_CC_LS] = functionTheoreticalCellFreeULSE_LS( R,HMeanWithoutPhase,A_singleLayer,M(m),K,pv,tau_p,tau_c,Pset);

       %Average of all users 
       %One layer
       sumSE_MR_MMSE(m,n) = mean(SE_MR_MMSE,1);
       sumSE_CC_MMSE(m,n) = mean(SE_CC_MMSE,1);
       sumSE_MR_LMMSE(m,n) = mean(SE_MR_LMMSE,1);
       sumSE_CC_LMMSE(m,n) = mean(SE_CC_LMMSE,1);
       sumSE_MR_LS(m,n) = mean(SE_MR_LS,1);
       sumSE_CC_LS(m,n) = mean(SE_CC_LS,1);
       %Second layer
       sumSE_MR_MMSE_LSFD(m,n) = mean(SE_MR_MMSE_LSFD,1);
       sumSE_CC_MMSE_LSFD(m,n) = mean(SE_CC_MMSE_LSFD,1);
       sumSE_MR_LMMSE_LSFD(m,n) = mean(SE_MR_LMMSE_LSFD,1);
       sumSE_CC_LMMSE_LSFD(m,n) = mean(SE_CC_LMMSE_LSFD,1);
       sumSE_MR_LS_LSFD(m,n) = mean(SE_MR_LS_LSFD,1);
       sumSE_CC_LS_LSFD(m,n) = mean(SE_CC_LS_LSFD,1);
       
    %Output simulation progress
    disp([num2str(n) ' setups out of ' num2str(nbrOfSetups)]);
    end
   clear R HMean Hhat_MMSE Hhat_LMMSE Hhat_LS
   %Output simulation progress
   disp([num2str(M(m)) ' APs out of ' num2str(M(end))]);
end

% Plot simulation results
figure;
m1=plot(M,mean(sumSE_MR_MMSE,2),'ks');
hold on
c1=plot(M,mean(sumSE_CC_MMSE,2),'k-+');
hold on
plot(M,mean(sumSE_MR_LMMSE,2),'ks');
hold on
c2=plot(M,mean(sumSE_CC_LMMSE,2),'k-x');
hold on
plot(M,mean(sumSE_MR_LS,2),'ks');
hold on
c3=plot(M,mean(sumSE_CC_LS,2),'k-o');
hold on
plot(M,mean(sumSE_MR_MMSE_LSFD,2),'rs');
hold on
plot(M,mean(sumSE_CC_MMSE_LSFD,2),'r-+');
hold on
plot(M,mean(sumSE_MR_LMMSE_LSFD,2),'rs');
hold on
plot(M,mean(sumSE_CC_LMMSE_LSFD,2),'r-x');
hold on
plot(M,mean(sumSE_MR_LS_LSFD,2),'rs');
hold on
plot(M,mean(sumSE_CC_LS_LSFD,2),'r-o');
xlabel('Number of APs, M');
ylabel('Average UL sum SE [bit/s/Hz]');
legend([c1 c2 c3 m1],'MMSE','LMMSE','LS','Monte-Carlo','Location','Northwest')