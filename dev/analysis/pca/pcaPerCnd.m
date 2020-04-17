function pcaPerCnd(experimentStructure)


% get data into cell x trial x cnd sum
data = experimentStructure.dFperCndFBS;

% get the sum per cnd
for p = 1:experimentStructure.cellCount % for each cell
    for  x =1:length(experimentStructure.cndTotal) % for each condition
        
        %full trial prestimON-trialEND cell cnd trial
        trialSum = sum(data{p}{x}(experimentStructure.stimOnFrames(1):experimentStructure.stimOnFrames(2),:),1); %chunks data and sorts into structure
        
        pcaMatrix(p,:,x) = trialSum;
    end
end

% cut out L+M color cnds
pcaMatrix(:,:,13:18) = [];

pcaMatrix(isnan(pcaMatrix)) = 0;
%% all conditions
for i = 1:size(pcaMatrix,3)
    [eigenvectors(:,:,i),score(:,:,i),latent(:,i), tsquared(i,:), explained(i,:), mu(:,i)] = pca(pcaMatrix(:,:,i));
    %     [eigenvectors(:,:,i),score(:,:,i),latent(:,i), tsquared(i,:), explained(i,:), mu(:,i)] = pca(pcaMatrix(:,:,i)');
end

cols = distinguishable_colors(size(eigenvectors,3));


figH = figure('units','normalized','outerposition',[0 0 1 1]);

for q = 1:size(eigenvectors,3)
    lineH(q) = plot3(eigenvectors(:,1,q)', eigenvectors(:,2,q)', eigenvectors(:,3,q)', 'LineWidth',2, 'Color', cols(q,:), 'DisplayName', ['Condition ' num2str(q)] );
    hold on
end

xlabel('PCA 1');
ylabel('PCA 2');
zlabel('PCA 3');

legend;

%% orientations
for x = 1:6
    pcaMatrixOrientation(:,:,x) = [pcaMatrix(:,:,0+x) pcaMatrix(:,:,6+x) pcaMatrix(:,:,12+x) ];
end

for i = 1:size(pcaMatrixOrientation,3)
    [eigenvectorsOrientation(:,:,i),scoreOrientation(:,:,i),latentOrientation(:,i), tsquaredOrientation(i,:), explainedOrientation(i,:), muOrientation(:,i)] = pca(pcaMatrixOrientation(:,:,i));
    %     [eigenvectors(:,:,i),score(:,:,i),latent(:,i), tsquared(i,:), explained(i,:), mu(:,i)] = pca(pcaMatrix(:,:,i)');
end

figH = figure('units','normalized','outerposition',[0 0 1 1]);

for q = 1:size(eigenvectorsOrientation,3)
    lineH(q) = plot3(eigenvectorsOrientation(:,1,q)', eigenvectorsOrientation(:,2,q)', eigenvectorsOrientation(:,3,q)', 'LineWidth',2, 'Color', cols(q,:), 'DisplayName', ['Orientation ' num2str(q)] );
    hold on
end

xlabel('PCA 1');
ylabel('PCA 2');
zlabel('PCA 3');

legend;
end