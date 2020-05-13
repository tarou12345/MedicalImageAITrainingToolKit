classdef SeparateLabelDef
    % labelDef ��segmentation �� Rect�ɕ���
    
    properties
        segment
        rect
        segmentCount
        rectCount
    end
    
    methods
        function obj = SeparateLabelDef(gTruth)
            % SEPARATELABELDEF ���̃N���X�̃C���X�^���X���쐬
            
            % �ݒ�
            labelDef = gTruth.LabelDefinitions;
            numOfLabel = size(labelDef,1);
            segmentCount = 0;
            rectCount = 0;
            
            % PixellabelId �̗L�薳�������o
            % ToDo: �Ȃ���exist�Ńe�[�u���̗�̑��݂��m�F�ł��Ȃ�
            % ��������R�[�h�����ǃG���[�����𗘗p���đ��݂��m�F
%             isPixelExist = 1;
%             try
%                 labelDef.PixelLabelID(1);
%             catch
%                 isPixelExist = 0;
%             end
%             if isPixelExist ==0 
%             end
                
            % table�����Z���f�[�^�ł��邽��for���[�v�Œ��o
            % type 0 : rect
            % type 4 : segment
            % ToDo �F �ق��̃^�C�v����
            for i=1:numOfLabel
                switch labelDef.Type(i)
                    case 0
                    rectCount = rectCount + 1;
                    colorMapVal = labelDef.LabelColor(i,:);
                    rect(rectCount).colorMapVal = colorMapVal;
                    rect(rectCount).name = cell2mat(labelDef.Name(i));
                    %rect(rectCount).colorMapVal = cell2mat(labelDef.LabelColor(i));
                    %rect(rectCount).name = cell2mat(labelDef.Name(i));
                    rect(rectCount).labelId = i;
                    case 4
                    % segment �Ȃ� pixelLabelId ������͂�
                    pixelLabelId = cell2mat(labelDef.PixelLabelID(i));
                    segmentCount = segmentCount + 1;
                    colorMapVal = labelDef.LabelColor(i,:);
                    segment(segmentCount).colorMapVal = colorMapVal;
                    segment(segmentCount).name = cell2mat(labelDef.Name(i));
                    segment(segmentCount).pixelLabelId = cell2mat(labelDef.PixelLabelID(i));
                    %segment(segmentCount).colorMapVal = cell2mat(labelDef.LabelColor(i));
                    %segment(segmentCount).name = cell2mat(labelDef.Name(i));
                    %segment(segmentCount).pixelLabelId = cell2mat(labelDef.PixelLabelID(i));
                    segment(segmentCount).labelId = i;
                end
            end
            
            
            obj.segment = segment;
            obj.rect = rect;
            obj.segmentCount = segmentCount;
            obj.rectCount = rectCount;
        end
        
    end
end

