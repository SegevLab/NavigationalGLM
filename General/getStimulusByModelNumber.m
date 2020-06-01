function stimulus = getStimulusByModelNumber(modelNumber, posgrid, hdgrid, speedgrid, thetaGrid)

switch modelNumber
    case 1
        stimulus = [posgrid hdgrid speedgrid thetaGrid];
    case 2
        stimulus = [posgrid hdgrid speedgrid];
    case 3
        stimulus = [posgrid hdgrid thetaGrid];
    case 4
        stimulus = [posgrid speedgrid thetaGrid];
    case 5
        stimulus = [hdgrid speedgrid thetaGrid];
    case 6
        stimulus = [posgrid hdgrid];
    case 7
        stimulus = [posgrid speedgrid];
    case 8
        stimulus = [posgrid thetaGrid];
    case 9
        stimulus = [hdgrid speedgrid];
    case 10
        stimulus = [hdgrid thetaGrid];
    case 11
        stimulus = [speedgrid thetaGrid];
    case 12
        stimulus = [posgrid];
    case 13
        stimulus = [hdgrid];
    case 14
        stimulus = [speedgrid];
    case 15
        stimulus = [thetaGrid];


end