classdef SegmentColor
    %SEGMENTCOLOR ���̃N���X�̊T�v�������ɋL�q
    %   �ڍא����������ɋL�q
    
    properties
        I
        Iseg
        labelId
        colorMapVal
        alphaVal
        Ib
        Ic
    end
    
    methods
        function obj = SegmentColor(I,Iseg,labelId,colorMapVal)
            % �C�j�V�����C�Y
            obj.I = I;
            obj.Iseg = Iseg;
            obj.labelId = labelId;
            obj.colorMapVal = colorMapVal;
            
            % ���ߐ��ݒ�
            obj.alphaVal = 0.7;
            alphaVal = 0.7;
            
            % �Z�O�����g���ꂽ�̈�𒊏o���ĐF�t��
            Ilogic = (Iseg == labelId);
            Imatch = 255 * uint8(Ilogic); % �Z�O�����g�̈�̒��o 
            Ib(:,:,1) = Imatch .* colorMapVal(1); % �F�t��
            Ib(:,:,2) = Imatch .* colorMapVal(2);
            Ib(:,:,3) = Imatch .* colorMapVal(3);
            %imshow(Ib)

            % �Z�O�����g����Ă��Ȃ��̈�𒊏o���Č��摜�𒣂�t��
            IlogicInv = ~Ilogic;
            IbInv = uint8(IlogicInv) .* I;
            %imshow(IbInv)

            % ���҂�����
            IbCombined = IbInv + Ib;
            %imshow(IbCombined)

            % alphaVal���ߐ��ɉ����Č���
            Ia = I;
            Ic = (Ia .* alphaVal) + (IbCombined .* (1-alphaVal));
            %imshow(IC)
            
            % �L�^
            obj.Ic = Ic; % �����摜
            obj.Ib = Ib; % 
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 ���̃��\�b�h�̊T�v�������ɋL�q
            %   �ڍא����������ɋL�q
            outputArg = obj.Property1 + inputArg;
        end
    end
end

