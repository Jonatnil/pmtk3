function mixGaussImputationDemo()

%% Make data
setSeed(1);
d = 10; n = 100; pcMissing = 0.5;

K = 5;
mu = rand(d,K); mixweight = normalize(rand(1,K));
Sigma = zeros(d,d,K);
for k=1:K
  Sigma(:,:,k) = randpd(d);
end
trueModel = struct('K', K, 'mu', mu, 'Sigma', Sigma, 'mixweight', mixweight);
[Xfull] = mixGaussSample(trueModel, n);

missing = rand(n,d) < pcMissing;
Xmiss = Xfull;
Xmiss(missing) = NaN;


%% Impute

% GMM
[modelK] = mixGaussMissingFitEm(Xmiss, K);
[XimputeEMK] = mixGaussImpute(modelK, Xmiss);

% Check that a mixture of 1 Gaussian is equivalent to a single Gaussian
[model1] = mixGaussMissingFitEm(Xmiss, 1);
[XimputeEM1] = mixGaussImpute(model1, Xmiss);

[modelG] = gaussMissingFitEm(Xmiss);
[XimputeEMG] = gaussImpute(modelG, Xmiss);

% Oracle
[XimputeTruth] = mixGaussImpute(trueModel, Xmiss); 

% Heuristic
[XimputeMV, mu] = meanValueImputation(Xmiss);

% Scatter plots
doPlot(Xmiss, Xfull, XimputeTruth, 'true params', 'gmmImputeScatterTruth')
doPlot(Xmiss, Xfull, XimputeEMK, sprintf('em gmm(%d)',K), 'gmmImputeScatterEmK')
doPlot(Xmiss, Xfull, XimputeEM1, 'em gmm(1)', 'gmmImputeScatterEm1')
doPlot(Xmiss, Xfull, XimputeEMG, 'em gauss', 'gmmImputeScatterEmG')
doPlot(Xmiss, Xfull, XimputeMV, 'mean value imputation', 'gmmImputeScatterMV')
end


function doPlot(Xmiss, Xfull, Ximpute, ttl, fname)

figure; nr = 2; nc = 2;
for j=1:(nr*nc)
  subplot(nr, nc, j);
  miss = find(isnan(Xmiss(:,j)));
  scatter(Xfull(miss, j), Ximpute(miss,j))
  xlabel('truth'); ylabel('imputed');
  mini = min(Xfull(:,j)); maxi = max(Xfull(:,j));
  line([mini maxi], [mini maxi]);
  %axis square
  %grid on
   stats = regstats(Xfull(miss,j), Ximpute(miss,j));
  r = stats.rsquare;
  title(sprintf('R^2 = %5.3f', r))
end
suptitle(ttl)
printPmtkFigure(fname);
end




