% simple test for debug

% parameters
PCM = [1 1 0 1 0 0 ; 0 1 1 0 1 0 ; 1 0 0 0 1 1 ; 0 0 1 1 0 1];
max_iter = 15;
in = [-0.5 2.5 -4.0 5.0 -3.5 2.5];

% decoding
T = mydecoder(PCM, max_iter);
T.decodeSP(in);
T.decodeMS(in);
T.decodeNMS(in, 0.75);