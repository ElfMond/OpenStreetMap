function [road,building_poly] = f_get_map_info(center_of_intersection)
% download map from openstreetmap and get polygons of buildings around
% intersection.
% INPUT: 
%   center_of_intersection: [x_utm,y_utm]
% OUTPUT:
%   pgon: array of polyshape
    openstreetmap_filename = 'map.osm';
    options = weboptions('Timeout',20);
%     center_of_intersection = [457264,5427980]; 
    [Lat_ctr_ld,Lon_ctr_ld] = utm2deg(center_of_intersection(1)-100,center_of_intersection(2)-100,'32 U');
    [Lat_ctr_ru,Lon_ctr_ru] = utm2deg(center_of_intersection(1)+100,center_of_intersection(2)+100,'32 U');
    bbox = [Lon_ctr_ld,Lat_ctr_ld,Lon_ctr_ru,Lat_ctr_ru];
    bbox_str = sprintf("bbox=%.5f,%.5f,%.5f,%.5f",bbox(1),bbox(2),bbox(3),bbox(4));
    url = "https://overpass-api.de/api/map?"+ bbox_str;
    outfilename = websave(openstreetmap_filename,url,options);
    map_osm = xml2struct_fex28518(openstreetmap_filename);
    parsed_osm = parse_osm(map_osm.osm);
    objs = cell(size(parsed_osm.way.tag,2),4);
    building_poly = [];
    road = [];
    for idx = 1:size(parsed_osm.way.tag,2)
        tag = parsed_osm.way.tag{idx};
        objs{idx,3} = parsed_osm.way.nd{idx};
        objs{idx,4} = zeros(2,size(objs{idx,3},2));
        for pts = 1:size(objs{idx,3},2)
            objs{idx,4}(:,pts) = parsed_osm.node.xy(:,find(parsed_osm.node.id == objs{idx,3}(pts)));
        end
        if isempty(tag)
            objs{idx,1} = "none";
            objs{idx,2} = "none";
            continue
        end
        if ~iscell(tag)
            tag = {tag};
        end
        objs{idx,1} = "other";
        objs{idx,2} = "other";
        for n = 1:size(tag,2)
            if (tag{n}.Attributes.k == "highway")||(tag{n}.Attributes.k == "building")...
                    ||(tag{n}.Attributes.k == "leisure")||(tag{n}.Attributes.k == "natural")...
                    ||(tag{n}.Attributes.k == "landuse")||(tag{n}.Attributes.k == "boundary")...
                    ||(tag{n}.Attributes.k == "area:highway")||(tag{n}.Attributes.k == "amenity")
                objs{idx,1} = tag{n}.Attributes.k;
                objs{idx,2} = tag{n}.Attributes.v;
            elseif tag{n}.Attributes.k == "name"
                objs{idx,5} = tag{n}.Attributes.v;
            elseif tag{n}.Attributes.k == "maxspeed"
                objs{idx,6} = tag{n}.Attributes.v;
            elseif tag{n}.Attributes.k == "sidewalk"
                objs{idx,7} = tag{n}.Attributes.v;
            end
        end
        if objs{idx,1} == "building"
            [x,y,~] = deg2utm(objs{idx,4}(2,:),objs{idx,4}(1,:));
            building_poly = horzcat(building_poly,convhull(polyshape(x,y)));
        end
        if objs{idx,1} == "highway" && objs{idx,2} == "residential"
            [x,y,~] = deg2utm(objs{idx,4}(2,:),objs{idx,4}(1,:));
            road = horzcat(road,struct("name",objs{idx,5},"points",[x,y],"maxspeed",objs{idx,6},"sidewalk",objs{idx,7}));
        end
    end
end