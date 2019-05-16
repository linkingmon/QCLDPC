% simple test for debug

% parameters
PCM = [1 0 0 1 0 1 ; 
       0 1 1 0 1 0 ; 
       1 0 1 0 1 0 ; 
       0 1 0 1 0 1];
Zc = 2;
max_iter = 15;
in = [-0.5 2.5 -4.0 5.0 -3.5 2.5];

% decoding
T = mydecoder(PCM, max_iter, Zc);
T.decodeMS_layer(in);

T.decodeSP_layer(in);
T.decodeSP(in);
T.decodeMS(in);
T.decodeNMS(in, 0.75);