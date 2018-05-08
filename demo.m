% This demo shows how to use the software described in our IJCV paper: 
%   Selective Search for Object Recognition,
%   J.R.R. Uijlings, K.E.A. van de Sande, T. Gevers, A.W.M. Smeulders, IJCV 2013
%%
addpath('Dependencies');

fprintf('Demo of how to run the code for:\n');
fprintf('   J. Uijlings, K. van de Sande, T. Gevers, A. Smeulders\n');
fprintf('   Segmentation as Selective Search for Object Recognition\n');
fprintf('   IJCV 2013\n\n');

% Compile anisotropic gaussian filter
if(~exist('anigauss'))
    fprintf('Compiling the anisotropic gauss filtering of:\n');
    fprintf('   J. Geusebroek, A. Smeulders, and J. van de Weijer\n');
    fprintf('   Fast anisotropic gauss filtering\n');
    fprintf('   IEEE Transactions on Image Processing, 2003\n');
    fprintf('Source code/Project page:\n');
    fprintf('   http://staff.science.uva.nl/~mark/downloads.html#anigauss\n\n');
    mex Dependencies/anigaussm/anigauss_mex.c Dependencies/anigaussm/anigauss.c -output anigauss
end

if(~exist('mexCountWordsIndex'))
    mex Dependencies/mexCountWordsIndex.cpp
end

% Compile the code of Felzenszwalb and Huttenlocher, IJCV 2004.
if(~exist('mexFelzenSegmentIndex'))
    fprintf('Compiling the segmentation algorithm of:\n');
    fprintf('   P. Felzenszwalb and D. Huttenlocher\n');
    fprintf('   Efficient Graph-Based Image Segmentation\n');
    fprintf('   International Journal of Computer Vision, 2004\n');
    fprintf('Source code/Project page:\n');
    fprintf('   http://www.cs.brown.edu/~pff/segment/\n');
    fprintf('Note: A small Matlab wrapper was made.\n');
%     fprintf('   
    mex Dependencies/FelzenSegment/mexFelzenSegmentIndex.cpp -output mexFelzenSegmentIndex;
end

%%
% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
colorType = colorTypes{1}; % Single color space for demo

% Here you specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};
simFunctionHandles = simFunctionHandles(1:2); % Two different merging strategies

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
k = 100; % larger k means easier to group segments / prefer larger segments (typical values from 50 to 300)

minSize = 25; %must be less than size of smallest sign (225) or else will overbound
%key is to undermerge segments (i trust sel search to collect the red/blue boundary on most signs)
%but the boundary must not be swallowed by a larger false blob, prefer it to be segmented, no pun intended
sigma = 0.8;

% As an example, use a single image
images = {'00001 copy.ppm'};
im = imread(images{1});

% Perform Selective Search
%tic
%[boxes blobIndIm blobBoxes hierarchy] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
%boxes = BoxRemoveDuplicates(boxes);
%toc

fprintf('done');

%%
figure,imshow(im);

%%
%output color-coded initial segmentation
map = rand(size(blobBoxes,1),3);
color_im = ind2rgb(blobIndIm,map);
figure,imshow(color_im);

%%
% Output bounding boxes with no filters / restrictions
figure,imshow(color_im);
hold on
for i=1:size(boxes,1)
    bbox = boxes(i,:);
    width_ = bbox(4) - bbox(2);
    height_ = bbox(3) - bbox(1);
    if width_ > 128 | height_ > 128 | width_ < 16 | height_ < 16
        continue
    end
    
    r = rectangle('Position',[bbox(2), bbox(1), bbox(4)-bbox(2), bbox(3)-bbox(1)]);
    r.FaceColor = 'none';
    r.EdgeColor = 'b';
    r.LineWidth = 1;
end

%%
% Output bounding boxes based on size / aspect ratio
figure,imshow(color_im);
hold on
for i=1:size(boxes,1)
    bbox = boxes(i,:);
    width_ = bbox(4) - bbox(2);
    height_ = bbox(3) - bbox(1);
    
    if width_ > 128 | height_ > 128 | width_ < 16 | height_ < 16
        continue
    end
    
    if (width_ / height_) > 1.25 | (height_ / width_) > 1.25
        continue
    end
    
    r = rectangle('Position',[bbox(2), bbox(1), bbox(4)-bbox(2), bbox(3)-bbox(1)]);
    r.FaceColor = 'none';
    r.EdgeColor = 'b';
    r.LineWidth = 1;
end

fprintf('done');

%%
priorityHelper = zeros(size(color_im,1), size(color_im,2));
figure,imshow(priorityHelper);

%%
% Output bounding boxes based on priority, size, and aspect ratio
figure,imshow(color_im);
hold on
for i=1:size(boxes,1)
    bbox = boxes(i,:);
    width_ = bbox(4) - bbox(2);
    height_ = bbox(3) - bbox(1);
    
    if width_ > 128 | height_ > 128 | width_ < 16 | height_ < 16
        continue
    end
    
    if (width_ / height_) > 1.25 | (height_ / width_) > 1.25
        continue
    end
    
    flag = 0;
    %check white pixels in tracking image
    for row=bbox(1):bbox(3)
        for col=bbox(2):bbox(4)
            if priorityHelper(row,col) == 1
                flag = 1;
                break
            end
        end
    end
    
    if flag == 1
        continue
    end
     
    %set white pixels in tracking image
    for row=bbox(1):bbox(3)
        for col=bbox(2):bbox(4)
            priorityHelper(row,col) = 1;
        end
    end
    
    r = rectangle('Position',[bbox(2), bbox(1), bbox(4)-bbox(2), bbox(3)-bbox(1)]);
    r.FaceColor = 'none';
    r.EdgeColor = 'b';
    r.LineWidth = 1;
end

fprintf('done');

%%
for i=1:size(priorityHelper,1)
   for j=1:size(priorityHelper,2)
         priorityHelper(i,j) = 0;
   end
end
figure,imshow(priorityHelper); 

%%
%TIME PROCESS END TO END
tic
%t = cputime;

%with hierarchical grouping
[boxes blobIndIm blobBoxes hierarchy] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
boxes = BoxRemoveDuplicates(boxes);
map = rand(size(blobBoxes,1),3);
color_im = ind2rgb(blobIndIm,map);
[filteredBoxes, priorityHelper] = BoundingBoxFilter(boxes, size(color_im,1), size(color_im,2));
toc
%e = cputime - t
%%
%TIME PROCESS END TO END
tic
%without hierarchical grouping (twice as fast)
[colourIm imageToSegment] = Image2ColourSpace(im, colorType);
[blobIndIm blobBoxes neighbours] = mexFelzenSegmentIndex(imageToSegment, sigma, k, minSize);
blobBoxes = BoxRemoveDuplicates(blobBoxes);
map = rand(size(blobBoxes,1),3);
color_im = ind2rgb(blobIndIm,map);
[filteredBoxes, priorityHelper] = BoundingBoxFilter(blobBoxes, size(color_im,1), size(color_im,2));
toc
%e = cputime - t

%%
%output color-coded initial segmentation
figure,imshow(color_im);
%%
%output easy to see white bboxes on black background
figure,imshow(priorityHelper);
%%
%output bboxes on original image
figure,imshow(im);
hold on
for i=1:size(filteredBoxes,1)
    bbox = filteredBoxes(i,:);
    width_ = bbox(4) - bbox(2);
    height_ = bbox(3) - bbox(1);
    
    r = rectangle('Position',[bbox(2), bbox(1), bbox(4)-bbox(2), bbox(3)-bbox(1)]);
    r.FaceColor = 'none';
    r.EdgeColor = 'b';
    r.LineWidth = 1;
end
%%
% Show boxes
%ShowRectsWithinImage(boxes, 5, 5, im);

% Show blobs which result from first similarity function
%hBlobs = RecreateBlobHierarchyIndIm(blobIndIm, blobBoxes, hierarchy{1});
%ShowBlobs(hBlobs, 5, 5, im);