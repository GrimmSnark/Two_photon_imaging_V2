function SEM  = sem(data)
 SEM = std( data ) / sqrt( length( data ));
end