classdef MovieReader
    % reader
    
    properties
        movieStream
    end
    
    methods
        function obj = MovieReader()
            %UNTITLED6 このクラスのインスタンスを作成
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
            outputArg = obj.Property1 + inputArg;
        end
    end
end

