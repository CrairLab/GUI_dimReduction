function [clst_labels, clst_centers, K_old, bic_after_split] = XMeans(X, kmax, max_iter)
%Scripts translated from https://github.com/alex000kim/XMeans/blob/master/xmeans.py
%Implementation of XMeans algorithm based on
%Pelleg, Dan, and Andrew W. Moore. "X-means: Extending K-means with Efficient Estimation of the Number of Clusters."
%ICML. Vol. 1. 2000.
%https://www.cs.cmu.edu/~dpelleg/download/xmeans.pdf
    
    %Start with K = 1
    K = 1;
    K_sub = 2;
    K_old = K;
    n_features = size(X, 2); %Dimensons of the data
    stop_splitting = 0;
    iter_num = 0;
    display('Running Xmeans analysis...')
    while ~(stop_splitting && iter_num < max_iter)
        K_old = K;
        [clst_labels,clst_centers, ~] = ...
            kmeans(X, K, 'emptyaction','drop','replicate', 10);
        %Get the addtional number of clusters to add
         [add_k, bic_after_split] = get_additional_k_split(K, X, ...
             clst_labels, clst_centers, n_features, K_sub);
         K = K + add_k;
         %Stop if K doesn't change of K is larger than kmax
         stop_splitting = K_old == K || K >= kmax;
         iter_num = iter_num + 1;
         display(['Splitting...Current K = ', num2str(K_old)])
    end
    %Run vanilla kmeas with the number of clusters identified above
    [clst_labels,clst_centers, ~] = ...
            kmeans(X, K_old, 'emptyaction','drop','replicate', 100);
    
end


function [add_k, bic_after_split] = get_additional_k_split(K, X, ...
    clst_labels, clst_centers, n_features, K_sub)
%Determin how many clusters to add
    bic_before_split = []; %Bayesian Infromation Creteria
    bic_after_split = [];
    clst_n_params = n_features + 1;
    add_k = 0;
    
    %Go over each of current clusters
    for clst_index = 1:K
        clst_points = X(clst_labels == clst_index, :);
        clst_size = length(clst_points);
        if clst_size <= K_sub
            %Skip if there isn't enough points 
            continue
        end
        %Current within cluster variance
        clst_variance = sum((clst_points - clst_centers(clst_index, :)).^2,...
            'all')/(clst_size - 1);
        %Calculate BIC before splitting
        bic_before_split(clst_index) = loglikelihood(clst_size, clst_size,...
            clst_variance, n_features, 1) - clst_n_params/ 2 * log(clst_size);
        
        %Break the current cluster to K_sub subclusters
        [subclst_labels,subclst_centers, ~] = kmeans(clst_points, K_sub, ...
            'emptyaction','drop','replicate', 10);
        
        %Quantify BIC after splitting
        l_likelihood = 0;
        %Go over each subcluster
        for subclst_index = 1:K_sub
            subclst_points = clst_points(subclst_labels == subclst_index, :);
            subclst_size = size(subclst_points, 1);
            if subclst_size <= K_sub
                continue
            end
            subclst_variance = sum((subclst_points - subclst_centers(subclst_index, :)).^2,...
            'all')/(subclst_size - K_sub);
            %Accumulate loglikelihood from each subcluster
            l_likelihood = l_likelihood + loglikelihood(clst_size, ...
                subclst_size, subclst_variance, n_features, K_sub);
        end
        subclst_n_params = K_sub * clst_n_params;
        %Compute BIC after splitting
        bic_after_split(clst_index) = l_likelihood - subclst_n_params/ 2 * log(clst_size);
        if bic_before_split(clst_index) < bic_after_split(clst_index)
            %Note that the BIC her is actually -BIC described on Wikipedia
            add_k  = add_k + 1;
        end

    end

end


function res = loglikelihood(R, R_n, variance, M, K)
% See Pelleg's and Moore's for more details.
%    :param R: (int) size of cluster
%    :param R_n: (int) size of cluster/subcluster
%    :param variance: (float) maximum likelihood estimate of variance under spherical Gaussian assumption
%    :param M: (float) number of features (dimensionality of the data)
%    :param K: (float) number of clusters for which loglikelihood is calculated
%    :return: (float) loglikelihood value

    if variance == 0
        res = 0;
    else
        res = R_n * (log(R_n) - log(R) - 0.5*(log(2*pi) + M*log(variance) + 1))...
            + 0.5 * K;
        if res == inf
            res = 0;
        end
    end

end