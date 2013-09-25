excelCompiled = {};
excelLumped = {};
filename = [imagePath{1} '_octSegmentation.mat'];

load(filename);

%intitialize a vector location of the layers
layersToPlot  = {'ilm' 'nflgcl' 'iplinl' 'inlopl' 'oplonl' 'isos' 'rpe'};
for i = 1:numel(layersToPlot)
    layerCompile(i).name = layersToPlot{i};
    layerCompile(i).x = [];
end

%shorten the pathx and pathy
if params.isResize(1)
    szImg = size(imresize(img(:,:,1),params.isResize(2)));
else
    szImg = size(img);
end
%% iterate through 'imageLayer(i).retinalLayers(j)'
% and save location to the corresponding vector 'layerCompile(storeInd)'

for i = 1:numel(imageLayer),

    params =  imageLayer(i).params;

    for j = 1:numel(imageLayer(i).retinalLayers),

        indValidPath = find(imageLayer(i).retinalLayers(j).pathY ~=1 & ...
                       imageLayer(i).retinalLayers(j).pathY ~= szImg(2)+2);

        %make sure subscript-Y is inbound image, and left shift subscript-y
        imageLayer(i).retinalLayers(j).pathX = imageLayer(i).retinalLayers(j).pathX(indValidPath);
        imageLayer(i).retinalLayers(j).pathY = imageLayer(i).retinalLayers(j).pathY(indValidPath)-1; 

        %make sure subscript-ys are unique
        [uniqVal uniqInd] = unique(imageLayer(i).retinalLayers(j).pathY);

        imageLayer(i).retinalLayers(j).pathX = imageLayer(i).retinalLayers(j).pathX(uniqInd);
        imageLayer(i).retinalLayers(j).pathY = imageLayer(i).retinalLayers(j).pathY(uniqInd); 

        %make sure Ys are contiguous
        imageLayer(i).retinalLayers(j).pathXNew = interp1(imageLayer(i).retinalLayers(j).pathY,... %original Y
            imageLayer(i).retinalLayers(j).pathX,... %original X, to be interp
            [1:szImg(2)],... %new Y
            'nearest');

        % %replace old pathX and pathY with the new ones.
        % imageLayer(i).retinalLayers(j).pathX = imageLayer(i).retinalLayers(j).pathXNew;
        % imageLayer(i).retinalLayers(j).pathY = 1:szImg(2);

        %find location in layerCompile to save the new pathX
        storeInd = find( strcmpi(imageLayer(i).retinalLayers(j).name,layersToPlot) ==1);

        if ~isempty(storeInd)
            layerCompile(storeInd).x = [ layerCompile(storeInd).x imageLayer(i).retinalLayers(j).pathXNew];
        end

    end % of for j = 1:numel(imageLayer(i).retinalLayers),


end % of for i = 1:numel(imageLayer),

%%
% quantify retinal layer thickness
excel = {};
layersToAnalyze = {'ilm' 'nflgcl' 'iplinl' 'inlopl' 'oplonl' 'isos' 'rpe'};

excel = [excel; {'name' 'mean' 'sd'}];
for i = 2:numel(layersToAnalyze)
    firstLayerInd = find(strcmpi(layersToAnalyze{i-1},layersToPlot)==1);
    secondLayerInd = find(strcmpi(layersToAnalyze{i},layersToPlot)==1);
    excel = [excel; {strcat( [ layersToAnalyze{i-1} ' - ' layersToAnalyze{i}] ),...
        nanmean(layerCompile(secondLayerInd).x-layerCompile(firstLayerInd).x),...
        nanstd(layerCompile(secondLayerInd).x-layerCompile(firstLayerInd).x)}];
end

% print out thickness
excel