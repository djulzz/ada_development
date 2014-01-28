function [ str_out ] = f_create_name_from_filename( fullFileName, LeadingPart )

    [pathstr, name, ext] = fileparts( fullFileName );
    res = strsplit( name, LeadingPart );
    res = cell2mat( res( 2 ) );
    res = strsplit( res, '.' );
    date = res( 1 );
    time = res( 2 );
    time = cell2mat( time );
    date = cell2mat( date );
    date = strsplit( date, '-' );
    year = cell2mat( date( 1 ) );
    month = cell2mat( date( 2 ) );
    day = cell2mat( date( 3 ) );
    str_date = [month, '/', day, '/', year];
    time = strsplit( time, '_' );
    hour = cell2mat( time( 1 ) );
    min = cell2mat( time( 2 ) );
    sec = cell2mat( time( 3 ) );
    str_time = [hour, ':', min, ':', sec];
    str_out = [LeadingPart( 1 : end - 1 ), ' - Date - ', str_date, ' - Time ', str_time];


end

