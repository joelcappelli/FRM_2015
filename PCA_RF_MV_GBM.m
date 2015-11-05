function sim_dRFs = PCA_RF_MV_GBM(dRFs,numSims,power)

covarRFs = cov(dRFs);
[u,d,~] = svd(covarRFs,0);

eigVals = diag(d);
eigVecs = u;
energyContent = cumsum(eigVals);
propEnergyContent = energyContent./energyContent(end);
%find how many PCs to extract input explanatory power
% power = [0, 1]
index = min(find(propEnergyContent >= power));
eigVecsPCs = eigVecs(:,1:index);
eigenValsPCs = diag(sqrt(eigVals(1:index)));
Q = eigenValsPCs*eigVecsPCs';
%standard norm sampling
eps = randn(numSims, size(eigenValsPCs,1));
sim_dRFs = transpose(eps*Q);

end