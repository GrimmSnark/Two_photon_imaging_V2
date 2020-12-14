function chooseROIsCallbck(src,evnt)

% retrieve cell number
cellNo = str2double(src.Tag);

% get cell identity data
cellIdentityFlag = src.Parent.Parent.UserData;


if cellIdentityFlag(cellNo) == 0
    cellIdentityFlag(cellNo) = 1;
    src.EdgeColor = [1 0 0];
else
    cellIdentityFlag(cellNo) = 0;
    src.EdgeColor = [0 1 1];
end


src.Parent.Parent.UserData = cellIdentityFlag;
end