classdef TestDefault
    % �����l�ݒ�̎���
    % https://qiita.com/eigs/items/5d4f93464eb6506bead6
    
    properties
        a
        b
    end
    
    methods
        function obj = TestDefault(a, b)
            % TESTSHOKI ���̃N���X�̃C���X�^���X���쐬
            % X = TestDefault
            % a:1 b:1
            % X = TestDefault(2)
            % a:2 b;1
            %�@�������ׂ��I
            arguments
                a = 1;
                b = 1;
            end
            obj.a = a;
            obj.b = b;
        end
        
        function x = getC(obj,c)
            % obj �����ׂȂ��Ƃ����Ȃ�
            arguments
                obj
                c = 1
            end
            x = c;
        end
    end
end

