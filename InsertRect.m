classdef InsertRect
    % �摜��rect��}������
    
    properties
        Inserted
    end
    
    methods
        function obj = InsertRect(I,position,colorMapVal)
            % �C���X�^���X���쐬
            Iinserted = insertShape(I, 'Rectangle', position, ...
                'LineWidth', 5, 'Color', colorMapVal);
            obj.Iinserted = Iinserted;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            outputArg = obj.Property1 + inputArg;
        end
    end
end

