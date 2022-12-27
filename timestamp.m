function [d2] = timestamp(d1)
UTC_offset=d1-datenum(1970,1,1);
d2=UTC_offset*(24*60*60);
end

