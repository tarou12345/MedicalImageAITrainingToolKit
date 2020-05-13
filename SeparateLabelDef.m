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
            
            % table�����Z���f�[�^�ł��邽��for���[�v�Œ��o
            for i=1:numOfLabel
                pixelLabelId = cell2mat(labelDef.PixelLabelID(i));
                % pixelLabelId ��������̂�segment�Ƃ݂Ȃ�
                % ToDo: �{���Ȃ�type �ŕ��ނ��ׂ���������ID���킩��Ȃ�
                if isempty(pixelLabelId)
                    rectCount = rectCount + 1;
                    colorMapVal = labelDef.LabelColor(i,:);
                    rect(rectCount).colorMapVal = colorMapVal;
                    rect(rectCount).name = cell2mat(labelDef.Name(i));
                    %rect(rectCount).colorMapVal = cell2mat(labelDef.LabelColor(i));
                    %rect(rectCount).name = cell2mat(labelDef.Name(i));
                    rect(rectCount).labelId = i;
                else
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

