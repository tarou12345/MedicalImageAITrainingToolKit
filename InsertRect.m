classdef InsertRect
    % 画像にrectを挿入する
    
    properties
        Inserted
    end
    
    methods
        function obj = InsertRect(I,position,colorMapVal)
            % インスタンスを作成
            Iinserted = insertShape(I, 'Rectangle', position, ...
                'LineWidth', 5, 'Color', colorMapVal);
            obj.Iinserted = Iinserted;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
            outputArg = obj.Property1 + inputArg;
        end
    end
end

