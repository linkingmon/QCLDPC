% ldpc decoder

classdef mydecoder
    properties
        PCM;            % parity check matrix
        Col;
        Row;
        Max_iter;
        p;              % find 1's
        pmod;           % mod of p
        ppr;            % Cell Array: place of 1's per column
        BGRow;          % number of rows of base graph
        Zc;             % lifting size
    end
    
    methods
    
        % constructor
        function obj = mydecoder(PCM, Max_iter, Zc)
            obj.PCM = PCM;
            obj.Col = size(PCM,2);
            obj.Row = size(PCM,1);
            obj.Max_iter = Max_iter;
            obj.p = find(obj.PCM);
            obj.pmod = ceil(obj.p / obj.Row);
            obj.ppr = obj.makePPR();            % save the place for 1's first
            obj.BGRow = obj.Row / Zc;
            obj.Zc = Zc;
        end

        % Sum product decoding
        % our speed is approximately 7 times slower than MATLABs ldpcdecode(MATLAB version)
        % (QCLDPC) giving base graph: 1 ; input length : 22 * 32 ; code rate : 1 / 2 (22 * 32)
        function out = decodeSP(obj, in)
            E = zeros(obj.Row, obj.Col);
            M = zeros(obj.Row, obj.Col);
            L = in;
            M = repmat(in,obj.Row,1).*obj.PCM;
            for ii = 0 : obj.Max_iter
                out = obj.check(L);
                if(sum(out) == 0 || ii == obj.Max_iter)
                    out = L < 0;
                    out = out(1,1:length(in)/obj.Col*(obj.Col - obj.Row));
                    break;
                else
                    M(obj.p) = tanh(M(obj.p)/2);
                    for jj = 1 : obj.Row
                        ID = obj.ppr{jj,1};
                        T = prod(M(jj, ID));
                        E(jj, ID) = T ./ M(jj, ID);
                    end
                    E(obj.p) = 2*atanh(E(obj.p));
                    L = sum(E, 1) + in;
                    M(obj.p) = L(obj.pmod)' - E(obj.p);

                end
            end
        end

        % min-sum decoding
        function out = decodeMS(obj, in)
            E = zeros(obj.Row, obj.Col);
            M = zeros(obj.Row, obj.Col);
            L = in;
            M = repmat(in,obj.Row,1).*obj.PCM;
            for ii = 0 : obj.Max_iter
                out = obj.check(L);
                if(sum(out) == 0 || ii == obj.Max_iter)
                    out = L < 0;
                    out = out(1,1:length(in)/obj.Col*(obj.Col - obj.Row));
                    break;
                else
                    for jj = 1 : obj.Row
                        ID = obj.ppr{jj,1};;
                        neg_cnt = sum(M(jj, ID) < 0);
                        change = mod(neg_cnt, 2);
                        SG = sign(M(jj, ID));
                        SG(SG==0) = 1;
                        M(jj, ID) = abs(M(jj, ID));
                        [O, idx] = sort(M(jj, ID));
                        E(jj, ID) = O(1);
                        E(jj, ID(idx(1))) = O(2);
                        if change
                            E(jj, ID) = -E(jj, ID) .* SG;
                        else
                            E(jj, ID) = E(jj, ID) .* SG;
                        end
                    end
                    L = sum(E, 1) + in;
                    M(obj.p) = L(obj.pmod)' - E(obj.p);
                end
            end
        end

        % Layered Sum product decoding
        function out = decodeSP_layer(obj, in)
            M = zeros(obj.Row, obj.Col);
            L = in;
            for ii = 0 : obj.Max_iter+1
                if sum(isnan(L)) ~= 0
                    error("NAN")
                end
                out = obj.check(L);
                if(sum(out) == 0 || ii == obj.Max_iter)
                    out = L < 0;
                    out = out(1,1:length(in)/obj.Col*(obj.Col - obj.Row));
                    break;
                else
                    for kk = 1 : obj.BGRow                    % for each layer
                        for jj = (kk-1)*obj.Zc+1 : kk*obj.Zc  % for each row in the layer
                            ID = obj.ppr{jj,1};
                            To(ID) = L(ID) - M(jj, ID);
                            
                            T(ID) = tanh(To(ID)/2);

                            NZ = [];
                            Z = sum(abs(T(ID)) < 0.001);
                            if Z > 0
                                NZ = ID(abs(T(ID)) > 0.001);
                            end
                            T(ID(abs(T(ID)) < 0.001)) = 0.001;
                            
                            T1 = prod(T(ID));
                            T(ID) = T1 ./ T(ID);
                            T(NZ) = 0;
                            M(jj, ID) = 2*atanh(T(ID));
                            num_inf = sum(isinf(M(jj, ID)));
                            if num_inf > 0
                                S = isinf(M(jj, ID));
                                inf_place = ID(S);
                                M(jj, inf_place) = sign(M(jj, inf_place))*38.14;
                            end
                            L(ID) = M(jj, ID) + To(ID);
                        end
                    end
                end
            end
        end

        % Layered MS decoding
        function out = decodeMS_layer(obj, in)
            M = zeros(obj.Row, obj.Col);
            L = in;
            for ii = 0 : obj.Max_iter+1
                out = obj.check(L);
                if(sum(out) == 0 || ii == obj.Max_iter)
                    out = L < 0;
                    out = out(1,1:length(in)/obj.Col*(obj.Col - obj.Row));
                    break;
                else
                    for kk = 1 : obj.BGRow                    % for each layer
                        for jj = (kk-1)*obj.Zc+1 : kk*obj.Zc  % for each row in the layer
                            ID = obj.ppr{jj,1};
                            To(ID) = L(ID) - M(jj, ID);
                            ID = ID;
                            neg_cnt = sum(To(ID) < 0);
                            change = mod(neg_cnt, 2);
                            SG = double(sign(To(ID)));
                            SG(SG == 0) = 1;
                            T(ID) = abs(To(ID));
                            [O, idx] = sort(T(ID));
                            M(jj, ID) = O(1);
                            M(jj, ID(idx(1))) = O(2);
                            if change
                                M(jj, ID) = -M(jj, ID) .* SG;
                            else
                                M(jj, ID) = M(jj, ID) .* SG;
                            end
                            L(ID) = M(jj, ID) + To(ID);
                        end
                    end
                end
            end
        end

        % normalize MS quan, not optimize in MATLAB, may be slow
        function out = decodeNMSq(obj, in, Nor, ntBP)
            % the maximun number that can be represent by this type of fixed point
            ep = realmax(fi(0, ntBP));
            ep = ep.data;
            % initialize
            E = zeros(obj.Row, obj.Col);
            M = zeros(obj.Row, obj.Col);
            % quantize input
            in(in > ep) = ep;
            in(in < -ep) = -ep;
            in = fi(in,ntBP);
            L = in.data;
            M = repmat(L,obj.Row,1).*obj.PCM;
            for ii = 0 : obj.Max_iter
                out = obj.check(L);
                if(sum(out) == 0 || ii == obj.Max_iter)
                    out = L < 0;
                    out = out(1,1:length(in)/obj.Col*(obj.Col - obj.Row));
                    break;
                else
                    % CTV
                    for jj = 1 : obj.Row
                        % find min1 and min2 per row
                        ID = obj.ppr{jj,1};
                        neg_cnt = sum(M(jj, ID) < 0);
                        change = mod(neg_cnt, 2);
                        SG = double(sign(M(jj, ID)));
                        SG(SG == 0) = 1;
                        M(jj, ID) = abs(M(jj, ID));
                        [O, idx] = sort(M(jj, ID));
                        E(jj, ID) = O(1);
                        E(jj, ID(idx(1))) = O(2);
                        if change
                            E(jj, ID) = -E(jj, ID) .* SG;
                        else
                            E(jj, ID) = E(jj, ID) .* SG;
                        end
                    end
                    % normalize
                    temp = fi(E(obj.p), ntBP);
                    temp = bitsra(temp,1) + bitsra(temp,2);
                    E(obj.p) = temp.data;
                    
                    % VTC
                    L = sum(E, 1) + in;
                    M(obj.p) = L(obj.pmod)' - E(obj.p);
                    M(obj.p(M(obj.p) > ep)) =  ep;
                    M(obj.p(M(obj.p) < -ep)) =  -ep;
                end
            end
        end

        % parity checking
        function out = check(obj, in)
            in = in < 0;
            out = mod(obj.PCM * in', 2)';
        end

        % initialize cell array obj.ppr
        function ppr = makePPR(obj)
            ppr = cell(obj.Row,1);
            for ii = 1 : obj.Row
                ppr{ii} = find(obj.PCM(ii,:));
            end
        end
    end
end

