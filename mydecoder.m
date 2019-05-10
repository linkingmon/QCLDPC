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
    end
    
    methods
    
        % constructor
        function obj = mydecoder(PCM, Max_iter)
            obj.PCM = PCM;
            obj.Col = size(PCM,2);
            obj.Row = size(PCM,1);
            obj.Max_iter = Max_iter;
            obj.p = find(obj.PCM);
            obj.pmod = ceil(obj.p / obj.Row);
            obj.ppr = obj.makePPR();
        end

        % Sum product decoding
        % our speed is approximately 7 times slower than MATLABs ldpcdecode(MATLAB version)
        % (QCLDPC) giving base graph: 1 ; input length : 22 * 32 ; code rate : 1 / 2 (22 * 32)
        function out = decodeSP(obj, in)
            % fprintf("Start decoding...\n\n");
            E = zeros(obj.Row, obj.Col);
            M = zeros(obj.Row, obj.Col);
            L = in;
            M = repmat(in,obj.Row,1).*obj.PCM;
            for ii = 0 : obj.Max_iter
                % fprintf("Iteration %d\n", ii);
                out = obj.check(L);
                % print_L = sprintf(repmat('%.4f ', 1, length(L)), L);
                % print_out = sprintf(repmat('%1d ', 1, length(out)), out);
                % fprintf("input sequence %s\n", print_L);
                % fprintf("parity checking %s\n\n", print_out);
                if(sum(out) == 0 || ii == obj.Max_iter)
                    % fprintf("Done decoding...\n\n");
                    out = L < 0;
                    out = out(1,1:length(in)/obj.Col*(obj.Col - obj.Row));
                    break;
                else
                    M(obj.p) = tanh(M(obj.p)/2);
                    for jj = 1 : obj.Row
                        T = prod(M(jj, obj.ppr{jj,1}));
                        E(jj, obj.ppr{jj,1}) = T ./ M(jj, obj.ppr{jj,1});
                    end
                    E(E>=0.9999999999999999) = 0.9999999999999999;
                    E(E<=-0.9999999999999999) = -0.9999999999999999;
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
                        ID = obj.ppr{jj,1};
                        neg_cnt = sum(M(jj, ID) < 0);
                        change = mod(neg_cnt, 2);
                        SG = sign(M(jj, ID));
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

        % normalize min-sum decoding
        function out = decodeNMS(obj, in, Nor)
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
                        ID = obj.ppr{jj,1};
                        neg_cnt = sum(M(jj, ID) < 0);
                        change = mod(neg_cnt, 2);
                        SG = sign(M(jj, ID));
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
                    E(obj.p) = E(obj.p) * Nor;
                    L = sum(E, 1) + in;
                    M(obj.p) = L(obj.pmod)' - E(obj.p);
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

