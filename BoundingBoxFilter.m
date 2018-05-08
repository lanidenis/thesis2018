function [filteredBoxes, priorityHelper] = BoundingBoxFilter(boxes, rows, cols)

% Filter bounding boxes based on priority, size, and aspect ratio
filteredBoxes = zeros(size(boxes,1),size(boxes,2));
priorityHelper = zeros(rows, cols);
lastIndex = 1;
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
    
    %add to accepted boxes
    filteredBoxes(lastIndex,:) = [bbox(1),bbox(2),bbox(3),bbox(4)];
    lastIndex = lastIndex + 1;
end

filteredBoxes = filteredBoxes(1:lastIndex-1,:);

