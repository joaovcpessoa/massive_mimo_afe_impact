function [ H,HMean] = channel_generation( R,HMeanWithoutPhase,M,nbrOfRealizations,K)
 
H=zeros(M,nbrOfRealizations,K); 
W = (randn(M,nbrOfRealizations,K)+1i*randn(M,nbrOfRealizations,K));

HMean=zeros(M,nbrOfRealizations,K); 
HMeanx=reshape(repmat(HMeanWithoutPhase,nbrOfRealizations,1),M,nbrOfRealizations,K); 

angles= -pi + 2*pi*rand(M,nbrOfRealizations,K);
phaseMatrix=exp(1i*angles);
  
    for k = 1:K
        
        HMean(:,:,k)= phaseMatrix(:,:,k).*HMeanx(:,:,k);
        Rsqrt = sqrtm(R(:,:,k));
        H(:,:,k) = sqrt(0.5)*Rsqrt*W(:,:,k) + HMean(:,:,k);
       
    end
    
end
