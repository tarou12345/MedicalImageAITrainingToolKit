classdef TestDefault
    % 初期値設定の実験
    % https://qiita.com/eigs/items/5d4f93464eb6506bead6
    
    properties
        a
        b
    end
    
    methods
        function obj = TestDefault(a, b)
            % TESTSHOKI このクラスのインスタンスを作成
            % X = TestDefault
            % a:1 b:1
            % X = TestDefault(2)
            % a:2 b;1
            %　すごくべんり！
            arguments
                a = 1;
                b = 1;
            end
            obj.a = a;
            obj.b = b;
        end
        
        function x = getC(obj,c)
            % obj も並べないといけない
            arguments
                obj
                c = 1
            end
            x = c;
        end
    end
end

