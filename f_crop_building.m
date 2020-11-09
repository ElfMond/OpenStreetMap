function [outputFrames] = f_crop_building(pc_global,polyin)
%crop the point of building using polygons
% INPUT:
%   pc_global: cell of point cloud
%   polyin: array of polygons
% OUTPUT:
%   outputFrames: cell of point cloud without buildings
    if ~iscell(pc_global)
        pc_global = {pc_global};
    end
    outputFrames = cell(length(pc_global),1);
    h = waitbar(0,"cropping building ......");
    for frame_idx = 1:length(pc_global)
        if(isa(pc_global{frame_idx},'pointCloud'))
            frame = pc_global{frame_idx};
        else
            Location = pc_global{frame_idx}(:,1:3);
            Intensity = pc_global{frame_idx}(:,4);
            frame = pointCloud(Location,'Intensity',Intensity);
        end
        for i = 1:size(polyin,2)
            locations = frame.Location;
            locations = reshape(locations,[],3);
            [x,y] = polybuffer(polyin(1,i),2.5).boundary;
            inside = insidepoly(locations(:,1),locations(:,2),x,y);
            indices = find(~inside);
            frame = select(frame,indices);
        end

        outputFrames{frame_idx} = frame;
        waitbar(frame_idx/length(pc_global),h,sprintf("cropping building ......%2.2f%%",100*frame_idx/length(pc_global)));
    end
    delete(h);
end

