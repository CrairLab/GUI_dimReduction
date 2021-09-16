function [all_bic, bic_knee, bic_laplacian, bic_max] = bestBIC(X, kmax)
%Evalute and get the best K using the BIC
%X: input data, n * d
%kmax: max number of k
%Pelleg, Dan, and Andrew W. Moore. "X-means: Extending K-means with Efficient Estimation of the Number of Clusters."
%ICML. Vol. 1. 2000.
%https://www.cs.cmu.edu/~dpelleg/download/xmeans.pdf
    
    all_bic = zeros(kmax, 1);
    for K = 1:kmax     
        disp(['Computing the BIC score at K = ' num2str(K)])
        [clst_labels,clst_centers, ~] = kmeans(X, K, 'emptyaction','drop',...
            'replicate', 10);
        all_bic(K) = getBIC(X, clst_labels, clst_centers);
    end
    
    [bic_knee, ~] = knee_pt(all_bic); %Find the knee point
    [~, bic_laplacian] = min(del2(all_bic)); %Find the minimum laplacian
    [max_bic, bic_max] = max(all_bic);
    
    %Plot the result
    figure();
    title('BIC scores');
    plot(all_bic);
    hold on;
    plot(bic_knee, all_bic(bic_knee), 'r*');
    plot(bic_laplacian, all_bic(bic_laplacian), 'g*');
    plot(bic_max, max_bic, 'b*');
    legend('BIC curve', 'Knee', 'Min Laplacian', 'Max BIC')
end


function BIC = getBIC(X, clst_labels, clst_centers)

    %Get the BIC score for the current model
    R = size(X,1); %number of points
    K = size(clst_centers, 1); %number of clustersop
    M = size(clst_centers, 2); %number of dimensions
    variance = getvariance(R, K ,X, clst_labels, clst_centers); %model variance
    
    %Calculate the BIC of current model
    l = loglikelihood(R, clst_labels, variance, M, K); %loglikelihood 
    
    %Get the BIC score 
    BIC = l - 0.5 * (M+1)*K * log(R);
    
end

function variance = getvariance(R, K ,X, clst_labels, clst_centers)
%Compute the variance given input data
%R: number of points 
%K: number of clusters
%X: all input datapoints
%clst_labels: current cluster labels
%clst_centers: current cluster centers
    variance = 0;
    %Iterate over all clusters
    for i = 1:size(clst_centers,1)
        subclst_points = X(clst_labels == i, :);
        variance = variance +...
            sum((subclst_points - clst_centers(i, :)).^2,...
                'all')/(R - K);
    end
    %%https://github.com/bobhancock/goxmeans/blob/master/doc/BIC_notes.pdf    
    variance = variance/size(clst_centers, 2); 
end


function res = loglikelihood(R, clst_labels, variance, M, K)
% See Pelleg's and Moore's for more details.
% Note that the loglikelihood is of the entire model
%    :param R: (int) size of cluster
%    :param clst_labels: (int) size of cluster/subcluster
%    :param variance: (float) maximum likelihood estimate of variance under spherical Gaussian assumption
%    :param M: (float) number of features (dimensionality of the data)
%    :param K: (float) number of clusters for which loglikelihood is calculated
%    :return: (float) loglikelihood value
    
    res = 0;
    if variance == 0
        return
    else
        for i = 1:K
            R_n = sum(clst_labels == i);
            res = res + R_n * log (R_n);
        end
        %See https://github.com/bobhancock/goxmeans/blob/master/doc/BIC_notes.pdf
        %Note that (21) -> (22) the MK/2 sign was wrong, corrected here
        res = res + 0.5 * ( M * K - M * R * log(variance));         
        if res == inf
            res = 0;
        end
    end

end