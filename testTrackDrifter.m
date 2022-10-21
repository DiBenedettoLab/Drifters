



%% Beached Spotter
[ds]=load_drift_data('spot');
clc
ID=[305
348
611
621
637
642
645
650
651
670
1279
1299
1301
1504
1505
1966
1970
10025
10050
10122
10216];
TrackDrifter(ID,ds,'bcrit',10,'adjlon',70);