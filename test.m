% simple test for debug

% parameters
PCM = [1 0 0 1 0 1 ; 
       0 1 1 0 1 0 ; 
       1 0 1 0 1 0 ; 
       0 1 0 1 0 1];
Zc = 2;
max_iter = 2;

s = 1; w = 6; f = 1;
ep = 2^(w - s - f) - 1;
ntBP = numerictype(s,w,f);          % numeric type

in = [-0.6 2.7 -3.9 5.22 -3.567 2.50];

% decoding
T = mydecoder(PCM, max_iter, Zc);
T.decodeNMSq(in, 0.75, ntBP);

% T.decodeSP_layer(in);
% T.decodeSP(in);
% T.decodeMS(in);
% T.decodeNMS(in, 0.75);