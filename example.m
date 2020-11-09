% give the center of region of interest (in utm coordinate)
center_of_intersection = [457264,5427980];
% f_get_map_info will get the building polygon and street info in region size 100*100m box 
% the size of box can be modified in row 11 and 12 in f_get_map_info
[roads,building] = f_get_map_info(center_of_intersection);
% crop the point cloud using building polygon
% insidepoly_install must run before using f_crop_building
% insidepoly is a C-code for accelerate the program
frame_merged_without_building = f_crop_building(frame_merged,building);