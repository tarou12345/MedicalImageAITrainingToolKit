classdef RectPosition
    %Rect��position�֌W�̊Ǘ�
    
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
            %RECTPOSITION ���̃N���X�̃C���X�^���X���쐬
            %   �ڍא����������ɋL�q
            obj.position = position;
            obj.p1 = position(1);
            obj.p2 = position(2);
            obj.p3 = position(3);
            obj.p4 = position(4);
            obj.center = [position(1) + position(3)/2 , position(2) + position(4)/2 ];
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            outputArg = obj.Property1 + inputArg;
        end
    end
end

