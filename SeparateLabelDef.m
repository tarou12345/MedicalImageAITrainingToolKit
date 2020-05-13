classdef SeparateLabelDef
    % labelDef をsegmentation と Rectに分割
    
    properties
        segment
        rect
        segmentCount
        rectCount
    end
    
    methods
        function obj = SeparateLabelDef(gTruth)
            % SEPARATELABELDEF このクラスのインスタンスを作成
            
            % 設定
            labelDef = gTruth.LabelDefinitions;
            numOfLabel = size(labelDef,1);
            segmentCount = 0;
            rectCount = 0;
            
            % PixellabelId の有り無しを検出
            % ToDo: なぜかexistでテーブルの列の存在を確認できない
            % 汚すぎるコードだけどエラー処理を利用して存在を確認
%             isPixelExist = 1;
%             try
%                 labelDef.PixelLabelID(1);
%             catch
%                 isPixelExist = 0;
%             end
%             if isPixelExist ==0 
%             end
                
            % table内がセルデータであるためforループで抽出
            % type 0 : rect
            % type 4 : segment
            % ToDo ： ほかのタイプ分類
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
                    % segment なら pixelLabelId があるはず
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

