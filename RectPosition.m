classdef RectPosition
    %Rectのposition関係の管理
    
    properties
        position
        p1
        p2
        p3
        p4
        center
    end
    
    methods
        function obj = RectPosition(position)
            %RECTPOSITION このクラスのインスタンスを作成
            %   詳細説明をここに記述
            obj.position = position;
            obj.p1 = position(1);
            obj.p2 = position(2);
            obj.p3 = position(3);
            obj.p4 = position(4);
            obj.center = [position(1) + position(3)/2 , position(2) + position(4)/2 ];
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 このメソッドの概要をここに記述
            %   詳細説明をここに記述
            outputArg = obj.Property1 + inputArg;
        end
    end
end

